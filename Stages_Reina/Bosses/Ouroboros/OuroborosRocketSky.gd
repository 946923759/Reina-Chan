extends "res://Stages_Reina/Bosses/BaseRocket.gd"

onready var marker = $Sprite

var startingDirection:int=0
func init(startingDirection_=DIRECTION.LEFT,canChangeDirections=false,_harderRockets=false):
	shouldGoTowards=startingDirection_
	startingDirection=startingDirection_
	handle_sprite_direction()
	
var destXpos:float
var waitTime:float
var speed:float
func init2(startingDirection_=DIRECTION.LEFT,destXPos_:float=5.0,waitTime_:float=1.0,speed_:float=24.0):
	shouldGoTowards=startingDirection_
	startingDirection=startingDirection_
	destXpos=destXPos_
	speed=speed_
	#print("[OuroborosRocketSky] Wait for "+String(waitTime_))
	waitTime=waitTime_
	handle_sprite_direction()
	$CollisionShape2D.disabled=true

func get_pos_relative_to_room()->Vector2:
	return get_parent().position + position
func set_pos_relative_to_room(obj:Node2D,p:Vector2):
	obj.position=p-get_parent().position

var processTime:float=0.0
func _physics_process(delta):
	match shouldGoTowards:
		DIRECTION.LEFT:
			curVelocity=Vector2(-10,0)
			processTime+=delta
			#Gee if only I listened in trigonometry class!
			#if startingDirection!=DIRECTION.LEFT:
			#	var playerPos:Vector2 = get_node("/root/Node2D/").get_player().global_position
			#	if global_position.x < playerPos.x+300 and startingDirection==DIRECTION.UPLEFT:
			#		shouldGoTowards=DIRECTION.DOWNLEFT
			#	elif startingDirection==DIRECTION.UPRIGHT:
			#		shouldGoTowards=DIRECTION.DOWNRIGHT
		DIRECTION.RIGHT:
			curVelocity=Vector2(10,0)
		DIRECTION.UPLEFT:
			curVelocity=Vector2(-10,-10)
			processTime+=delta
			if processTime>.5:
				processTime=0

				curVelocity=Vector2(0,0)
				set_pos_relative_to_room(self,Vector2(destXpos,-3)*64)
				set_pos_relative_to_room(marker,Vector2(destXpos,11)*64-position)

				$CollisionShape2D.disabled=false
				shouldGoTowards=DIRECTION.DOWN
				#shouldGoTowards=DIRECTION.LEFT
		DIRECTION.DOWNLEFT:
			curVelocity=Vector2(-10,10)
		DIRECTION.DOWN:
			marker.visible=true
			if waitTime<0:
				curVelocity=Vector2(0,speed)
				set_pos_relative_to_room(marker,Vector2(destXpos,11)*64-position)
				
			waitTime-=delta
