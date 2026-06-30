extends Node2D

var diffuse:Color = Color.white
var object_A:Node2D

onready var bullet_spawn_pos:Vector2 = $Position2D.position
onready var sprite:AnimatedSprite = $AnimatedSprite
onready var charge:AnimatedSprite = $Charge

func _draw():
	if !is_instance_valid(object_A):
		return
	if diffuse.a <= 0.0:
		return
	var A = object_A.global_position
	var B = self.global_position

	var dir:Vector2 = (A - B).normalized()

	if abs(dir.x) > 0.0001:
		var t = -B.x / dir.x
		var hit = B + dir * t

		# Shift into B-relative space
		var local_start = Vector2.ZERO
		var local_end = hit - B

		draw_line(local_start, local_end, diffuse, 2)
		
#The arguments are flipped because the tweener requires it
func draw_tangent_towards(line_color:Color, ob:Node2D):
	object_A = ob
	diffuse = line_color
	update()
	#set_process(true)

func play(s:String):
	sprite.play(s)
	if s=="charging":
		charge.play("default")
		charge.visible = true
	else:
		charge.stop()
		charge.visible = false
