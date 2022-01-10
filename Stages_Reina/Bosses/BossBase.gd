extends KinematicBody2D
signal boss_killed()

#-1 to move left, 1 to move right
enum DIRECTION {LEFT = -1, RIGHT = 1}
export(DIRECTION) var facing = DIRECTION.LEFT
var lastTouched
var enabled:bool = false
var curHP:int = 28 #All bosses in mega man have 28 health.
onready var sprite = $AnimatedSprite
onready var HPBar = $CanvasLayer/bar
onready var hurtSound = $HurtSound

#This is only if you didn't override objectTouched!
#There might be cases where you need to override it.
export(int,0,25) var player_damage = 1

export(String) var intro_subtitle_key = "Architect_Intro"
export(bool) var stage_finished_when_killed = true

#var rocket = preload("res://Stages_Reina/Bosses/Architect/ArchiRocket.tscn")
var deathAnimation = preload("res://Animations/deathAnimation.tscn")

func _ready():
# warning-ignore:return_value_discarded
	$Area2D.connect("body_entered",self,"objectTouched")
# warning-ignore:return_value_discarded
	$Area2D.connect("body_exited",self,"clearLastTouched")
# warning-ignore:return_value_discarded
	#Absolutely kicking myself for not using the enemy base script right now
# warning-ignore:return_value_discarded
	$Area2D.connect("area_entered",self,"areaTouched")


func playIntro(playSound=true,showHPbar=true):
	#$AnimatedSprite.animation="intro"
	$AnimatedSprite.play("intro")
	if showHPbar:
		var seq := TweenSequence.new(get_tree())
		HPBar.set_process(true)
		seq.append(HPBar,"position:x",1235,.1)
# warning-ignore:return_value_discarded
		seq.append(HPBar,"curHP",1,1.5)
# warning-ignore:return_value_discarded
		seq.append_callback(HPBar,"set_process",[false])
	if playSound:
		$AudioStreamPlayer.play()
		return $AudioStreamPlayer
	#1235
	#$AudioStreamPlayer.connect("finished",callback,)

enum STATE {
	IDLE,
	SHOOTING1,
	SHOOTING2,
	MOVING,
	IDLE2,
	JUMPING,
	JUMPING2,
	SHOOTDOWN
}
var curState = STATE.SHOOTING1
var idleTime:float =0
var shots:int = 0
var shouldMoveLeft:bool=true
var tempVelocity:Vector2
#var is_on_floor_:bool
#The duration that the sprite has been colored white.
var whiteTime = 0

# warning-ignore:unused_argument
func _physics_process(delta):
	if not enabled:
# warning-ignore:return_value_discarded
		move_and_slide(Vector2(0,200))

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
func damage(amount):
	curHP -= amount
	#print("Took damage!")
	if curHP <= 0:
		if isAlive:
			killSelf()
	else:
		#set false so the white tint shader will show up.
		hurtSound.play()
		sprite.use_parent_material = false
		whiteTime = 0
		#print(curHP/28.0)
		HPBar.updateHP(curHP/28.0)
		
func killSelf():
	print(self.name+" queued to be killed.")
	HPBar.updateHP(0)
	isAlive = false
	set_physics_process(false)
	sprite.visible = false
	sprite.stop()
	
	$DieSound.play()
	var sp = deathAnimation.instance()
	sp.position=position
	get_parent().add_child(sp)
	#dropRandomItem()
	
	#self.queue_free()
	emit_signal("boss_killed")
	var player = get_node("/root/Node2D/Player")
	player.finishStage()
	#.lockMovement(999,Vector2())
	#get_node("/root/Node2D/VictorySound").play()
