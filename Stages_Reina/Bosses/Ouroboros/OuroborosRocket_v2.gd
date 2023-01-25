extends "res://Stages_Reina/Bosses/BaseRocket.gd"

func _physics_process(delta):
	match shouldGoTowards:
		DIRECTION.LEFT:
			curVelocity=Vector2(-10,0)
		DIRECTION.RIGHT:
			curVelocity=Vector2(10,0)
		
