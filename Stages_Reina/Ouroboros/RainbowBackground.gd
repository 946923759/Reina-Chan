extends Sprite

var color:float = 0.0
func _process(delta):
	get_material().set_shader_param("clr1", Color.from_hsv(color,.2,.2))
	color+=delta*.1
	if color>360:
		color=0
