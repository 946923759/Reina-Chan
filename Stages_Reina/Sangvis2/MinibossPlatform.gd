extends StaticBody2D

var position_wrapper:Vector2 setget set_pos, get_pos
var player_ref:KinematicBody2D

func _ready():
	$Area2D.connect("body_entered",self,"obj_touched")
	$Area2D.connect("body_exited",self,"obj_exited")

func obj_touched(obj):
	if obj is KinematicBody2D:
		player_ref = obj
		$Label.text = "True"
	
func obj_exited(obj):
	if obj is KinematicBody2D:
		player_ref = null
		$Label.text = "False"
		
func set_pos(p:Vector2):
	if player_ref and player_ref.is_on_floor():
		player_ref.position += p-position
	position = p

func get_pos():
	return position
