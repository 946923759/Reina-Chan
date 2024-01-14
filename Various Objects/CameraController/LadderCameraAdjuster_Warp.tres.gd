#tool
extends Area2D
signal camera_adjusted(camera,newBounds)

export (float,-3,3,.5) var center_bound_offset = 0
export (float) var tweenTime = 1;
export (bool) var freeze_player_during_transition=true
export (bool) var only_if_on_ladder=false
export (int,"Relative","Absolute") var warp_type = 0;
export (int,"Before","After") var warp_when = 0
export (Vector2) var warp_position = Vector2(0,0)
export (Rect2) var warp_bounds
export (int,"Upwards","Downwards","Do not adjust camera") var ladder_type
#export (Rect2) var downwards_warp_bounds


const cameraScale = 64;
#export(Shape2D) var shape;


#var player

func _ready():
	#The shape to trigger the camera. If the assertion is failing, the camera can't be triggered so it's useless.
	#In other words, give your camera controller a shape! It's somewhere in your stage!
	#assert(shape)
	#if OS.is_debug_build():
	#	self.get_node("CollisionShape2D").set_shape(shape)
	#self.shape_owner_add_shape(self.create_shape_owner(self), shape)
# warning-ignore:return_value_discarded
	self.connect("body_entered",self,"player_entered")
# warning-ignore:return_value_discarded
	self.connect("body_exited",self,"player_exited")

func player_entered(obj):
	if obj.has_method("player_touched"):
		print("Touched camera trigger!")
		if only_if_on_ladder and obj.state != 6:
			print("Not on ladder, ignoring")
			return

		if cooldown<=0:
			cam(obj)
			cooldown=.3
		set_process(true)
	
func player_exited(obj):
	if obj.has_method("player_touched"):
		print("Touched camera trigger!")
		if only_if_on_ladder and obj.state != 6:
			print("Not on ladder, ignoring")
			return
		if cooldown<=0:
			cam(obj)
			cooldown=.3
		set_process(true)

var cooldown:float = 0.0
func _process(delta):
	if cooldown>0.0:
		cooldown-=delta
	else:
		set_process(false)


func teleport_player(player:KinematicBody2D, relative_warp:bool=true):
	var cc:Camera2D = player.get_node("Camera2D")
	if relative_warp:
		player.position += warp_position*cameraScale
		
		cc.limit_top += warp_position.y*cameraScale
		cc.limit_bottom += warp_position.y*cameraScale
		cc.limit_left += warp_position.x*cameraScale
		cc.limit_right += warp_position.x*cameraScale
	else:
		player.position = warp_position*cameraScale

var disabled = false
func cam(player:KinematicBody2D):
	if player.velocity.y > -4 and ladder_type == 0: #If upwards ladder but not upwards
		return
	elif player.velocity.y < 4 and ladder_type == 1: #If downwards ladder but not downwards
		return
	#disabled = true
	var cc:Camera2D = player.get_node("Camera2D")
	
	if cc.is_tweening:
		return
	if ladder_type == 2: #DO_NOT_WARP
		return
	
	
	
	#We don't want to overwrite leftBound,rightBound, etc so keep the changed variables in a new array.
	var boundsArray = [0,0,0,0]
	
	var leftBound = warp_bounds.position.x
	var topBound = warp_bounds.position.y
	var rightBound = warp_bounds.size.x
	var bottomBound = warp_bounds.size.y
	
	if rightBound == -999:
		boundsArray[2] = leftBound*cameraScale+Globals.gameResolution.x
	else:
		boundsArray[2] = rightBound*cameraScale
		
	if leftBound == -999:
		boundsArray[0] = rightBound*cameraScale-Globals.gameResolution.x
	elif leftBound == -9999:
		boundsArray[0] = cc.limit_right
	else:
		boundsArray[0] = leftBound*cameraScale;
		#print("WARN: Left and right bounds are not defined. The camera won't work.")
	
	
	if warp_when==0:
		teleport_player(player, warp_type==0)
			
	#If the player is going up
	if ladder_type == 0:
		
		#print("Top bound "+String(boundsArray[3]))
		
		#Set bottom bound to location of the camera trigger
		#boundsArray[3]=global_position.y+center_bound_offset*cameraScale
		
		#if warp_type==0:
		#	cc.limit_top += warp_position.y*cameraScale
		#	cc.limit_bottom += warp_position.y*cameraScale
			
		boundsArray[3]=bottomBound*cameraScale
		#cc.limit_top = boundsArray[3]
		#cc.limit_bottom = boundsArray[3]+Globals.gameResolution.y
		
		if topBound == -999:
			boundsArray[1] = boundsArray[3]-Globals.gameResolution.y
		else:
			boundsArray[1] = topBound*cameraScale;
	elif ladder_type == 1:
		
		if topBound == -999:
			#print("Top is -999")
			boundsArray[1]=bottomBound*cameraScale-Globals.gameResolution.y
		else:
			boundsArray[1]=topBound*cameraScale
		
		if bottomBound == -999:
			boundsArray[3] = boundsArray[1]+Globals.gameResolution.y
		else:
			boundsArray[3] = bottomBound*cameraScale
			
	if cc.destPositions[1] == boundsArray[1] and cc.destPositions[3]==boundsArray[3]:
		#print("No need to adjust!")
		return
	
	print("LEFT: "+ String(boundsArray[0])+ " TOP: "+String(boundsArray[1])+" RIGHT: "+String(boundsArray[2]) + " BOTTOM: "+String(boundsArray[3]))
	assert(boundsArray[0] < boundsArray[2]);
	assert(boundsArray[1] < boundsArray[3]);
	
	#
	if freeze_player_during_transition or player.state == 6: #State.ON_LADDER:
		if player.velocity.y < 0:
			player.lockMovement(1,Vector2(0,-100))
		else:
			player.lockMovement(tweenTime,Vector2(0,100))
	cc.adjustCamera(boundsArray, tweenTime)
	
	#What is this even FOR??? It doesn't wait for the tween, there's no way this is useful right?
	emit_signal("camera_adjusted",cc,boundsArray)
	
	if warp_when==1:
		yield(cc,"camera_finished_tween")
		teleport_player(player, warp_type==0)
