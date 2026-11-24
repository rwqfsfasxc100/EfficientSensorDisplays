extends "res://hud/Hud.gd"

# Individual sensor refs
var sensor_store:Dictionary = Dictionary()

# Store info all equivalent sensors use
var sensor_cache:Dictionary = Dictionary()

var registered_sensors:PoolStringArray = PoolStringArray()

var equipment_store:Dictionary = Dictionary()
var equipment_cache:Dictionary = Dictionary()

var registered_equipment:PoolStringArray = PoolStringArray()

onready var pointers:HevLibPointers = ModLoader._savedObjects[0]

func _ready():
	Settings.connect("settingsChanged",self,"recalculate_flicker")
	pointers.ConfigDriver.__subscribe_to_setting_change("sensor_resolution_uv",self,"FASTSENSORS_NAME","FASTSENSORS_CONFIG_SECT_GENERAL","sensor_tick_rate")
	pointers.ConfigDriver.__subscribe_to_setting_change("sensor_packet_uv",self,"FASTSENSORS_NAME","FASTSENSORS_CONFIG_SECT_GENERAL","sensor_packet_count")
	pointers.ConfigDriver.__subscribe_to_setting_change("valid_sensors_only_uv",self,"FASTSENSORS_NAME","FASTSENSORS_CONFIG_SECT_GENERAL","show_only_valid_outputs")
	sensor_resolution_uv(pointers.ConfigDriver.__get_value("FASTSENSORS_NAME","FASTSENSORS_CONFIG_SECT_GENERAL","sensor_tick_rate",15))
	sensor_packet_uv(pointers.ConfigDriver.__get_value("FASTSENSORS_NAME","FASTSENSORS_CONFIG_SECT_GENERAL","sensor_packet_count",1))
	valid_sensors_only_uv(pointers.ConfigDriver.__get_value("FASTSENSORS_NAME","FASTSENSORS_CONFIG_SECT_GENERAL","show_only_valid_outputs",false))

var sensor_resolution:float = 1.0 / 15.0
var packet_target:int = 1
var only_valid:bool = false

func sensor_resolution_uv(how:int):
	sensor_resolution = 1.0 / how

func sensor_packet_uv(how:int):
	packet_target = how
	Tool.deferCallInPhysics(self,"recalculate_sensor_packets",[],true)

func valid_sensors_only_uv(how:int):
	only_valid = how

func register_sensor_display(data:Dictionary):
	var sensor:String = data.get("sensor","")
	if not sensor in registered_sensors:
		sensor_store[sensor] = Array()
		sensor_cache[sensor] = [float(hash(sensor)) + 1.0,sensor.hash()]
		registered_sensors.append(sensor)
	var arr:Array = get_data_array(data)
	if arr:
		sensor_store[sensor].append(arr)
	hammer_sensors.append({
		"object":self,
		"method":"call_sensor",
		"args":[sensor,sensor_store[sensor],sensor_cache[sensor]]
	})
	Tool.deferCallInPhysics(self,"recalculate_sensor_packets",[],true)

func register_equipment_display(data:Dictionary):
	var sensor:String = data.get("sensor","")
	if not sensor in registered_equipment:
		equipment_store[sensor] = Array()
		equipment_cache[sensor] = sensor.hash()
		registered_equipment.append(sensor)
	var arr:Array = get_data_array(data)
	if arr:
		equipment_store[sensor].append(arr)
	hammer_equipment.append({
		"object":self,
		"method":"call_equipment",
		"args":[sensor,equipment_store[sensor]]
	})
	Tool.deferCallInPhysics(self,"recalculate_sensor_packets",[],true)

var flicker:float = 600.0

var sensor_ctr:float = 0.0
func _process(delta):
	sensor_ctr += delta
	if sensor_ctr > sensor_resolution:
		sensor_ctr = 0
		poll_sensors(delta)

const DATA_COUNT = 2

func get_data_array(dict:Dictionary) -> Array:
	var node:Node = dict.get("node",null)
	var sensor:String = dict.get("sensor","")
	if not Tool.ovnolock(node) or sensor.empty():
		return Array()
	var out:Array = Array()
	out.resize(DATA_COUNT)
	out[0] = node
	out[1] = dict.get("booter_format","register text display %X for sensor %X: {v}" % [node.name.hash(), sensor.hash()])
	return out

var hammer_equipment:Array = Array()
var hammer_sensors:Array = Array()

var equipment_packets:Array = Array()
var sensor_packets:Array = Array()

var lag:float = 0.0
var failRate:float = 0.0
var short:float = 0.0
var show_boot:bool = false
var poll_delta:float = 0.0

var sensor_packet_index:int = 0
var sensor_packet_wrap:int = 0

var equipment_packet_index:int = 0
var equipment_packet_wrap:int = 0

func recalculate_sensor_packets():
	if hammer_equipment:
		hammer_equipment.shuffle()
		var he_size:int = hammer_equipment.size()
		if he_size < packet_target:
			equipment_packet_wrap = he_size - 1
			equipment_packets.resize(he_size)
			for i in he_size:
				equipment_packets[i] = [hammer_equipment[i]]
		else:
			equipment_packet_wrap = packet_target - 1
			equipment_packets.resize(packet_target)
			for i in packet_target:
				equipment_packets[i] = []
			for i in he_size:
				equipment_packets[i % packet_target].append(hammer_equipment[i])
	
	if hammer_sensors:
		hammer_sensors.shuffle()
		var hs_size:int = hammer_sensors.size()
		if hs_size < packet_target:
			sensor_packet_wrap = hs_size - 1
			sensor_packets.resize(hs_size)
			for i in hs_size:
				sensor_packets[i] = [hammer_sensors[i]]
		else:
			sensor_packet_wrap = packet_target - 1
			sensor_packets.resize(packet_target)
			for i in packet_target:
				sensor_packets[i] = []
			for i in hs_size:
				sensor_packets[i % packet_target].append(hammer_sensors[i])
	

func poll_sensors(delta:float):
	if Tool.claim(ship):
		lag = getLag()
		failRate = pow(getCondition("sensors"), 2)
		short = clamp(getCondition("shortcircuit"), 0, 1)
		show_boot = bootProgress > 0 and bootProgress < bootTime and ship.isPlayerControlled()
		poll_delta = delta
		if equipment_packets:
			pointers.Threading.__request_multiple_threads(equipment_packets[equipment_packet_index])
		Tool.release(ship)
		if sensor_packets:
			pointers.Threading.__run_multiple_async_operations(sensor_packets[sensor_packet_index])
		sensor_packet_index += 1
		if sensor_packet_index > sensor_packet_wrap:
			sensor_packet_index = 0
		equipment_packet_index += 1
		if equipment_packet_index > equipment_packet_wrap:
			equipment_packet_index = 0

func getErrorFromRaw(short:float,error:float):
	return clamp(1 + (short * ((error / errorSampleSize) + pow(2 * short * randf() - 0.5, 6))), 0, 2)

func recalculate_flicker():
	flicker = (1.0 if Settings.cfg.display.reduceFlicker else 600.0)

func bootRaw(s: String, v: Dictionary = Dictionary()):
	emit_signal("bootMsg", s, v)

func call_sensor(sensor:String,store:Array,cache:Array):
	var vis:Array = Array()
	for i in store:
		var box = i[0]
		if (box.enabled and box.is_visible_in_tree()) or box.alwaysUpdate:
			vis.append(i)
	if vis:
		var readout = null
		if show_boot:
			if (0.5 * (sin(getRawError((cache[0]), flicker)) + 1.0)) < failRate:
				bootRaw("Sensor %X ERROR" % cache[1])
			elif bootProgress + randFluc * randf() < bootTime:
				bootRaw("Sensor %X FAILED" % cache[1])
		else:
			readout = ship.sensorGet(sensor)
		if readout != null:
			readout *= getErrorFromRaw(short,getRawError((cache[0]), flicker))
			if show_boot:
				bootRaw("Sensor %X SUCCESS: {v}" % cache[1], {"v": "%.2f" % readout})
		elif only_valid:return
		for entry in vis:
			if show_boot and readout != null and pow(randf(), 4.0) > lag:
				bootRaw(entry[1],{"v": "%.3f" % readout})
			entry[0].display_sensor(readout,poll_delta)

func call_equipment(sensor:String,store:Array):
	var sys = getSystem(sensor)
	if sys:
		var vis:Array = Array()
		for i in store:
			var box = i[0]
			if (box.is_visible_in_tree()):
				var power:float = sys.power
				var status:float = sys.status
				if show_boot:
					bootRaw(i[1], {"s": status, "p": "%.2f" % power})
				box.display_sensor(sys.enabled,power,status)
