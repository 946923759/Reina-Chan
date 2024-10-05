extends Node2D

var platform = preload("res://bntest/Platform.tscn")


var platformCenter:Vector2
onready var characters:Node2D = $Characters
#var characters:Node2D

onready var panels = [
	[$Stage/Panel,  $Stage/Panel2, $Stage/Panel3, $Stage/Panel10, $Stage/Panel11, $Stage/Panel12],
	[$Stage/Panel4, $Stage/Panel5, $Stage/Panel6, $Stage/Panel13, $Stage/Panel14, $Stage/Panel15],
	[$Stage/Panel7, $Stage/Panel8, $Stage/Panel9, $Stage/Panel16, $Stage/Panel17, $Stage/Panel18],
]

func _ready():
	#for i in range(3):
	platformCenter=$Stage/Panel.position
	platformCenter+=Vector2(40*2-3,-10)
	#platformCenter.y-=75
	for c in characters.get_children():
		c.init(platformCenter)
	#$Player.init(platformCenter)
	#$Player2.init(platformCenter)
	#$Player.position=platformCenter
	#$Player.platformCenter=platformCenter

#func _process(delta):
#	

func get_obj_at_pos(v2):
	for c in $Characters.get_children():
		if v2==c.charaPos:
			return c
	return null

func get_panel_at_pos(pos:Vector2, val:bool=true):
	var x = int(pos.x)
	var y = int(pos.y)
	if x>0 and x<7:
		if y>0 and y<4:
			return panels[x-1][y-1]
	return null
