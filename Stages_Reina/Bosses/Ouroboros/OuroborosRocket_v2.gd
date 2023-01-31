extends "res://Stages_Reina/Bosses/BaseRocket.gd"


var startingDirection:int=0
func init(startingDirection_=DIRECTION.LEFT,canChangeDirections=false,_harderRockets=false):
	shouldGoTowards=startingDirection_
	startingDirection=startingDirection_
	handle_sprite_direction()

var processTime:float=0.0
func _physics_process(delta):
	match shouldGoTowards:
		DIRECTION.LEFT:
			curVelocity=Vector2(-10,0)
			processTime+=delta
			#Gee if only I listened in trigonometry class!
			if startingDirection!=DIRECTION.LEFT:
				var playerPos:Vector2 = get_node("/root/Node2D/").get_player().global_position
				if global_position.x < playerPos.x+300 and startingDirection==DIRECTION.UPLEFT:
					shouldGoTowards=DIRECTION.DOWNLEFT
				elif startingDirection==DIRECTION.UPRIGHT:
					shouldGoTowards=DIRECTION.DOWNRIGHT
		DIRECTION.RIGHT:
			curVelocity=Vector2(10,0)
		DIRECTION.UPLEFT:
			curVelocity=Vector2(-10,-10)
			processTime+=delta
			if processTime>.5:
				processTime=0
				shouldGoTowards=DIRECTION.LEFT
		DIRECTION.DOWNLEFT:
			curVelocity=Vector2(-10,10)
