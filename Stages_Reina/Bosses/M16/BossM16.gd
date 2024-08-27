extends "res://Stages_Reina/Bosses/BossBase.gd"

enum STATES {
	IDLE,
	RAGING_DEMON_START,
	RAGING_DEMON,
	JUMP_SMASH_START,
	JUMP_SMASH,
	HEAL,
	HEAL_WAIT
}
# Why can't I use macros in godot engine reeeeeee
onready var stateToString = [
	"IDLE",
	"RAGING_DEMON_START",
	"RAGING_DEMON",
	"JUMP_SMASH_START",
	"JUMP_SMASH",
	"HEAL",
	"HEAL_WAIT"
]
var current_state = STATES.RAGING_DEMON_START

var player:KinematicBody2D
const gravity = 3500
var velocity = Vector2()
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
	$RockSmash.visible=false
	
	$Heaven.connect("finished",self,"raging_demon_fin")
	sprite.flip_h = (facing==DIRECTION.LEFT)


func _input(_event):
	if Input.is_key_pressed(KEY_0):
		current_state=STATES.HEAL
	elif Input.is_key_pressed(KEY_1):
		current_state=STATES.RAGING_DEMON_START
	
func playIntro(playSound=true,showHPbar=true)->AudioStreamPlayer:
	if player==null: #TODO: This should probably be in the base class
		player=get_node("/root/Node2D/").get_player()

	#sprite.play("intro")
	var seq := get_tree().create_tween()
	#seq.tween_method($AnimationPlayer,"play",)
	seq.tween_callback($AnimationPlayer,"play",["intro"]).set_delay(5.0/60.0)
	seq.tween_callback($RockSmash/Sound,"play")
	#seq.set_parallel(true)
	var cam:Camera2D = player.get_node("Camera2D")
	#for i in range(2):
	#	seq.tween_property(cam,"offset",Vector2(5*randf(),5*randf()), .05)
	#	seq.tween_property(cam,"offset",Vector2(-5*randf(),-5*randf()), .05)
	#seq.tween_property(cam,"offset",Vector2(0,0), .1)
	
	seq.parallel().tween_callback(cam,"shakeCamera",[1.5]).set_delay(5.0/60.0)
	
#	#seq.tween_property($Node2D,"visible",true,0.0)
#	if showHPbar:
#		#HPBar.set_process(true)
#		seq.parallel().tween_property(HPBar,"position:x",1235,.1)
## warning-ignore:return_value_discarded
#		seq.tween_property(HPBar,"curHP",1,1.5)
## warning-ignore:return_value_discarded
#		seq.tween_callback(HPBar,"set_process",[false])
#	if playSound:
#		introSound.play()
	return .playIntro(playSound,showHPbar)

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

var progress:float=0.0
var progress_v:int = 0
func _physics_process(delta):
	if not enabled:
		if player==null: #TODO: This should probably be in the base class
			player=get_node("/root/Node2D/").get_player()
		return
	elif cooldown >=0:
		cooldown-=delta
		return
	
	sprite.flip_h = (facing==DIRECTION.LEFT)
	$CanvasLayer2/Label.text= stateToString[current_state]+'\n'+String($Lasers.time)
	
	match current_state:
		STATES.IDLE:
			is_reflecting=false
# warning-ignore:return_value_discarded
			move_and_slide(Vector2(0,200))
			sprite.play("Idle")
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
			elif (
					facing == DIRECTION.LEFT and get_room_position().x/CAMERA_SCALE < 2
				) or (
					facing == DIRECTION.RIGHT and get_room_position().x/CAMERA_SCALE > 18
				):
				#raging_demon_fin()
				a1.visible = false
				a2.visible = false
				a3.visible = false
				sprite.play("default")
				#Flip M16 facing
				facing *= -1
				current_state = STATES.IDLE
			else:
				var velocity=Vector2(450.0*facing,5)
				move_and_slide(velocity,Vector2(0,-1),true)
		STATES.JUMP_SMASH_START:
			velocity = Vector2(450.0*facing, -270.0)
			current_state = STATES.JUMP_SMASH
			sprite.animation = "smash"
			sprite.playing=false
		STATES.JUMP_SMASH:
			velocity.y += 500 * delta
			#position = position+velocity*delta*6
			velocity = move_and_slide(
				velocity,
				Vector2(0,-1),
				true
			)
			if is_on_floor():
				sprite.playing = true
				current_state = STATES.IDLE
			elif velocity.y > 0:
				sprite.frame = 1
		STATES.HEAL:
			sprite.play("intro")
			sprite.frame=0
			$Lasers.anim()
			is_reflecting=true
			#cooldown=.5
			if curHP<MAX_HP and Globals.playerData.gameDifficulty >= Globals.Difficulty.HARD:
				$BossHealthUp.play()
			current_state=STATES.HEAL_WAIT
		STATES.HEAL_WAIT:
			progress+=delta
			#var t = $Lasers.ANIMATION_LENGTH
			if progress_v>3:
				HPBar.updateHP(curHP/28.0)
				$BossHealthUp.stop()
				current_state=STATES.IDLE
				cooldown= 1.5
				progress_v=0
				progress=0
				
			var threshold = .125
			if progress > threshold:
				progress-=threshold
				progress_v += 1
				if Globals.playerData.gameDifficulty >= Globals.Difficulty.HARD:
					curHP=min(MAX_HP,curHP+1)
					HPBar.updateHP(curHP/28.0)
				

#This disables the afterimages when the raging demon attack connects
func raging_demon_fin():
	a1.visible = false
	a2.visible = false
	a3.visible = false
	sprite.play("RagingDemon")

static func get_bezier_curve(p0:Vector2, p1:Vector2, p2:Vector2, t:float):
	var q0 = p0.linear_interpolate(p1, t)
	var q1 = p1.linear_interpolate(p2, t)
	var r = q0.linear_interpolate(q1, t)
	return r

# #Because godot tweens suck
# var p0:Vector2
# var p1:Vector2
# var p2:Vector2
# func set_bezier(p0_:Vector2,p1_:Vector2,p2_:Vector2):
# 	p0 = p0_
# 	p1 = p1_
# 	p2 = p2_

static func move_along_bezier(obj:Node2D, t:float, p0:Vector2, p1:Vector2, p2:Vector2):
	obj.position = get_bezier_curve(p0,p1,p2,t)
	pass
	
static func move_along_parabola(obj:Node2D, cur_time:float, end_time:float):
	#get_node(obj).position.y=t
	# (x-.5)^2*-4+1 = invert parabola from 0 to 1
	var s = Def.SCALE(cur_time,0,end_time,0,1)
	var r:float = pow(s-.5, 2) * -4 + 1
	#obj.position.y = Def.SCALE(r,0,1,begin,end)
