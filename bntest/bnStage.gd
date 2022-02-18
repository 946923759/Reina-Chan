extends Node2D

var platform = preload("res://bntest/Platform.tscn")


var platformCenter:Vector2
func _ready():
	#for i in range(3):
	platformCenter=$Stage/Sprite.position
	platformCenter.y-=75
	$Player.init(platformCenter)
	$Player2.init(platformCenter)
	#$Player.position=platformCenter
	#$Player.platformCenter=platformCenter
