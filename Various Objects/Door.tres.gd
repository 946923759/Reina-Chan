tool
extends Node2D
signal player_entered_door()

export (bool) var automatically_set_x_bounds = true
enum Y_BOUNDS_MODE {
	NO,
	TOP_ALIGNED,
	BOTTOM_ALIGNED
}
export (Y_BOUNDS_MODE) var automatically_set_y_bounds = Y_BOUNDS_MODE.NO

export (bool) var boss_room_door = false
export (bool) var locked = false
export (int) var leftBound;
export (int) var topBound;
export (int) var rightBound;
export (int) var bottomBound;
#export (float) var CAMERA_SCALE = 64.0;
export (float) var tweenTime = .5;
export(AudioStream) var newMusic

enum DOOR_IS_FACING {
	LEFT = -1,
	RIGHT = 1
}
export (DOOR_IS_FACING) var facing = DOOR_IS_FACING.RIGHT

const CAMERA_SCALE = 64;
const ROOM_WIDTH = 20
const ROOM_HEIGHT = 12

const SCREEN_WIDTH:int = 1280
const SCREEN_HEIGHT:int = 720
const SCREEN_CENTER_X = SCREEN_WIDTH/2
const SCREEN_CENTER_Y = SCREEN_HEIGHT/2

# After copying all this code I realized
# there's no reason to ever do this because
# the draw function can just draw based on the object
# position...
func set_bounds():
	#auto_adjust_bounds = t
	if !is_inside_tree():
		return
		
	#We don't align to the nearest room, just the nearest block!!
#	if automatically_set_x_bounds:
#		if facing == DOOR_IS_FACING.LEFT:
#			rightBound=int(global_position.x/CAMERA_SCALE)
#			leftBound=rightBound-ROOM_WIDTH
#			#print("???")
#		else:
#			leftBound=int(global_position.x/CAMERA_SCALE)
#			rightBound=leftBound+ROOM_WIDTH
	
	#Align to the nearest room for this one!
	if automatically_set_y_bounds==Y_BOUNDS_MODE.TOP_ALIGNED:
		topBound = int(floor(global_position.y/CAMERA_SCALE/ROOM_HEIGHT)*ROOM_HEIGHT)
		bottomBound = -999
	elif automatically_set_y_bounds==Y_BOUNDS_MODE.BOTTOM_ALIGNED:
		topBound = -999
		bottomBound = int(floor(global_position.y/CAMERA_SCALE/ROOM_HEIGHT)*ROOM_HEIGHT)+ROOM_HEIGHT

	
#	if t == AUTO_ADJUST.X_ONLY or t == AUTO_ADJUST.X_AND_Y:
#		leftBound = int(floor(global_position.x/CAMERA_SCALE/ROOM_WIDTH)*ROOM_WIDTH)
#		rightBound = leftBound+ROOM_WIDTH
#		#print("Calculated x="+String(leftBound))
#	if t == AUTO_ADJUST.Y_ONLY or t == AUTO_ADJUST.X_AND_Y:
#		#topBound = 
#		# 768
#		var ROOM_HEIGHT_REAL = CAMERA_SCALE*ROOM_HEIGHT
#		var closestRoomBoundary = round(global_position.y/ROOM_HEIGHT_REAL)*ROOM_HEIGHT
#		topBound = closestRoomBoundary-ROOM_HEIGHT
#		bottomBound = closestRoomBoundary+ROOM_HEIGHT
		# print("Calculated closest boundary is "+String(closestRoomBoundary))
	#Causes extreme lag
	#property_list_changed_notify()

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		#print("changed position", position)
		set_bounds()
	update()

func _draw():
	if Engine.editor_hint:
		var rect = Rect2(leftBound, topBound, rightBound, bottomBound)
		
		if automatically_set_x_bounds:
			if facing == DOOR_IS_FACING.RIGHT:
				rect.position.x = global_position.x/CAMERA_SCALE
				rect.size.x = rect.position.x+ROOM_WIDTH
			else:
				rect.size.x = global_position.x/CAMERA_SCALE+1
				rect.position.x = rect.size.x-ROOM_WIDTH
		
		if rect.position.y == -999:
			rect.position.y = rect.size.y-ROOM_HEIGHT #floor(global_position.y/(ROOM_HEIGHT*CAMERA_SCALE))*ROOM_HEIGHT
		
		if rect.size.y == -999:
			rect.size.y = rect.position.y+ROOM_HEIGHT
		
		#print("Draw!")
		
		var leftBoundaryStart:Vector2 = to_local(rect.position*CAMERA_SCALE)
		leftBoundaryStart.x += 4
		var rightBoundaryStart:Vector2 = to_local(Vector2(rect.size.x,rect.position.y)*CAMERA_SCALE)
		rightBoundaryStart.x -= 4
		var boundaryEnd = to_local(rect.size*CAMERA_SCALE)
		#print(leftBoundaryStart)
		#print(boundaryEnd)

		#Left side
		draw_line(
			leftBoundaryStart,
			Vector2(leftBoundaryStart.x,boundaryEnd.y),
			Color.blueviolet,
			8,
			false
		)
		#Right side
		draw_line(
			rightBoundaryStart,
			Vector2(rightBoundaryStart.x,boundaryEnd.y),
			Color.darkmagenta,
			8,
			false
		)

func _ready():
	$Area2D.connect("body_entered",self,"move")
	if locked:
		lock_door()
	if Engine.editor_hint:
		set_notify_transform(true)

func move(obj):
	# I don't remember why this is checking but it's probably so
	# you can't clip through the door and activate the movement code below
	if locked:
		return
	elif obj.has_method("lockMovement"):
		obj.dash_time=0
		var cc = obj.get_node("Camera2D")
		
		if newMusic != null and newMusic != "":
			var music = load(newMusic)
			get_node("/root/Node2D/AudioStreamPlayer").stream = music;
			get_node("/root/Node2D/AudioStreamPlayer").play()

		#We don't want to overwrite leftBound,rightBound, etc so keep the changed variables in a new array.
		var boundsArray = [null,null,null,null]
		
		if automatically_set_x_bounds:
			if facing == DOOR_IS_FACING.LEFT:
				rightBound=global_position.x+64
				leftBound=rightBound-SCREEN_WIDTH
			else:
				leftBound=global_position.x
				rightBound=leftBound+SCREEN_WIDTH
		else:
			#Copying and pasting the same code twice is a great idea right?			
			if rightBound == -999:
				rightBound = leftBound*CAMERA_SCALE+SCREEN_WIDTH
			else:
				rightBound = rightBound*CAMERA_SCALE
				
			if leftBound == -999:
				leftBound = rightBound-SCREEN_WIDTH
			else:
				leftBound = leftBound*CAMERA_SCALE;
				#print("WARN: Left and right bounds are not defined. The camera won't work.")
		
		if bottomBound == -999:
			bottomBound = topBound*CAMERA_SCALE+SCREEN_HEIGHT
		elif bottomBound == -9999:
			bottomBound = cc.limit_bottom
		else:
			bottomBound = bottomBound*CAMERA_SCALE
		
		if topBound == -999:
			topBound = bottomBound-SCREEN_HEIGHT
		else:
			topBound = topBound*CAMERA_SCALE;
			
		print("LEFT: "+ String(leftBound)+ " TOP: "+String(topBound)+" RIGHT: "+String(rightBound) + " BOTTOM: "+String(bottomBound))
		obj.get_node("Camera2D").adjustCamera([leftBound,topBound,rightBound,bottomBound], tweenTime)
		
		#Lock player into walking right .5 seconds
		#$Sprite.piecesToDraw=0
		var seq := get_tree().create_tween()
		$Sound.play()
		
		seq.tween_property($Sprite,'piecesToDraw',0,.3)
		seq.tween_callback($Sound,"play").set_delay(.4)
		seq.tween_property($Sprite,'piecesToDraw',16,.3)
		
		#Apply gravity if they're on the floor so it plays the walking animation
		var gravity = 0
		if obj.is_on_floor():
			gravity = 200
		if boss_room_door:
			get_node("/root/Node2D").fadeMusic()
			
			obj.call("lockMovementQueue",[
				[.3,Vector2(0,0),"",true],
				[.8,Vector2(obj.run_speed*facing, gravity),"",true],
				[.3,Vector2(0,0),"",false]
			])
		else:
			obj.call("lockMovementQueue",[
				[.3,Vector2(0,0),"",true],
				[.4,Vector2(obj.run_speed*facing, gravity),"",true],
				[.3,Vector2(0,0),"",true]
			])
			
		emit_signal("player_entered_door")
		
#func _process(delta):
#	var time = 5/16;
	
func lock_door():
	$LockedDoor.set_collision_layer_bit(0,true)
	$Area2D.monitoring=false
	
func unlock_door():
	$LockedDoor.queue_free()
	$Area2D.monitoring=true
	locked=false
