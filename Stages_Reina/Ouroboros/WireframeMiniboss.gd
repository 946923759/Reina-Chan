extends "res://Stages/EnemyBaseScript.gd"

var ti = 0.0
func _process(delta):
	ti+=delta
	
	sprite.rotation_degrees+=delta*200
	return
	
	if ti>.1:
		sprite.rotation_degrees+=15
		if sprite.rotation_degrees >= 360:
			sprite.rotation_degrees=0
		ti=0
