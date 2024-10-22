extends "res://Stages_Reina/Bosses/BossBase.gd"
signal raging_demon_finished()

enum STATES {
	IDLE,
	RAGING_DEMON_START,
	RAGING_DEMON,
	JUMP_SMASH_START,
	JUMP_SMASH,
	JUMP_SMASH_ATTACK,
	HEAL,
	HEAL_WAIT,
	WALK,
	DASH,
	SHOOT,
	THROWING,
}
# Why can't I use macros in godot engine reeeeeee
onready var stateToString = [
	"IDLE",
	"RAGING_DEMON_START",
	"RAGING_DEMON",
	"JUMP_SMASH_START",
	"JUMP_SMASH",
	"JUMP_SMASH_ATTACK",
	"HEAL",
	"HEAL_WAIT",
	"WALK",
	"DASH",
	"SHOOT",
	"THROWING"
]
var previous_state:int = STATES.IDLE
var current_state:int = STATES.RAGING_DEMON_START

var player:KinematicBody2D
var camera:Camera2D

const gravity = 3500
var velocity = Vector2()
var cooldown:float=0.0

onready var rayCast:RayCast2D = $RayCast2D
onready var a1 = get_node("AnimatedSprite/AfterImage1")
onready var a2 = get_node("AnimatedSprite/AfterImage2")
onready var a3 = get_node("AnimatedSprite/AfterImage3")
var oldPositions:PoolVector2Array = PoolVector2Array()

var m16ChargeShot = preload("res://Stages_Reina/Enemies/EnemyChargeShot.tscn")
var m16Shot = preload('res://Stages_Reina/Bosses/M16/M16Shot.tscn')
var grenade = preload("res://Stages_Reina/Enemies/EnemyGrenade.tscn")
var explodeAnim = preload('res://Stages/EnemyExplodeSmall.tscn')

func _ready():
	oldPositions.resize(6)
	a1.visible=false
	a2.visible=false
	a3.visible=false
	$RockSmash.visible=false
	$CanvasLayer2.visible = $CanvasLayer2.visible and OS.is_debug_build()
	
	$Heaven.connect("finished",self,"raging_demon_fin")
	sprite.flip_h = (facing==DIRECTION.LEFT)


func _input(_event):
	if Input.is_key_pressed(KEY_9):
		cooldown=0
		current_state=STATES.HEAL
	elif Input.is_key_pressed(KEY_8):
		cooldown=0
		current_state=STATES.RAGING_DEMON_START
	elif Input.is_key_pressed(KEY_7):
		cooldown=0
		current_state=STATES.JUMP_SMASH_START
	elif Input.is_key_pressed(KEY_6):
		if current_state==0:
			current_state=STATES.SHOOT
	
func playIntro(playSound=true,showHPbar=true)->AudioStreamPlayer:
	if player==null: #TODO: This should probably be in the base class
		player=get_node("/root/Node2D/").get_player()

	#sprite.play("intro")
	var seq := get_tree().create_tween()
	#seq.tween_method($AnimationPlayer,"play",)
	seq.tween_callback($AnimationPlayer,"play",["intro"]).set_delay(5.0/60.0)
	seq.tween_callback($RockSmash/Sound,"play")
	#seq.set_parallel(true)
	#for i in range(2):
	#	seq.tween_property(cam,"offset",Vector2(5*randf(),5*randf()), .05)
	#	seq.tween_property(cam,"offset",Vector2(-5*randf(),-5*randf()), .05)
	#seq.tween_property(cam,"offset",Vector2(0,0), .1)
	
	camera = player.get_node("Camera2D")
	seq.parallel().tween_callback(camera,"shakeCamera",[1.5]).set_delay(5.0/60.0)
	
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
var healing_cooldown:float = 0
func _physics_process(delta):
	if not enabled:
		if player==null: #TODO: This should probably be in the base class
			player=get_node("/root/Node2D/").get_player()
		return
	elif cooldown > 0:
		cooldown-=delta
		return
		
	healing_cooldown -= delta
	
	sprite.flip_h = (facing==DIRECTION.LEFT)
	$CanvasLayer2/Label.text= stateToString[current_state] + \
	'\n'+String($Lasers.time) #+ \
	#String(abs((player.global_position - global_position).x/64))
	
	match current_state:
		STATES.IDLE:
			progress=0
			progress_v=0
			is_reflecting=false
			
			facing=1 if (player.global_position.x > global_position.x) else -1
# warning-ignore:return_value_discarded
			move_and_slide(Vector2(0,200))
			sprite.play("Idle")
			
			#return
			
			#TODO: jump needs to be fair, can't do it if
			# you are too close to the wall and there is
			# no way to dodge.
			# ground smash > shot is proven dodgable, but
			# not sure about shot > ground smash
			var validOptions = [
				STATES.JUMP_SMASH_START,
				STATES.RAGING_DEMON_START,
				STATES.THROWING,
				STATES.SHOOT,
				#STATES.DASH #Just way too hard
			]
			if curHP <= MAX_HP-4 and healing_cooldown <= 0:
				validOptions.append(STATES.HEAL)
			#if curHP < 14:
			#	validOptions.append(STATES.RAGING_DEMON_START)
			var rand = randi()%validOptions.size()
			
			if validOptions[rand] != previous_state:
				current_state=validOptions[rand]
				# Too easy?
				#if Globals.playerData.gameDifficulty <= Globals.Difficulty.MEDIUM:
				#	cooldown+=.3
			
		STATES.RAGING_DEMON_START:
			a1.visible = true
			a2.visible = true
			a3.visible = true

			rayCast.cast_to = Vector2(facing*25,0)
			rayCast.enabled = true
			sprite.animation = "Falling"
			sprite.playing=false
			#lololol
			if Globals.playerData.gameDifficulty >= Globals.Difficulty.MEDIUM:
				is_reflecting = true
			
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
				previous_state = STATES.RAGING_DEMON_START
				current_state = STATES.IDLE
			else:
				var spd = Globals.playerData.gameDifficulty*12
				if curHP<10:
					velocity=Vector2((520.0+spd)*facing,100)
				else:
					velocity=Vector2((460.0+spd)*facing,100)
				move_and_slide(velocity,Vector2(0,-1),true)
		STATES.JUMP_SMASH_START:
			progress_v=0
			
#			if player.global_position.x > global_position.x:
#				facing = DIRECTION.RIGHT
#			else:
#				facing = DIRECTION.LEFT
			velocity = Vector2(200.0*facing, -600.0)
			current_state = STATES.JUMP_SMASH
			sprite.animation = "smash"
			sprite.playing=false
		STATES.JUMP_SMASH:
			velocity.y += 1000 * delta
			#position = position+velocity*delta*6
			velocity = move_and_slide(
				velocity,
				Vector2(0,-1),
				true
			)
			if is_on_floor():
				sprite.frame = 2
				sprite.playing = true
				camera.shakeCamera(.8)
				
				var inst = explodeAnim.instance()
				inst.init(true)
				inst.position = position+Vector2(0,50)
				get_parent().add_child(inst)
				inst.z_index=2
				
				current_state = STATES.JUMP_SMASH_ATTACK
			elif velocity.y > 0:
				sprite.frame = 1
		STATES.JUMP_SMASH_ATTACK:
			for i in range(5):
				var inst = m16Shot.instance()
				inst.position = self.position
				inst.rotation_degrees = -45*i
				get_parent().add_child(inst)
				#if i==0:
				#	inst.audio.play()
			# Playing the one attached to the charge shot
			# would cause it to get cut off when it leaves
			# the screen, which we don't want
			$ChargeShot.play()
			
			cooldown=.4
			#Randomly attack again
			if progress_v==0 and (
				randi()%2==0 and Globals.playerData.gameDifficulty > Globals.Difficulty.EASY
			) and (
				abs((player.global_position - global_position).x)/64 > 6
			):
				progress_v=1
			else:
				previous_state = STATES.JUMP_SMASH_START
				current_state = STATES.IDLE
			#inst.
			pass
		STATES.HEAL:
			sprite.play("intro")
			sprite.frame=0
			$Lasers.anim()
			is_reflecting=true
			if curHP<MAX_HP and Globals.playerData.gameDifficulty >= Globals.Difficulty.EASY:
				$BossHealthUp.play()
			$LaserSound.play()
			current_state=STATES.HEAL_WAIT
		STATES.HEAL_WAIT:
			move_and_slide(Vector2(0,200),Vector2(0,-1),true)
			progress+=delta
			#var t = $Lasers.ANIMATION_LENGTH
			if progress_v>3:
				HPBar.updateHP(curHP/28.0)
				$BossHealthUp.stop()

				#is_reflecting=false
				cooldown= 1.0
				# Should this be based on difficulty?
				# Maybe 5sec cooldown on hard? Or is it hard enough already?
				healing_cooldown = 10
				previous_state=STATES.HEAL
				current_state=STATES.IDLE
				
			var threshold = .125
			if progress > threshold:
				progress-=threshold
				progress_v += 1
				if Globals.playerData.gameDifficulty >= Globals.Difficulty.EASY:
# warning-ignore:narrowing_conversion
					curHP=min(MAX_HP,curHP+1)
					HPBar.updateHP(curHP/28.0)
		STATES.THROWING:
			sprite.set_animation("Grenade")
			#facing=1 if (player.global_position.x > global_position.x) else -1
			#if sprite.frame==1:
			var a = [grenade.instance(),grenade.instance(),grenade.instance()]
			for i in range(a.size()):
				var bi = a[i]
				var pos = position + Vector2(15*facing, -16)
				bi.position = pos
				get_parent().add_child(bi)
				bi.init(facing,Vector2(Vector2(5*facing*(i+1),-5)))
			#No idea why this works, because the raycast
			#is colliding and the grenades aren't
			for i in range(a.size()):
				self.add_collision_exception_with(a[i])# Make bullet and this not collide
				a[i].add_collision_exception_with(a[0])
				a[i].add_collision_exception_with(a[1])
				a[i].add_collision_exception_with(a[2])
			cooldown=1
			previous_state=STATES.THROWING
			current_state=0
		STATES.DASH:
			sprite.play("Dash")
			a1.visible = true
			a2.visible = true
			a3.visible = true
			update_after_image()
			
			velocity=Vector2(460.0*facing,100)
			move_and_slide(velocity,Vector2(0,-1),true)
			
			if (
				progress > .5
			) or (
				facing == DIRECTION.LEFT and get_room_position().x/CAMERA_SCALE < 2
			) or (
				facing == DIRECTION.RIGHT and get_room_position().x/CAMERA_SCALE > 18
			):
				#cooldown=.2
				a1.visible = false
				a2.visible = false
				a3.visible = false
				previous_state=current_state
				current_state=STATES.IDLE
				
			progress+=delta
			
		STATES.SHOOT:
			#var inst = m16ChargeShot.instance()
			if progress_v<2:
				var bi = m16ChargeShot.instance()
				var pos = position + Vector2(30*facing, -15)
			
				bi.position = pos
				get_parent().add_child(bi)
				bi.init(facing)
				sprite.set_animation("IdleShoot")
				progress_v+=1
				cooldown=.5
			else:
				var inst = m16Shot.instance()
				inst.position = self.position + Vector2(30*facing, -15)
				inst.rotation_degrees = -90 + 70*facing
				get_parent().add_child(inst)
				cooldown=.2
				previous_state=STATES.SHOOT
				current_state=STATES.IDLE

#This disables the afterimages when the raging demon attack connects
func raging_demon_fin():
	emit_signal("raging_demon_finished")
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
