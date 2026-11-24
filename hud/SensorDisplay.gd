extends "res://hud/SensorDisplay.gd"

func _ready():
	if not reader.has_method("register_sensor_display"):
		return
	
	yield(self, "setup")
	disconnect("visibility_changed", self, "_onVisibityChanged")
	set_process(false)
	set_physics_process(false)
	
	var booter_format:String = "register text display %X for sensor %X: {v}" % [name.hash(), sensor.hash()]
	reader.register_sensor_display({
		"sensor":sensor,
		"node":self,
		"booter_format":booter_format,
	})

func display_sensor(readout,delta:float):
	if readout == null:
		text = empty
		self_modulate = errColor
		return
	
	text = format % (readout * conversion + conversionOffset)
	if flash > 0:
		flash -= delta
	var color:Color = okColor
	if readout < minWarn or readout > maxWarn:
		color = warnColor
	if readout < minErr or readout > maxErr:
		color = errColor
		if not erred:
			flash = flashTime
		erred = true
	else:
		erred = false
		flash = 0
	if flash > 0:
		flashOnOff = not flashOnOff
		if flashOnOff:
			color.a = flashAlpha
		else:
			color.a *= flashBrightness
	self_modulate = color
	

signal setup
func _onVisibityChanged():
	._onVisibityChanged()
	emit_signal("setup")

