extends Node2D

export (bool) var automatically_set_x_bounds = true
export (bool) var boss_room_door = false
export (int) var leftBound;
export (int) var topBound;
export (int) var rightBound;
export (int) var bottomBound;
export (float) var cameraScale = 64;
export (float) var tweenTime = .5;
export(String, FILE, "*.ogg") var newMusic

func _ready():
	$Area2D.connect("body_entered",self,"move")
	
	
func move(obj):
	if obj.has_method("lockMovement"):
		if newMusic != null and newMusic != "":
			var music = load(newMusic)
			get_node("/root/Node2D/AudioStreamPlayer").stream = music;
			get_node("/root/Node2D/AudioStreamPlayer").play()

		if automatically_set_x_bounds:
			leftBound=position.x
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
		get_node("/root/Node2D/Player/Camera2D").adjustCamera([leftBound,topBound,rightBound,bottomBound], tweenTime)
		
		#Lock player into walking right .5 seconds
		$Sprite.set_process(true)
		#$Sprite.piecesToDraw=0
		var seq := TweenSequence.new(get_tree())
		$Sound.play()
		seq.append($Sprite,'piecesToDraw',0,.3)
		seq.append($Sprite,'piecesToDraw',0,.4)
		seq.append_callback($Sound,"play")
		seq.append($Sprite,'piecesToDraw',16,.3)
		seq.connect("finished",$Sprite,"set_process",[false])
		if boss_room_door:
			get_node("/root/Node2D").fadeMusic()
			obj.call("lockMovementQueue",[
				[.3,Vector2(0,0)],
				[.8,Vector2(obj.run_speed,0),"",false],
				[.3,Vector2(0,0),"Idle"]
			])
		else:
			obj.call("lockMovementQueue",[
				[.3,Vector2(0,0)],
				[.5,Vector2(obj.run_speed,0),"",false],
				[.3,Vector2(0,0),"Idle"]
			])
		
#func _process(delta):
#	var time = 5/16;
	
