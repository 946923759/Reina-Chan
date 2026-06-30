extends Node2D

export(PackedScene) var large_bullet
var player:KinematicBody2D

func _ready():
	set_process(false)
	
func _process(delta):
	update()
	
func _draw():
	var A = player.global_position
	var B = self.global_position

	var dir:Vector2 = (A - B).normalized()

	if abs(dir.x) > 0.0001:
		var t = -B.x / dir.x
		var hit = B + dir * t

		# Shift into B-relative space
		var local_start = Vector2.ZERO
		var local_end = hit - B

		draw_line(local_start, local_end, Color.red, 2)



func _on_Node2D_ready():
	player = get_node("/root/Node2D").get_player()
	set_process(true)
	print("Tree")
