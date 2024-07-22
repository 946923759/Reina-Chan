tool
extends Area2D
signal camera_adjusted(camera,newBounds)

enum AUTO_ADJUST {
	MANUAL = 0,
	DOWN_1,
	RIGHT_1,
	LEFT_1,
}
export (int,"Manual","1 Room Down (Top Aligned)","1 Room Right (Changes X Axis Only)", "1 Room Left (Changes X Axis Only)") var auto_adjust_bounds=0 setget auto_set_bounds

export (int) var leftBound = 0;
export (int) var topBound = 0;
export (int) var rightBound = 0;
export (int) var bottomBound = 0;

export (float) var tweenTime = 1.0;
export (bool) var freeze_player_during_transition=false
export (int,"Left","Right","Down","Up") var frozen_movement_direction=2 
export (bool) var never_disable=false
export (int,"No Warp","Relative","Absolute") var warp_type = 0;
export (Vector2) var destination_coordinates_if_warp=Vector2(0,-2.5);
#export(Shape2D) var shape;

const DO_NOT_ADJUST = -9998
const AUTOMATIC_BASED_ON_OTHER_SIDE = -999
const AUTOMATIC_BASED_ON_THIS_OBJ = -9999

const CAMERA_SCALE = 64;
const ROOM_WIDTH = 20
const ROOM_HEIGHT = 12

func auto_set_bounds(t:int):
	auto_adjust_bounds = t
	
	#Godot glitches out if it's false and it's false when switching tabs
	if !is_inside_tree():
		return
	
	#Rounded to nearest room borders
	if t == AUTO_ADJUST.RIGHT_1:
		leftBound = int(round(global_position.x/CAMERA_SCALE/ROOM_WIDTH)*ROOM_WIDTH)
		rightBound = leftBound+ROOM_WIDTH
		topBound = DO_NOT_ADJUST
		bottomBound = DO_NOT_ADJUST
	elif t == AUTO_ADJUST.LEFT_1:
		rightBound = int(floor(global_position.x/CAMERA_SCALE/ROOM_WIDTH)*ROOM_WIDTH)
		leftBound = rightBound-ROOM_WIDTH
		topBound = DO_NOT_ADJUST
		bottomBound = DO_NOT_ADJUST
	elif t == AUTO_ADJUST.DOWN_1:
		topBound = int(round(global_position.y/CAMERA_SCALE/ROOM_HEIGHT)*ROOM_HEIGHT)
		bottomBound = AUTOMATIC_BASED_ON_OTHER_SIDE
		leftBound = int(floor(global_position.x/CAMERA_SCALE/ROOM_WIDTH)*ROOM_WIDTH)
		rightBound = leftBound+ROOM_WIDTH

	
#	if t >= AUTO_ADJUST.X_ONLY:
#		leftBound = int(floor(global_position.x/CAMERA_SCALE/ROOM_WIDTH)*ROOM_WIDTH)
#		rightBound = leftBound+ROOM_WIDTH
#		#print("Calculated x="+String(leftBound))
#	if t == AUTO_ADJUST.X_AND_Y:
#		#topBound = 
#		# 768
#		var ROOM_HEIGHT_REAL = CAMERA_SCALE*ROOM_HEIGHT
#		var closestRoomBoundary = round(global_position.y/ROOM_HEIGHT_REAL)*ROOM_HEIGHT
#		topBound = closestRoomBoundary-ROOM_HEIGHT
#		bottomBound = closestRoomBoundary+ROOM_HEIGHT
		# print("Calculated closest boundary is "+String(closestRoomBoundary))
	update()

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		#print("changed position", position)
		auto_set_bounds(auto_adjust_bounds)

func _draw():
	if Engine.editor_hint:
		var rect = Rect2(leftBound, topBound, rightBound, bottomBound)
		
		#var ROOM_HEIGHT_REAL = CAMERA_SCALE*ROOM_HEIGHT
		if rect.position.x == -999: #Autocalc based on right bound
			rect.position.x = rect.size.x-ROOM_WIDTH
		elif rect.position.x == -9999:
			rect.position.x = rect.size.x-ROOM_WIDTH
			#rect.x = round(global_position.y/(ROOM_WIDTH*CAMERA_SCALE))*ROOM_WIDTH
		
		if rect.position.y == -9999 or rect.position.y == DO_NOT_ADJUST:
			rect.position.y = floor(global_position.y/(ROOM_HEIGHT*CAMERA_SCALE))*ROOM_HEIGHT
		elif rect.position.y == -999:
			rect.position.y = rect.size.y-ROOM_HEIGHT #floor(global_position.y/(ROOM_HEIGHT*CAMERA_SCALE))*ROOM_HEIGHT
		
		if rect.size.y == AUTOMATIC_BASED_ON_THIS_OBJ or rect.size.y == DO_NOT_ADJUST:
			rect.size.y = ceil(global_position.y/(ROOM_HEIGHT*CAMERA_SCALE))*ROOM_HEIGHT
		elif rect.size.y == AUTOMATIC_BASED_ON_OTHER_SIDE:
			rect.size.y = rect.position.y+ROOM_HEIGHT
		
		
		var leftBoundaryStart:Vector2 = to_local(rect.position*CAMERA_SCALE)
		leftBoundaryStart.x += 4
		var rightBoundaryStart:Vector2 = to_local(Vector2(rect.size.x,rect.position.y)*CAMERA_SCALE)
		rightBoundaryStart.x -= 4
		var boundaryEnd = to_local(rect.size*CAMERA_SCALE)
		#print(leftBoundaryStart)
		#print(boundaryEnd)

		draw_line(
			leftBoundaryStart,
			Vector2(leftBoundaryStart.x,boundaryEnd.y),
			Color.cyan,
			8,
			false
		)
		draw_line(
			rightBoundaryStart,
			Vector2(rightBoundaryStart.x,boundaryEnd.y),
			Color.green,
			8,
			false
		)
		# if leftBound != 999 and leftBound != 9999:
			
#		if topBound != 999 and topBound != 9999:
#			var topBoundaryStart = to_local(Vector2(topBound*CAMERA_SCALE,global_position.y*CAMERA_SCALE))
#			var bottomBoundaryStart = to_local(Vector2(bottomBound*CAMERA_SCALE,global_position.y*CAMERA_SCALE))
#		var ladderBoundaryStart = to_local(Vector2(leftBound*CAMERA_SCALE,global_position.y+center_bound_offset*CAMERA_SCALE))
#		var ladderBoundaryEnd = to_local(Vector2(rightBound*CAMERA_SCALE,global_position.y+center_bound_offset*CAMERA_SCALE))
#		#print("Drawing from "+String(ladderBoundaryStart)+" to "+String(ladderBoundaryEnd))
#		draw_line(ladderBoundaryStart,ladderBoundaryEnd,Color.chartreuse,4,false)
#
#		if bottomBound == -999 or topBound == -999:
#			return
#
#		var leftSide = to_local(Vector2(leftBound,topBound)*CAMERA_SCALE)
#		var rightSide = to_local(Vector2(rightBound,topBound)*CAMERA_SCALE)
#		#var bottomSide = to_local(Vector2(leftBound,bottomBound)*CAMERA_SCALE)
#
#		draw_line(
#			leftSide,
#			to_local(Vector2(leftBound,bottomBound)*CAMERA_SCALE),
#			Color.chartreuse,4
#		)
#		draw_line(
#			rightSide,
#			to_local(Vector2(rightBound,bottomBound)*CAMERA_SCALE),
#			Color.chartreuse,4
#		)


func _ready():
	#The shape to trigger the camera. If the assertion is failing, the camera can't be triggered so it's useless.
	#In other words, give your camera controller a shape! It's somewhere in your stage!
	#assert(shape)
	#if OS.is_debug_build():
	#	self.get_node("CollisionShape2D").set_shape(shape)
	#self.shape_owner_add_shape(self.create_shape_owner(self), shape)
# warning-ignore:return_value_discarded
	self.connect("body_entered",self,"cam")

#func _process(delta):
#	if Engine.editor_hint and shape != null:
#		self.get_node("CollisionShape2D").set_shape(shape)

var disabled = false
func cam(obj):
	if obj.has_method("player_touched") and not disabled:
		disabled = !never_disable
		var cc = get_node("/root/Node2D/").get_player().get_node("Camera2D")
		print("Touched camera trigger at "+String(self.global_position))
		
		#We don't want to overwrite leftBound,rightBound, etc so keep the changed variables in a new array.
		var boundsArray = [null,null,null,null]
		if rightBound == -999:
			boundsArray[2] = leftBound*CAMERA_SCALE+Globals.gameResolution.x
		else:
			boundsArray[2] = rightBound*CAMERA_SCALE
			
		if leftBound == -999:
			boundsArray[0] = rightBound*CAMERA_SCALE-Globals.gameResolution.x
		elif leftBound == -9999: #Change the left bound to the current right bound. Basically move right exactly 1 room.
			boundsArray[0] = cc.limit_right
		else:
			boundsArray[0] = leftBound*CAMERA_SCALE;
			#print("WARN: Left and right bounds are not defined. The camera won't work.")
		
		if bottomBound == -999:
			boundsArray[3] = topBound*CAMERA_SCALE+Globals.gameResolution.y
		elif bottomBound == DO_NOT_ADJUST:
			boundsArray[3] = cc.limit_bottom
		else:
			boundsArray[3] = bottomBound*CAMERA_SCALE
			
		if topBound == -999:
			boundsArray[1] = bottomBound*CAMERA_SCALE-Globals.gameResolution.y
		elif bottomBound == DO_NOT_ADJUST:
			boundsArray[1] = cc.limit_top
		else:
			boundsArray[1] = topBound*CAMERA_SCALE;
		
		assert(boundsArray[0] < boundsArray[2]);
		assert(boundsArray[1] < boundsArray[3]);
		print("LEFT: "+ String(boundsArray[0])+ " TOP: "+String(boundsArray[1])+" RIGHT: "+String(boundsArray[2]) + " BOTTOM: "+String(boundsArray[3]))
		if warp_type > 0:
			
			if tweenTime > 0:
				var oldVelocity=obj.velocity
				print(oldVelocity)
				obj.lockMovement(tweenTime,Vector2(0,0))
				var CL = obj.get_node("CanvasLayer");
				print("fading out...")
				var t:SceneTreeTween = CL.get_node("Fadeout").fadeOut()
				yield(t,"finished")
				#yield(CL.get_node("Fadeout/Fadeout_Tween"),"tween_completed")
				if warp_type==1:
					print("Warped to "+String(obj.pos2cell(obj.position)+destination_coordinates_if_warp))
					obj.position = obj.cell2pos(obj.pos2cell(obj.position)+destination_coordinates_if_warp)
				elif warp_type==2:
					print("Warped to "+String(obj.cell2pos(destination_coordinates_if_warp)))
					obj.position = obj.cell2pos(destination_coordinates_if_warp)
				print("fading in..")
				obj.velocity=Vector2(0,10000)
				CL.get_node("Fadeout").fadeIn()
				cc.adjustCamera(boundsArray, 0)
			else:
				if warp_type == 1:
					obj.position += destination_coordinates_if_warp*CAMERA_SCALE
				cc.adjustCamera(boundsArray, 0)
			return
		elif freeze_player_during_transition:
			if frozen_movement_direction==0:
				obj.lockMovement(tweenTime,Vector2(-100,0))
			elif frozen_movement_direction==1:
				obj.lockMovement(tweenTime,Vector2(100,0))
			elif frozen_movement_direction==2:
				obj.lockMovement(tweenTime,Vector2(0,100))
			elif frozen_movement_direction==3:
				obj.lockMovement(tweenTime,Vector2(0,-100))
		cc.adjustCamera(boundsArray, tweenTime)
		emit_signal("camera_adjusted",cc,boundsArray)

func enable():
	disabled=false

func enable_2(_discard, _discard2):
	disabled=false
