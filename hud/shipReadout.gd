extends "res://hud/shipReadout.gd"

func _ready():
	if not reader.has_method("register_equipment_display"):
		return
	
	yield(self, "setup")
	disconnect("visibility_changed", self, "_visibilityChanged")
	set_process(false)
	set_physics_process(false)
	
	var booter_format:String = "system %X status: {s}, power: {p}" % name.hash()
	reader.register_equipment_display({
		"sensor":name,
		"node":self,
		"booter_format":booter_format,
	})

func display_sensor(enabled:bool,readout:float,status:float):
	if enabled:
		var color:Color = colorOk
		if status <= warnLevel:
			color = colorWarn
		if status <= errLevel:
			color = colorErr
		self_modulate = Color(1, 1, 1, clamp(readout, 0.1, 1)) * color
	else:
		self_modulate = colorOff




signal setup
func _visibilityChanged():
	._visibilityChanged()
	emit_signal("setup")
