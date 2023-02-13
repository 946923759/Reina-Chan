extends "res://Stages_Reina/Bosses/BaseRocket.gd"

onready var hurtBox:CollisionShape2D = $CollisionShape2D
var startingDirection:int=0

var spd:float = 10

func init(startingDirection_=DIRECTION.LEFT,canChangeDirections=false,_harderRockets=false):
	hurtBox.disabled=true
#	$CollisionShape2D.disabled=true
	shouldGoTowards=startingDirection_
	startingDirection=startingDirection_
	
	if _harderRockets:
		spd=12
	
	handle_sprite_direction()

var processTime:float=0.0
func _physics_process(delta):
	processTime+=delta
	hurtBox.disabled = processTime<.5
	
	
	match shouldGoTowards:
		DIRECTION.LEFT:
			curVelocity=Vector2(-spd,0)
			#Gee if only I listened in trigonometry class!
			if startingDirection!=DIRECTION.LEFT:
				var playerPos:Vector2 = get_node("/root/Node2D/").get_player().global_position
				if global_position.x < playerPos.x+300 and startingDirection==DIRECTION.UPLEFT:
					shouldGoTowards=DIRECTION.DOWNLEFT
#				elif startingDirection==DIRECTION.UPRIGHT:
#					shouldGoTowards=DIRECTION.DOWNRIGHT
		DIRECTION.RIGHT:
			curVelocity=Vector2(spd,0)
			#Gee if only I listened in trigonometry class!
			if startingDirection!=DIRECTION.RIGHT:
				var playerPos:Vector2 = get_node("/root/Node2D/").get_player().global_position
				if global_position.x > playerPos.x-300 and startingDirection==DIRECTION.UPRIGHT:
					shouldGoTowards=DIRECTION.DOWNRIGHT
#				elif startingDirection==DIRECTION.UPRIGHT:
#					shouldGoTowards=DIRECTION.DOWNRIGHT
		DIRECTION.UPLEFT:
			curVelocity=Vector2(-spd,-spd)
			if processTime>.5:
				#processTime=0
				shouldGoTowards=DIRECTION.LEFT
		DIRECTION.UPRIGHT:
			curVelocity=Vector2(spd,-spd)
			if processTime>.5:
				#processTime=0
				shouldGoTowards=DIRECTION.RIGHT
		DIRECTION.DOWNLEFT, DIRECTION.DOWNRIGHT:
			#shouldGoTowards = DOWNLEFT, then 5
			#DIRECTION.DOWN = 6
			# 5-6 = -1
			#if shouldGoTowards = DOWNRIGHT, then 7
			# 7-6 =  1
			curVelocity=Vector2(spd*(shouldGoTowards-DIRECTION.DOWN),spd)
		#DIRECTION.DOWNRIGHT:
		#	curVelocity=Vector2(-10,10)
