extends Node2D

var platform = preload("res://bntest/Platform.tscn")


var platformCenter:Vector2
onready var characters:Node2D = $Characters
#var characters:Node2D

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
