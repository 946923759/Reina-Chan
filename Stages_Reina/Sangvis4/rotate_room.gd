extends Node2D

export(NodePath) var tilemap_node_path
onready var tilemap:Node2D = get_node(tilemap_node_path)

export (int) var leftBound = 0;
export (int) var topBound = 0;
export (int) var rightBound;
export (int) var bottomBound;
export (Vector2) var destination_room_relative_position

onready var root = get_node("/root/Node2D")

func teleport_1(player):
	
	#unfortunately I didn't study in physics class so I
	#don't know how to calculate the exact time she reaches
	#her maximum height
	var goTowards = -300 if player.position.x > 640 else 300
	player.lockMovementQueue([
		[0,Vector2(0,0)], #I don't know why I made the 0th slot ignore animations... I should fix that
		[.4,Vector2(goTowards, player.jump_speed),"Falling",false],
		[2.6,Vector2(0,0),"Falling",true]
	])
	#return

	var seq := create_tween()
	seq.tween_property(tilemap,'rotation_degrees',180,3).set_trans(Tween.TRANS_QUAD)
	#device, weak magnitude, strong magnitude, duration
	Input.start_joy_vibration(0,.5,.6,3)

	seq.tween_callback(self,"teleport_2",[player])
	
func teleport_2(player):
	var cc = player.get_node("Camera2D")
	#LEFT,TOP,RIGHT,BOTTOM
	#cc.adjustCamera([-99999,-99999,99999,99999],0)
	cc.adjustCamera([leftBound*64,topBound*64,rightBound*64,bottomBound*64], 0)
	#var dest = (destination_room-current_room)
	#print("Teleported to"+String(dest))
	#The scale size is 64 and there are 20 blocks, so width is 1280
	#Additionally, the height is 12 blocks so 64*12
	player.position+=Vector2(destination_room_relative_position.x*1280,destination_room_relative_position.y*64*12)
