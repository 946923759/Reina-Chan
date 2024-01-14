#tool
extends Area2D
signal camera_adjusted(camera,newBounds)
#export (Array, int) var newBounds;
#asdadsadaddsa
export (int) var leftBound = 0;
export (int) var topBound = 0;
export (int) var rightBound = 0;
export (int) var bottomBound = 0;
export (float) var cameraScale = 64.0;
export (float) var tweenTime = 1.0;
export (bool) var freeze_player_during_transition=false
export (int,"Left","Right","Down","Up") var frozen_movement_direction=2 
export (bool) var never_disable=false
export (int,"No Warp","Relative","Absolute") var warp_type = 0;
export (Vector2) var destination_coordinates_if_warp=Vector2(0,-2.5);
#export(Shape2D) var shape;

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
		
		if bottomBound == -999:
			boundsArray[3] = topBound*cameraScale+Globals.gameResolution.y
		else:
			boundsArray[3] = bottomBound*cameraScale
			
		if topBound == -999:
			boundsArray[1] = bottomBound*cameraScale-Globals.gameResolution.y
		else:
			boundsArray[1] = topBound*cameraScale;
		
		assert(boundsArray[0] < boundsArray[2]);
		assert(boundsArray[1] < boundsArray[3]);
		print("LEFT: "+ String(boundsArray[0])+ " TOP: "+String(boundsArray[1])+" RIGHT: "+String(boundsArray[2]) + " BOTTOM: "+String(boundsArray[3]))
		if warp_type > 0:
			
			if tweenTime > 0:
				var oldVelocity=obj.velocity
				print(oldVelocity)
				obj.lockMovement(tweenTime,Vector2(0,0))
				var CL = obj.get_node("CanvasLayer");
				CL.get_node("Fadeout").fadeOut()
				yield(CL.get_node("Fadeout/Fadeout_Tween"),"tween_completed")
				if warp_type==1:
					print("Warped to "+String(obj.pos2cell(obj.position)+destination_coordinates_if_warp))
					obj.position = obj.cell2pos(obj.pos2cell(obj.position)+destination_coordinates_if_warp)
				elif warp_type==2:
					print("Warped to "+String(obj.cell2pos(destination_coordinates_if_warp)))
					obj.position = obj.cell2pos(destination_coordinates_if_warp)
				#print("fading in..")
				obj.velocity=Vector2(0,10000)
				CL.get_node("Fadeout").fadeIn()
				cc.adjustCamera(boundsArray, 0)
			else:
				if warp_type == 1:
					obj.position += destination_coordinates_if_warp*cameraScale
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
