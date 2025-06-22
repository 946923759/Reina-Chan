extends CanvasLayer
signal finished()

var explosion = preload("res://Stages/EnemyExplodeSmall.tscn")

var player:KinematicBody2D #This is just to control the fade out
var obj:KinematicBody2D

onready var stageRoot = get_node("/root/Node2D/")

func _ready():
	set_process(false)
	self.visible = false

func raging_demon(obj):
	self.obj = obj
	player=stageRoot.get_player()
	player.get_node("CanvasLayer/Fadeout").fadeOut(.3)
	set_process(true)
	
	
var delay=.3
var limit = 15
func _process(delta):
	delay-=delta
	if limit==0:
		#visible = true
		obj.die()
		$Fire.play()
		player.get_node("CanvasLayer/Fadeout").modulate.a=0.0
		set_process(false)
		emit_signal("finished")
	elif delay<=0:
		limit-=1
		delay=.1
		var e = explosion.instance()
		e.z_index=100
		#e.position = stageRoot.position + obj.position + stageRoot.get_canvas_transform().origin
		e.global_position = obj.global_position + stageRoot.get_canvas_transform().origin
		e.position+=Vector2(randi()%40-20,randi()%60-30)
		
		player.get_node("CanvasLayer").add_child(e)
		e.sound.volume_db=-999
		$Explosion.play()
