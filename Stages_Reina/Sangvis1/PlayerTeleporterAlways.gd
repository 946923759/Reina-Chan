tool
extends Area2D
signal player_teleported(new_player_position)

const CAMERA_SCALE = 64;

export (Vector2) var warp_position = Vector2(0,0) setget set_warp_position

var player:KinematicBody2D



func set_warp_position(v):
	warp_position = v
	update()
	
func _draw():
	if Engine.editor_hint:
		var c = Color.red
		draw_line(Vector2(0,0), warp_position*CAMERA_SCALE*1/scale, c, 25.0)

func _ready():
# warning-ignore:return_value_discarded
	self.connect("body_entered",self,"teleport_player")

func teleport_player(player:KinematicBody2D):
	var cc:Camera2D = player.get_node("Camera2D")
	player.position += warp_position*CAMERA_SCALE
	
	cc.adjustCamera([
		cc.limit_left + warp_position.x*CAMERA_SCALE,
		cc.limit_top + warp_position.y*CAMERA_SCALE,
		cc.limit_right + warp_position.x*CAMERA_SCALE,
		cc.limit_bottom + warp_position.y*CAMERA_SCALE,
	], 0.0)
	emit_signal("player_teleported", player.position)
