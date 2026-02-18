extends KinematicBody2D
signal boss_killed()

#-1 to move left, 1 to move right
enum DIRECTION {LEFT = -1, RIGHT = 1}
export(DIRECTION) var facing = DIRECTION.LEFT
var lastTouched
var enabled:bool = false

#Why isn't this customizable?
var health:int = 28 #All bosses in mega man have 28 health.
const MAX_HP = 28

var is_reflecting:bool=false

onready var sprite:AnimatedSprite = $AnimatedSprite
onready var HPBar = $CanvasLayer/bar
onready var hurtSound = $HurtSound

#This is only if you didn't override objectTouched!
#There might be cases where you need to override it.
export(int,0,25) var player_damage = 1

export(PoolRealArray) var weaponDamageMultiplier = [
	1.0,
	1.0,
	1.0,
	1.0,
	1.0,
	1.0,
	1.0,
	1.0
]
#export(Array, float,"a","b","c") var weaponDamageMultiplier = [1.0,1.0,1.0]

export(String) var intro_subtitle_key = "Architect_Intro"
# What's the point of this when the boss room handler has to reset the music and player position anyways?
# Just in case there is no boss room handler? Ok
export(bool) var stage_finished_when_killed = true
export(bool) var resume_music_after_killed:bool = true
export(int,-1,15) var set_temp_bitflag_when_boss_dies = -1

var deathAnimation = preload("res://Animations/deathAnimation.tscn")

const CAMERA_SCALE = 64;
const ROOM_WIDTH = 20
const ROOM_HEIGHT = 12
#This is real global position, not block position!
var CLOSEST_ROOM_BOUND:Vector2

#export(Vector2) var room_bound_offset = Vector2(0,0)
# Returns real pixel position, not rounded to nearest block!
# Note that get/set only works if another class calls it for some insane reason,
# so using this in your inherited class will have no effect.
# Use get_room_position() instead
var room_position:Vector2 setget set_room_position,get_room_position

func get_room_position()->Vector2:
	return global_position-CLOSEST_ROOM_BOUND

func set_room_position(v:Vector2):
	global_position=CLOSEST_ROOM_BOUND+v


func get_room_position_of_node(o:Node2D)->Vector2:
	return o.global_position - CLOSEST_ROOM_BOUND

func _ready():
	sprite.set_animation("default")
	sprite.flip_h = (facing == DIRECTION.RIGHT)
	
	if get_parent().get_parent().is_class("Node2D"):
		CLOSEST_ROOM_BOUND = get_parent().get_parent().global_position
	else:
		printerr(get_parent().get_parent()," is not Node2D type!!!")
	#print("[BossBase] Closest room is "+String(CLOSEST_ROOM_BOUND/CAMERA_SCALE)+", real pos "+String(CLOSEST_ROOM_BOUND))

	if Engine.editor_hint:
		set_physics_process(false)
		set_process(false)
	else:
		# warning-ignore:return_value_discarded
		$Area2D.connect("body_entered",self,"objectTouched")
		# warning-ignore:return_value_discarded
		$Area2D.connect("body_exited",self,"clearLastTouched")
		# warning-ignore:return_value_discarded
		#Absolutely kicking myself for not using the enemy base script right now
		# warning-ignore:return_value_discarded
		$Area2D.connect("area_entered",self,"areaTouched")

onready var introSound:AudioStreamPlayer=$IntroSound

func playIntro(playSound=true,showHPbar=true)->AudioStreamPlayer:
	sprite.play("intro")
	if showHPbar:
		var seq := get_tree().create_tween()
		#HPBar.set_process(true)
		seq.tween_property(HPBar,"position:x",1235,.1)
# warning-ignore:return_value_discarded
		seq.tween_property(HPBar,"health",1,1.5)
# warning-ignore:return_value_discarded
		seq.tween_callback(HPBar,"set_process",[false])
	if playSound:
		introSound.play()
	return introSound
	#1235
	#$AudioStreamPlayer.connect("finished",callback,)

#var is_on_floor_:bool
#The duration that the sprite has been colored white.
var whiteTime = 0

# warning-ignore:unused_argument
func _physics_process(delta):

	#This aligns the boss with the floor for her intro, but
	#only when she's not enabled.
	if not enabled: 
# warning-ignore:return_value_discarded
		move_and_slide(Vector2(0,200))
	else:
		if whiteTime > 0: #Have to check becuase shaders might get swapped out...
			whiteTime -= delta
			if whiteTime <= 0:
				sprite.use_parent_material = true

func objectTouched(obj):
	#print("intersecting!")
	if obj.has_method("player_touched"): #If enemy touched player
		lastTouched = obj
		obj.call("player_touched",self,player_damage)
	elif obj.has_method("enemy_touched"): #If enemy touched bullet
		obj.call("enemy_touched",self)

#Assume areas are bullets only, since players have a collision box
func areaTouched(obj):
	objectTouched(obj.get_parent())

func clearLastTouched(_obj):
	lastTouched=null

#We want an isAlive var so we can play the death animation only one time
var isAlive = true
func damage(amount,damageType:int=0):
	#It turns out the boss can be shot through the walls sometimes
	#so make sure you can't shoot it until it's enabled lol
	if !enabled:
		return
	health -= amount
	#print("Took damage!")
	if health <= 0:
		if isAlive:
			die()
	else:
		#set false so the white tint shader will show up.
		hurtSound.play()
		sprite.use_parent_material = false
		whiteTime = .1
		#print(health/28.0)
		HPBar.updateHP(health/28.0)
		
func die():
	print(self.name+" queued to be killed.")
	HPBar.updateHP(0)
	isAlive = false

	collision_layer=0
	collision_mask=0
	$Area2D.set_deferred("monitoring",false)
	$Area2D.set_deferred("monitorable",false)
	set_physics_process(false)
	
	sprite.visible = false
	sprite.stop()
	
	$DieSound.play()
	var sp = deathAnimation.instance()
	sp.position=position
	get_parent().add_child(sp)
	#dropRandomItem()
	
	#self.queue_free()
	if set_temp_bitflag_when_boss_dies >= 0:
		CheckpointPlayerStats.temporaryStageStats |= (1<<set_temp_bitflag_when_boss_dies)
	
	if stage_finished_when_killed:
		emit_signal("boss_killed")
		var player = get_node("/root/Node2D").get_player()
		player.finishStage()
		#.lockMovement(999,Vector2())
		#get_node("/root/Node2D/VictorySound").play()
	else:
		HPBar.visible=false
		yield($DieSound,"finished")
		emit_signal("boss_killed")
		self.queue_free()
		if resume_music_after_killed:
			get_node("/root/Node2D").playMusic_2()
