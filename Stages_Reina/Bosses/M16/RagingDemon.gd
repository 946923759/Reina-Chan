extends CanvasLayer
signal finished()

var explosion = preload("res://Stages/EnemyExplodeSmall.tscn")
var player
onready var stageRoot = get_node("/root/Node2D/")

func _ready():
	set_process(false)
	self.visible = false

func raging_demon(obj):
	if obj.has_method("player_touched"):
		player=obj
		player.invincible=true
		player.lockMovementQueue([
			[0,Vector2(0,0),"Hurt",true],
			[999,Vector2(0,0),"Hurt",true]
		])
		player.get_node("CanvasLayer/Fadeout").fadeOut(.3)
		set_process(true)
		
		#device, weak magnitude, strong magnitude, duration
		Input.start_joy_vibration(0, .5, .5, 5)

		#Input.vibrate_handheld()
		#func lockMovement(time:float,velocity:Vector2,freeze_y_velocity:bool=true):
		
var delay=.3
var limit = 15
func _process(delta):
	delay-=delta
	if limit==0:
		visible = true
		#TODO: Don't always kill player!
		player.die()

		$KO.play()
		$Fire.play()
		#var h = heaven.instance()
		#player.add_child(h)
		player.get_node("CanvasLayer/Fadeout").modulate.a=0.0
		set_process(false)
		emit_signal("finished")
	elif delay<=0:
		limit-=1
		delay=.1
		var e = explosion.instance()
		e.z_index=100
		e.position = stageRoot.position + player.position + stageRoot.get_canvas_transform().origin
		e.position+=Vector2(randi()%40-20,randi()%60-30)
		
		player.get_node("CanvasLayer").add_child(e)
		e.sound.volume_db=-999
		$Explosion.play()
