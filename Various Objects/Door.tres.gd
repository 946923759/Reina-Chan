extends Node2D
signal player_entered_door()

export (bool) var automatically_set_x_bounds = true
export (bool) var boss_room_door = false
export (bool) var locked = false
export (int) var leftBound;
export (int) var topBound;
export (int) var rightBound;
export (int) var bottomBound;
export (float) var cameraScale = 64.0;
export (float) var tweenTime = .5;
export(AudioStream) var newMusic

enum DOOR_IS_FACING {
	LEFT = -1,
	RIGHT = 1
}
export (DOOR_IS_FACING) var facing = DOOR_IS_FACING.RIGHT

func _ready():
	$Area2D.connect("body_entered",self,"move")
	if locked:
		$LockedDoor.set_collision_layer_bit(0,true)
		$Area2D.monitoring=false
	
	
func move(obj):
	if obj.has_method("lockMovement"):
		obj.dash_time=0
		if newMusic != null and newMusic != "":
			var music = load(newMusic)
			get_node("/root/Node2D/AudioStreamPlayer").stream = music;
			get_node("/root/Node2D/AudioStreamPlayer").play()

		if automatically_set_x_bounds:
			if facing == DOOR_IS_FACING.LEFT:
				rightBound=global_position.x+64
				leftBound=rightBound-Globals.gameResolution.x
			else:
				leftBound=global_position.x
				rightBound=leftBound+Globals.gameResolution.x
		else:
			#Copying and pasting the same code twice is a great idea right?			
			if rightBound == -999:
				rightBound = leftBound*cameraScale+Globals.gameResolution.x
			else:
				rightBound = rightBound*cameraScale
				
			if leftBound == -999:
				leftBound = rightBound-Globals.gameResolution.x
			else:
				leftBound = leftBound*cameraScale;
				#print("WARN: Left and right bounds are not defined. The camera won't work.")
		
		if bottomBound == -999:
			bottomBound = topBound*cameraScale+Globals.gameResolution.y
		else:
			bottomBound = bottomBound*cameraScale
		topBound = topBound*cameraScale;
		print("LEFT: "+ String(leftBound)+ " TOP: "+String(topBound)+" RIGHT: "+String(rightBound) + " BOTTOM: "+String(bottomBound))
		get_node("/root/Node2D/").get_player().get_node("Camera2D").adjustCamera([leftBound,topBound,rightBound,bottomBound], tweenTime)
		
		#Lock player into walking right .5 seconds
		#$Sprite.piecesToDraw=0
		var seq := get_tree().create_tween()
		$Sound.play()
		
		seq.tween_property($Sprite,'piecesToDraw',0,.3)
		seq.tween_callback($Sound,"play").set_delay(.4)
		seq.tween_property($Sprite,'piecesToDraw',16,.3)
		if boss_room_door:
			get_node("/root/Node2D").fadeMusic()
			obj.call("lockMovementQueue",[
				[.3,Vector2(0,0)],
				[.8,Vector2(obj.run_speed*facing,0),"",false],
				[.3,Vector2(0,0),"Idle"]
			])
		else:
			obj.call("lockMovementQueue",[
				[.3,Vector2(0,0)],
				[.5,Vector2(obj.run_speed*facing,0),"",false],
				[.3,Vector2(0,0),"Idle"]
			])
			
		emit_signal("player_entered_door")
		
#func _process(delta):
#	var time = 5/16;
	
func unlock_door():
	$LockedDoor.queue_free()
	$Area2D.monitoring=true
