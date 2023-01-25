extends "res://Stages_Reina/Bosses/BaseRocket.gd"

var harderRockets=false

func init(startingDirection=DIRECTION.LEFT,canChangeDirections=false,_harderRockets=false):
	#shouldGoTowards=DIRECTION.LEFT if facingLeft else DIRECTION.RIGHT
	shouldGoTowards=startingDirection
	harderRockets=_harderRockets
	handle_sprite_direction()

var timeSinceChange:float=0
func _physics_process(delta):
	#move_and_slide(Vector2(0,300))

	handle_sprite_direction()
			
	
	"""var playerPos = get_node("/root/Node2D/Player").global_position
	var movX = 0
	if playerPos.x > global_position.x+50:
		movX = 5
	elif playerPos.x < global_position.x-50:
		movX=-5
			
	var movY = 0
	if playerPos.y > global_position.y+30:
		movY = 5
	elif playerPos.y < global_position.y-30:
		movY = -5
	
	if movX < 0:
		if movY > 0:
			shouldGoTowards = DIRECTION.DOWNLEFT
		elif movY < 0:
			shouldGoTowards = DIRECTION.UPLEFT
		else:
			shouldGoTowards = DIRECTION.LEFT
	elif movX > 0:
		if movY > 0:
			shouldGoTowards = DIRECTION.DOWNRIGHT
		elif movY < 0:
			shouldGoTowards = DIRECTION.UPRIGHT
		else:
			shouldGoTowards = DIRECTION.RIGHT
	else:
		if movY > 0:
			shouldGoTowards = DIRECTION.DOWN
		elif movY < 0:
			shouldGoTowards = DIRECTION.UP"""
	
	"""if timeSinceChange > .1: # and curVelocity!=Vector2(movX,movY)
		curVelocity=Vector2(movX,movY)
		timeSinceChange=0
	else:
		timeSinceChange+=delta"""
	
	if harderRockets:
		var playerPos = get_node("/root/Node2D/").get_player().global_position
		
		if shouldGoTowards==DIRECTION.LEFT or shouldGoTowards==DIRECTION.RIGHT:
			curVelocity.y=0
			if playerPos.y > global_position.y+30:
				curVelocity.y = 2
			elif playerPos.y < global_position.y-30:
				curVelocity.y = -2
				
			
			if shouldGoTowards==DIRECTION.RIGHT:
				curVelocity.x+=1
			else:
				curVelocity.x+=-1
		elif shouldGoTowards==DIRECTION.DOWN:
			curVelocity.y+=1
	else:
		if shouldGoTowards==DIRECTION.RIGHT:
			curVelocity.x=10
		elif shouldGoTowards==DIRECTION.LEFT:
			curVelocity.x=-10
		elif shouldGoTowards==DIRECTION.DOWN:
			curVelocity.y=10
			
