extends "res://hud/circularReadout.gd"

func _ready():
	if not reader.has_method("register_sensor_display"):
		return
	yield(self, "setup")
	disconnect("visibility_changed", self, "_onVisibityChanged")
	set_process(false)
	set_physics_process(false)
	
	var booter_format:String = "register graphical display %X for sensor %X: {v}" % [name.hash(), sensor.hash()]
	reader.register_sensor_display({
		"sensor":sensor,
		"node":self,
		"booter_format":booter_format,
	})

func display_sensor(readout,delta:float):
	if flash > 0:
		flash -= delta
		flashing += delta
	
	if recheckWarningLevels:
		readWarningLevels()
	if readout == null:
		if not physical:
			self_modulate = errColor
			value = 0
		return
	var color:Color = okColor
	if readout < minWarn or readout > maxWarn:
		color = warnColor
	if readout < minErr or readout > maxErr:
		color = errColor
		if not alerted:
			ship.soundAlert()
			alerted = true
			flash = flashTime
	else:
		alerted = false
		flash = 0
	if flash > 0:
		if flashing > flashingTime:
			flashOnOff = not flashOnOff
			flashing = 0
		if flashOnOff:
			color.a = flashAlpha
	self_modulate = color
	if absolute:
		value = abs(readout)
	else:
		value = readout

signal setup
func _onVisibityChanged():
	._onVisibityChanged()
	emit_signal("setup")

