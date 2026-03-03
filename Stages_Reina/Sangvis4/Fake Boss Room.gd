extends Node2D

onready var sprite:AnimatedSprite = $AnimatedSprite
onready var camera:Camera2D = $Camera2D
var player:KinematicBody2D
var root:Node2D

const CAMERA_SCALE = 64;
const ROOM_WIDTH = 20
const ROOM_HEIGHT = 12

func _ready():
	set_process(false)

func _input(event):
	if event is InputEventKey:
		if event.is_pressed() and event.scancode == KEY_KP_0:
			root = get_node("/root/Node2D/")
			player = root.get_player()
			if camera.current:
				set_process(false)
				root.get_player().get_camera().make_current()
			else:
				#set_process(true)
				copy_limits()
				camera.make_current()
		elif event.is_pressed() and event.scancode == KEY_KP_PERIOD:
			root = get_node("/root/Node2D/")
			player = root.get_player()
			execute()
				
	#if Input.is_key_pressed(KEY_KP_0):

func _process(delta):
	sprite.animation = player.sprite.animation
	sprite.frame = player.sprite.frame

func copy_limits():
	#This room is aligned to the center so we have to offset it
	#For some reason UMP9 is a bit higher than her real position so offset that too
	sprite.position = player.get_onscreen_pos() - Vector2(1280,720)/2 + Vector2(0,24)

	sprite.animation = player.sprite.animation
	sprite.frame = player.sprite.frame
	sprite.flip_h = player.sprite.flip_h
	
	var player_cam:Camera2D = root.get_player().get_camera()
	#We just have to take the X-axis limits and align it to this room
	#var leftBound = int(floor(global_position.x/CAMERA_SCALE/ROOM_WIDTH)*ROOM_WIDTH)
	var leftBound = 200*CAMERA_SCALE
	var rightBound = leftBound+1280
	camera.limit_left = leftBound
	camera.limit_right = rightBound
	camera.limit_top = player_cam.limit_top
	camera.limit_bottom = player_cam.limit_bottom

func execute():
	root = get_node("/root/Node2D/")
	player = root.get_player()
	player.finishStage()
	
	copy_limits()
	camera.make_current()
	var tw = create_tween()
	tw.tween_property(self,"rotation_degrees", -180,3).from(0.0).set_trans(Tween.TRANS_QUAD)
	#We have to translate the player position
	var rotated_pos = transform.xform(sprite.position)
	tw.tween_property(sprite,"visible",false,0.0)
	tw.tween_property(player,"position",rotated_pos,0.0)
	
	tw.tween_callback(self,"exec_2")
	#tw.tween_callback(player,)

func exec_2():
	$CustomEventTile.execute()
	player.lockMovementQueue([[
		9999.0,
		Vector2(0, 0),
		"Falling",
		false
	]])
