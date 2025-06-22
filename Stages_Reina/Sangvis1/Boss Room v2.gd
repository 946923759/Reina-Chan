extends Node2D

var ROOM_HEIGHT = 12
var CAMERA_SCALE = 64

export(float, 100, 500, 10) var speed = 100.0
#var first_run = true
var camera_rect = Rect2(0, 0.0, 1280, ROOM_HEIGHT*CAMERA_SCALE)
#var player_camera_top:float = 0.0
#var y_position:float = 0.0
var players:Array

onready var platforms = $Platforms

#func _draw():
#	draw_rect(camera_rect,Color.red,false,10.0)

func _ready():
	set_process(false)
#	update()

func _process(delta):
	camera_rect.position.y -= delta*speed
	$Node2D.position.y -= delta*speed
	
	for p in players:
		var camera:Camera2D = p.get_node("Camera2D")
		#Camera limits are ints, not floats.
		#So we have to save to a seperate value and then
		#assign this value to the limits
		var lim_top = to_global(camera_rect.position)
		camera.limit_top = lim_top.y
		camera.limit_bottom = camera.limit_top+720

	for c in platforms.get_children():
		if c.position.y > camera_rect.position.y + camera_rect.size.y:
			c.position.y -= ROOM_HEIGHT*CAMERA_SCALE
	update()
	pass


func _on_PlayerTeleporter_player_teleported(new_player_position):
	#print(new_player_position)
	for c in platforms.get_children():
		c.position.y += ROOM_HEIGHT*CAMERA_SCALE*2
	camera_rect.position.y += ROOM_HEIGHT*CAMERA_SCALE*2
	$Node2D.position.y += ROOM_HEIGHT*CAMERA_SCALE*2
		
	#for p in players:
	#	var camera:Camera2D = p.get_node("Camera2D")
	#	camera.limit_bottom += 720
	#	camera.limit_top += 720


func _on_CameraAdjuster_Warp_player_teleported(new_player_position):
	get_parent().playBossMusic()
	players = get_parent().get_all_players()
	var tw:SceneTreeTween = create_tween()
	tw.tween_callback(self,"set_process",[true]).set_delay(1)
	#set_process(true)
	#player_camera_top


func _on_FishBoss_enemy_destroyed():
	set_process(false)
	for p in players:
		p.finishStage()
	pass # Replace with function body.
