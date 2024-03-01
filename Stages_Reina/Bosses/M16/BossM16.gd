extends "res://Stages_Reina/Bosses/BossBase.gd"

enum STATES {
	IDLE,
	RAGING_DEMON_START,
	RAGING_DEMON
}
var current_state = STATES.RAGING_DEMON_START

var player:KinematicBody2D
var cooldown:float=0.0

onready var rayCast:RayCast2D = $RayCast2D
onready var a1 = get_node("AnimatedSprite/AfterImage1")
onready var a2 = get_node("AnimatedSprite/AfterImage2")
onready var a3 = get_node("AnimatedSprite/AfterImage3")
var oldPositions:PoolVector2Array = PoolVector2Array()

func _ready():
	oldPositions.resize(6)
	a1.visible=false
	a2.visible=false
	a3.visible=false
	
	$Heaven.connect("finished",self,"raging_demon_fin")

func update_after_image():
	var t = sprite.frames.get_frame(sprite.get_animation(), sprite.frame)
	var f = sprite.flip_h
	#var p = 1 if f else -1
	#var i = 0
	oldPositions[5] = position
	for i in range(5):
		oldPositions[i] = oldPositions[i+1]
		#i+=1
	a1.texture = t
	a2.texture = t
	a3.texture = t

	a1.flip_h = f
	a2.flip_h = f
	a3.flip_h = f

	a1.position=oldPositions[4]-position
	a2.position=oldPositions[3]-position
	a3.position=oldPositions[2]-position

func _physics_process(delta):
	if not enabled:
		if player==null: #TODO: This should probably be in the base class
			player=get_node("/root/Node2D/").get_player()
		return
	elif cooldown >=0:
		cooldown-=delta
		return
	
	sprite.flip_h = (facing==DIRECTION.LEFT)
	
	match current_state:
		STATES.RAGING_DEMON_START:
			a1.visible = true
			a2.visible = true
			a3.visible = true
			
			if player.global_position.x > global_position.x:
				facing = DIRECTION.RIGHT
			rayCast.cast_to = Vector2(facing*25,0)
			rayCast.enabled = true
			sprite.animation = "Falling"
			sprite.playing=false
			current_state = STATES.RAGING_DEMON
		STATES.RAGING_DEMON:
			update_after_image()
			
			if rayCast.is_colliding():
				player.sprite.play("Hurt")
				sprite.animation="Grenade"
				sprite.frame=2
				$Heaven.raging_demon(player)
				cooldown=INF
			else:
				var velocity=Vector2(400.0*facing,5)
				move_and_slide(velocity,Vector2(0,-1),true)

func raging_demon_fin():
	a1.visible = false
	a2.visible = false
	a3.visible = false
	sprite.play("RagingDemon")
