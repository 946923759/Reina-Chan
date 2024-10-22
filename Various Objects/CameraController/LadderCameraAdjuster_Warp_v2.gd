tool
extends Area2D
#signal camera_adjusted(camera, newBounds, tweenTime)
signal player_teleported(new_player_position)

export (float) var tweenTime = 1.0;
export (bool) var freeze_player_during_transition=true
export (bool) var only_if_on_ladder=false
export (int,"Before","After") var warp_when = 0
export (Vector2) var warp_position = Vector2(0,0) setget set_warp_position
export (Rect2) var camera_bounds #This is bounds before teleporting
export (int,"Upwards","Downwards","Do not adjust camera") var ladder_type
#export (Rect2) var downwards_warp_bounds
export(int,0,16) var warp_num = 0 setget set_warp_num


const CAMERA_SCALE = 64;


var player:KinematicBody2D

func set_warp_num(i):
	warp_num = i
	update()
	
func set_warp_position(v):
	warp_position = v
	update()

func _draw():
	if Engine.editor_hint:
		var c = Color.from_hsv(float(warp_num)/16.0,1,.75)
		draw_line(Vector2(0,0), warp_position*CAMERA_SCALE*1/scale, c, 25.0)
#func _draw():
#	if is_processing():
#		draw_rect(Rect2(-8,-8,64,64),Color.red)
#	else:
#		draw_rect(Rect2(-8,-8,64,64),Color.blue)

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
	set_process(false)
	#update()
	add_to_group("ladderWarp")

func player_entered(obj):
	if obj.has_method("player_touched"):
		#print("Touched camera trigger!")
		#if only_if_on_ladder and obj.state != 6:
		#	print("Not on ladder, ignoring")
		#	return
		player = obj
		set_process(true)
	#update()
	
func player_exited(obj):
	if obj.has_method("player_touched"):
		#print("Touched camera trigger!")
		#if only_if_on_ladder and obj.state != 6:
		#	print("Not on ladder, ignoring")
		#	return
		#if cooldown<=0:
		#	cam(obj)
		#	cooldown=.3
		player = null
		set_process(false)
	#update()

var cooldown:float = 0.0
func _process(delta):
	if player:
		
		if player.velocity.y > -4 and ladder_type == 0: #If upwards ladder but not upwards
			return
		elif player.velocity.y < 4 and ladder_type == 1: #If downwards ladder but not downwards
			return
		
		#If only trigger when on ladder, upwards ladder, and player not on ladder
		elif only_if_on_ladder and ladder_type == 0 and player.state != 6:
			return
		
		var cc:Camera2D = player.get_node("Camera2D")
		if cc.is_tweening:
			return
		
		#If we got this far, we can finally transition the camera
		cam(player)
		player = null
		set_process(false)
	
	if cooldown>0.0:
		cooldown-=delta
	else:
		set_process(false)


func teleport_player(player:KinematicBody2D):
	var cc:Camera2D = player.get_node("Camera2D")
	player.position += warp_position*CAMERA_SCALE
	
	cc.adjustCamera([
		cc.limit_left + warp_position.x*CAMERA_SCALE,
		cc.limit_top + warp_position.y*CAMERA_SCALE,
		cc.limit_right + warp_position.x*CAMERA_SCALE,
		cc.limit_bottom + warp_position.y*CAMERA_SCALE,
	], 0.0)
	emit_signal("player_teleported", player.position)
	#cc.limit_top += warp_position.y*CAMERA_SCALE
	#cc.limit_bottom += warp_position.y*CAMERA_SCALE
	#cc.limit_left += warp_position.x*CAMERA_SCALE
	#cc.limit_right += warp_position.x*CAMERA_SCALE

var disabled = false
func cam(player:KinematicBody2D):
	#disabled = true
	var cc:Camera2D = player.get_node("Camera2D")
	
	# To teleport before:
	# - Teleport player to new location
	# - Offset their camera bounds by the teleport
	# - Transition to the new bounds, new bounds are also offset
	
	# To teleport after:
	# - Transition player to new camera bounds
	# - Teleport player to new location
	# - Offset the bounds by teleport offset
	
	
	#We don't want to overwrite leftBound,rightBound, etc so keep the changed variables in a new array.
	var boundsArray = [0,0,0,0]
	
	var leftBound = camera_bounds.position.x
	var topBound = camera_bounds.position.y
	var rightBound = camera_bounds.size.x
	var bottomBound = camera_bounds.size.y
	
	if rightBound == -999:
		boundsArray[2] = leftBound*CAMERA_SCALE+Globals.gameResolution.x
	else:
		boundsArray[2] = rightBound*CAMERA_SCALE
		
	if leftBound == -999:
		boundsArray[0] = rightBound*CAMERA_SCALE-Globals.gameResolution.x
	elif leftBound == -9999:
		boundsArray[0] = cc.limit_right
	else:
		boundsArray[0] = leftBound*CAMERA_SCALE;
		#print("WARN: Left and right bounds are not defined. The camera won't work.")
		
	if topBound == -999:
		#print("Top is -999")
		boundsArray[1]=bottomBound*CAMERA_SCALE-Globals.gameResolution.y
	else:
		boundsArray[1]=topBound*CAMERA_SCALE
	
	if bottomBound == -999:
		boundsArray[3] = boundsArray[1]+Globals.gameResolution.y
	else:
		boundsArray[3] = bottomBound*CAMERA_SCALE
		
	
	if warp_when==0:
		teleport_player(player)
		boundsArray[0] += warp_position.x*CAMERA_SCALE
		boundsArray[1] += warp_position.y*CAMERA_SCALE
		boundsArray[2] += warp_position.x*CAMERA_SCALE
		boundsArray[3] += warp_position.y*CAMERA_SCALE

	
	#if cc.destPositions[1] == boundsArray[1] and cc.destPositions[3]==boundsArray[3]:
	#	#print("No need to adjust!")
	#	return
	
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
	#emit_signal("camera_adjusted",cc, boundsArray, tweenTime)
	
	if warp_when==1:
		yield(cc,"camera_finished_tween")
		teleport_player(player)
