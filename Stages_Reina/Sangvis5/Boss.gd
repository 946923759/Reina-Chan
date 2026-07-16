extends Node2D
signal enabled()
# warning-ignore:unused_signal
signal finished()
signal boss_killed()

#HP is split up into 32
const MAX_HP = 160

var enabled = false setget set_enabled
onready var health:int = MAX_HP

export(PackedScene) var large_bullet
export(PackedScene) var small_bullet

export(NodePath) var hp_bar_path
export(NodePath) var weapon_1
export(NodePath) var weapon_2
onready var guns = [get_node(weapon_1), get_node(weapon_2)]

onready var sprite = $AnimatedSprite
onready var HPBar = get_node(hp_bar_path)
onready var introSound:AudioStreamPlayer=$IntroSound

var deathAnimation = preload("res://Animations/deathAnimation.tscn")
const deathAnimationReversed = preload("res://Animations/deathAnimationReversed.tscn")
const explosion = preload("res://Stages/EnemyExplosion.tscn")
const explosion_small = preload("res://Stages/EnemyExplodeSmall.tscn")

enum SPELL_CARD_PHASES {
	INACTIVE,
	LARGE_SHOT,
	SMALL_SHOT,
	SPREAD,
	MAGMA_RISING, # :)
	NITORI_WAVE, #Yes, from touhou 10
}
var phase = SPELL_CARD_PHASES.LARGE_SHOT
var tween:SceneTreeTween

var is_reflecting:bool=false

var SCREEN_SIZE = Vector2(1280,720)
const SCREEN_TOP = 0
const SCREEN_LEFT = 0
const SCREEN_RIGHT = 1280
const SCREEN_BOTTOM = 720
const SCREEN_CENTER_Y = 720/2

var _magma_wave_targets:Array = []
var _magma_wave_base_y:Array = []
var _magma_wave_amplitude:float = 0.0

func _ready():
	# All danmaku shots are CollisionShape2D
	# warning-ignore:return_value_discarded
	$Area2D.connect("body_entered",self,"objectTouched")
	guns[0].visible = false
	guns[1].visible = false

func resurrection(playSound:bool=true):
	if playSound:
		$ReviveSound.play()
	var sp = deathAnimationReversed.instance()
	sp.position = position
	get_parent().add_child(sp)
	#emit_signal("finished")
	#return
	
	var tw = create_tween()
	tw.tween_property(self,"visible",true,0.0).set_delay(2.5)
	#sprite.visible = true
	sprite.play("idle")
	tw.tween_callback(self,"emit_signal",["finished"])
	
#func skip_intro():
#	visible = true

func playIntro(playSound=true, showHPbar=true)->AudioStreamPlayer:
	#sprite.play("intro")
	for i in range(len(guns)): # 0,1
		guns[i].position.x = self.position.x
		if i==0:
			guns[i].position.y = self.position.y-200
		else:
			guns[i].position.y = self.position.y+200
		guns[i].play("intro")
		guns[i].visible = true

	if showHPbar:
		HPBar.health = 0
		var seq := create_tween()
		#HPBar.set_process(true)
		seq.tween_property(HPBar,"position:x",1232,.1)
# warning-ignore:return_value_discarded
		seq.tween_property(HPBar,"health",health,1.5)
# warning-ignore:return_value_discarded
		seq.tween_callback(HPBar,"set_process",[false])
	if playSound:
		introSound.play()
	else:
		visible = true
		sprite.play("idle")
		#resurrection(false)
	return introSound

func set_enabled(e):
	emit_signal("enabled")
	enabled = true

func _input(event:InputEvent):
	#print('a')
	if event is InputEventKey:
		if Input.is_key_pressed(KEY_1):
			danmaku_throw_everywhere()
		elif Input.is_key_pressed(KEY_2):
			laser_attack()
		elif Input.is_key_pressed(KEY_0):
			health = 1
			HPBar.updateHP(health)
		elif Input.is_key_pressed(KEY_3):
			danmaku_alt()
		elif Input.is_key_pressed(KEY_4):
			aaaa()
		elif Input.is_key_pressed(KEY_5):
			magma_rising()


var tmp_explode = false
func _physics_process(delta):
	#return
	
	if not enabled:
		return
		
	if Input.is_action_pressed("R1") and Input.is_action_just_pressed("DebugButton12"):
		die()
		return

	if health <= MAX_HP-32*(phase):
		is_reflecting = true
		if tmp_explode == false:
			print("Explode!!")
			tmp_explode = true
			
			explode()
			clear_bullets()
			tween.kill()

			var targets = [guns[0], self, guns[1]]
			tween = create_tween()
			var move_target = SCREEN_CENTER_Y
			for i in range(len(targets)):
				var this_pos = move_target+(i-1)*200
				tween.parallel().tween_property(targets[i],"position:y",this_pos,.5).set_delay(1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)



	if tween and tween.is_valid():
		return
		
	#If phase is 0 and health is 128 then should be phase 1
	#If phase is 1 and health is 96 then phase 2 etc
	if health <= MAX_HP-32*(phase):
		phase += 1
		is_reflecting = false
		tmp_explode = false
	
	match phase:
		SPELL_CARD_PHASES.LARGE_SHOT:
			#Align x positions
			var targets = [guns[0], self, guns[1]]
			guns[0].position.x = self.position.x
			guns[1].position.x = self.position.x
			
			tween = create_tween()
			tween.tween_callback(self,"danmaku_throw_everywhere")
			var move_target = SCREEN_BOTTOM-100
			for i in range(len(targets)):
				var this_pos = move_target+(i-1)*200
				tween.parallel().tween_property(targets[i],"position:y",this_pos,1).set_delay(1.6).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

			#danmaku_throw_everywhere(tween)
			tween.tween_callback(self,"danmaku_throw_everywhere")
			
			move_target = 100
			for i in range(len(targets)):
				var this_pos = move_target+(i-1)*200
				tween.parallel().tween_property(targets[i],"position:y",this_pos,1.25).set_delay(1.6).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
			
			tween.tween_callback(self,"danmaku_throw_everywhere")
			
			move_target = SCREEN_CENTER_Y
			for i in range(len(targets)):
				var this_pos = move_target+(i-1)*200
				tween.parallel().tween_property(targets[i],"position:y",this_pos,1).set_delay(1.6).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
				#tween.tween_property(self,"position:y",SCREEN_CENTER_Y,1).set_delay(1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
			#Sleep 5
			tween.tween_property(self,"position:y",SCREEN_CENTER_Y,1).set_delay(3)
		SPELL_CARD_PHASES.SMALL_SHOT:
			tween = create_tween()

			var random_position_rect = Rect2(1280-300, 200, 160, SCREEN_BOTTOM-200-200)
			var move_target = _get_random_step_target_in_rect(random_position_rect, 140.0)
			for g in guns:
				tween.parallel().tween_callback(g,"play",["charging"]).set_delay(1)
			#
			tween.parallel().tween_property(self,"position",move_target,1.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD).set_delay(1)
			tween.parallel().tween_property(guns[0],"position",move_target-Vector2(0,-200),1.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD).set_delay(1)
			tween.parallel().tween_property(guns[1],"position",move_target-Vector2(0,+200),1.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD).set_delay(1)
			# Keep a small pause so this phase cadence stays close to the old 1.5s sleep.
			#tween.tween_property(self,"position",position,.4)
			#tween.tween_callback($ShootSound2,"play")
			for g in guns:
				tween.tween_callback(g,"play",["shot"])
			tween.tween_callback(self,"laser_attack")
		SPELL_CARD_PHASES.SPREAD:
			tween = create_tween()
			danmaku_alt(tween)
			#SLEEP FOR 1.5 SECONDS
			tween.tween_property(self,"visible",true,1.5)
		SPELL_CARD_PHASES.NITORI_WAVE:
			tween = create_tween()
			aaaa(tween)
			#tween.tween_callback(self,"aaaa")
			#tween.tween_property(self,"visible",true,1.5)
		SPELL_CARD_PHASES.MAGMA_RISING:
			tween = create_tween()
			magma_rising(tween)
			

func objectTouched(obj):
	if is_reflecting:
		
		if obj.has_method("reflect"):
			obj.call("reflect")
		else:
			# No reason not to do this, a reflected
			# bullet should no longer affect the
			# stage
			obj.collision_layer = 0
			obj.collision_mask = 0
			
			if obj is RigidBody2D:
				obj.linear_velocity = Vector2(obj.linear_velocity.x*-1, -400)
	else:
		obj.queue_free()
		damage(1)

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
			pass
	else:
		#set false so the white tint shader will show up.
		$HurtSound.play()
		#sprite.use_parent_material = false
		#whiteTime = .1
		#print(health)
		HPBar.updateHP(health)

func explode():
	var explodePos:PoolVector2Array = [
		Vector2(-12,-12),
		Vector2(12,12),
		Vector2(0,4),
	]
	for i in range(3):
		var e = explosion.instance()
		#Delay playing animation
		e.time = -.45*i
		e.position = self.position+explodePos[i]*2
		get_parent().add_child(e)
		#device, weak magnitude, strong magnitude, duration
	get_node("/root/Node2D").get_player().INPUT.vibrate_device(
		0,
		min(.2,1.0),
		min(.3,1.0),
		.1
	)
	get_node("/root/Node2D").shake_camera(1.5);

func clear_bullets():
	var room = get_parent()
	var nodes = get_tree().get_nodes_in_group("bullets")
	var rect = Rect2(0,0,SCREEN_RIGHT,SCREEN_BOTTOM)
	for n in nodes:
		#For some reason not all bullets automatically queue free when out of scope
		#but we can do it here
		if rect.has_point(n.position):
			var inst = explosion_small.instance()
			inst.position = n.position
			room.add_child(inst)
			inst.sound.volume_db = -INF
		n.queue_free()

func die():
	print(self.name+" queued to be killed.")
	health = 0
	HPBar.updateHP(0)
	isAlive = false
	enabled = false
	if tween and tween.is_valid():
		tween.kill()
	clear_bullets()

	$Area2D.set_deferred("monitoring",false)
	$Area2D.set_deferred("monitorable",false)
	set_physics_process(false)
	
	#var tw = create_tween()
	var root = get_node("/root/Node2D")
	root.stop_music()
	#explode()
	
	#device, weak magnitude, strong magnitude, duration
	get_node("/root/Node2D").get_player().INPUT.vibrate_device(
		0,
		min(.2,1.0),
		min(.3,1.0),
		.1
	)
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	for i in range(5):
		var e = explosion.instance()
		#Delay playing animation
		e.time = -.25*i
		var random_position = Vector2(rand_range(0.0,12.0),rand_range(0.0,12.0)) - Vector2(6.0,6.0)
		e.position = self.position+random_position*2
		get_parent().add_child(e)
		if i > 0:
			e.sound.volume_db = -INF
	for g in guns:
		var e = explosion.instance()
		e.position = g.position
		get_parent().add_child(e)
		e.sound.volume_db = -INF
		g.visible = false
	
#	var tween = create_tween()
#	var white = $WhiteBox
#	tween.set_parallel()
#	tween.tween_property(white,"visible",true,0.0).set_delay(1.0)
#	tween.tween_property(white,"modulate:a",1.0,1.0).from(0.0).set_delay(1.0)
#	tween.tween_property(white,"scale:x",150.0,1).from(0.0).set_delay(1.0)
#	tween.set_parallel(false)
#	tween.tween_property(white,"modulate",Color.black,1.0).from(Color.white)
#	tween.tween_property(sprite,"visible",false,0.0)
#	tween.tween_property(white,"modulate:a",0.0,1.0).from(1.0)
#	yield(tween,"finished")
#	#$DieSound.play()
	yield(get_tree().create_timer(1.25), "timeout")
	#print("end")

	sprite.visible = false
	var sp = deathAnimation.instance()
	sp.position=position
	get_parent().add_child(sp)
	
	var tween = create_tween()
	var white = $WhiteBox
	tween.tween_callback($Quake,"play")
	tween.set_parallel()
	tween.tween_property(white,"visible",true,0.0)
	tween.tween_property(white,"modulate:a",1.0,1.0).from(0.0)
	tween.tween_property(white,"scale:x",150.0,1).from(0.0)
	
	emit_signal("boss_killed")


func danmaku_throw_everywhere(optional_tween=null):
	var room = get_parent()
	
	#Just leave it all to tweens!!!
	#var bullets = []
	#bullets.resize(9*3)
	var tw:SceneTreeTween
	if is_instance_valid(optional_tween):
		tw = optional_tween
	else:
		tw = create_tween()
		tw.set_parallel(true)
	for k in range(6):
		#TODO: Actually we only need to spawn the bullets facing forwards
		for i in range(9):
			var bi:Node2D = large_bullet.instance()
			bi.visible = false
			bi.position = self.position
			room.add_child(bi)
			bi.add_to_group("bullets")
			var velocity = Vector2.RIGHT.rotated(deg2rad(i*22.22+k*11.11+75))*250
			#bullets[k*9+i] = bi
			var ret = tw.tween_callback(bi,"init",[velocity, 0])
			ret.set_delay(k*.25)
		tw.tween_callback($ShootSound,"play").set_delay(k*.25)
			#bi.init(velocity, 0)
	#for k in range(3):
	#	bi.init(velocity, 0)
	tw.set_parallel(false)
	pass

func laser_attack():
	var room = get_parent()
	var player = get_node("/root/Node2D").get_player();
	var g1:Node2D = get_node(weapon_1)
	var g2:Node2D = get_node(weapon_2)
	
	#var tw = create_tween()
	#tw.set_parallel(true)
	$ShootSound2.play()
	for delay in range(5):
		for g in [g1, g2]:
			for i in range(-1,2,1):
				var bi:Node2D = small_bullet.instance()
				bi.color = Color("#c700ff")
				bi.position = g.position + g.bullet_spawn_pos
				#bi.visible = false
				room.add_child(bi)
				bi.add_to_group("bullets")
				var d_normalized = bi.position.direction_to(player.position).normalized()
				#print(i, d_normalized.rotated(PI/16*i))
				bi.timer = delay * -.2
				bi.init(
					d_normalized.rotated(PI/16*i)*5.2,
					false
				)


func _get_random_step_target_in_rect(rect:Rect2, step_distance:float)->Vector2:
	var min_x = rect.position.x
	var max_x = rect.position.x + rect.size.x
	var min_y = rect.position.y
	var max_y = rect.position.y + rect.size.y

	var origin = position
	var best_candidate = origin
	var best_distance = 0.0
	for _i in range(12):
		var angle = randf() * PI * 2.0
		var candidate = origin + Vector2.RIGHT.rotated(angle) * step_distance
		candidate.x = clamp(candidate.x, min_x, max_x)
		candidate.y = clamp(candidate.y, min_y, max_y)

		var dist = origin.distance_to(candidate)
		if dist > best_distance:
			best_distance = dist
			best_candidate = candidate
		if dist >= step_distance * 0.85:
			return candidate

	if best_distance > 0.0:
		return best_candidate

	return Vector2(
		rand_range(min_x, max_x),
		rand_range(min_y, max_y)
	)


func aaaa(optional_tween:SceneTreeTween=null):
	var room = get_parent()
	var tw:SceneTreeTween
	
	if is_instance_valid(optional_tween):
		tw = optional_tween
	else:
		tw = create_tween()
	tw.set_parallel(true)

	
	var spacing = 140
	if Globals.playerData.gameDifficulty >= Globals.Difficulty.HARD:
		spacing = 125

	for x in range(10):
		var x_pos = (SCREEN_SIZE.x - 100) - x*spacing
		var y_direction = 1
		if x&1: #If even number
			y_direction = -1
		#If even, spawn from top. If odd, spawn from bottom
		var y_pos = SCREEN_CENTER_Y + (SCREEN_CENTER_Y+128)*y_direction
		
		tw.tween_callback($ShootSound,"play").set_delay(.5+x)
		for i in range(18):
			var bi = large_bullet.instance()
			bi.visible = false
			bi.position = Vector2(x_pos,y_pos)
			room.add_child(bi)
			bi.add_to_group("bullets")
			
			
			var velocity = 300*Vector2(0,y_direction*-1)
			tw.tween_callback(bi,"init",[velocity, 0]).set_delay(.5*i+x)
			tw.tween_property(bi,"visible",true,0.0).set_delay(.5*i+x)
	
		tw.tween_callback(self,"laser_attack").set_delay(.5+x*1.5)
	#laser_attack()


#This attack spawns alternating circles and sends them towards the player
func danmaku_alt(optional_tween=null):
	var room = get_parent()
	
	#Just leave it all to tweens!!!
	#var bullets = []
	#bullets.resize(9*3)
	var tw:SceneTreeTween
	if is_instance_valid(optional_tween):
		tw = optional_tween
	else:
		tw = create_tween()
	tw.set_parallel(true)


	var LIM = 5
	var RANGE = SCREEN_SIZE.y
	var SPACING = RANGE/LIM
	for i in range(LIM):
		var y_pos = SCREEN_CENTER_Y+((i)-LIM/2.0)*SPACING+SPACING/2
		
		var bi = large_bullet.instance()
		bi.visible = false
		#We have to make it so when k==3 it's zero
		#bi.position = Vector2(position.x+200, y_pos)
		bi.position = position
		#bi.position = self.position
		room.add_child(bi)
		bi.add_to_group("bullets")
		
		tw.tween_property(bi,"visible",true,0.0)
		tw.tween_property(bi,"position",Vector2(position.x, y_pos),.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		
		var velocity = Vector2.LEFT*300
		var ret = tw.tween_callback(bi,"init",[velocity, 0])
		ret.set_delay(.5)
	tw.tween_callback($ShootSound,"play")
	
	LIM = 4
	RANGE = SCREEN_SIZE.y-100
	SPACING = RANGE/LIM
	for i in range(LIM):
		var y_pos = SCREEN_CENTER_Y+((i)-LIM/2.0)*SPACING+SPACING/2
		
		var bi = large_bullet.instance()
		bi.visible = false
		#We have to make it so when k==3 it's zero
		#bi.position = Vector2(position.x+200, y_pos)
		bi.position = position
		#bi.position = self.position
		room.add_child(bi)
		bi.add_to_group("bullets")
		
		tw.tween_property(bi,"visible",true,0.0).set_delay(.6)
		tw.tween_property(bi,"position",Vector2(position.x, y_pos),.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).set_delay(.6)
		
		var velocity = Vector2.LEFT*300
		var ret = tw.tween_callback(bi,"init",[velocity, 0])
		ret.set_delay(1.1)

func magma_rising(optional_tween=null):
	var tw:SceneTreeTween
	if is_instance_valid(optional_tween):
		tw = optional_tween
	else:
		tw = create_tween()

	var Y_RANGE = 400
	var wave_speed = 1 # Radians per second; increase for faster travel.
	var wave_duration = (PI * 8.0) / wave_speed
	var shot_interval = 0.22
	var shot_count = int(ceil(wave_duration / shot_interval))
	
	
	#TODO: This hot garbage
	#tween_callback can call the function at the tween's current time
	#so using that to instance bullets works fine

	_magma_wave_targets = [self, guns[0], guns[1]]


	_magma_wave_base_y.clear()
	_magma_wave_amplitude = Y_RANGE * 0.5
	var center_y = SCREEN_CENTER_Y
	for target in _magma_wave_targets:
		if target == self:
			_magma_wave_base_y.append(center_y)
		else:
			_magma_wave_base_y.append(center_y + (target.position.y - self.position.y))

	# Tween theta from 0..2*PI and derive Y from sin(theta).
	tw.tween_method(self, "_set_magma_wave_theta", 0.0, PI * 4.0, wave_duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	for i in range(shot_count):
		tw.parallel().tween_callback(self, "_fire_bullet_pair").set_delay(i * shot_interval)
	for i in range(10):
		#tw.parallel().tween_callback(self, "_alt_bullets",[i]).set_delay(i * shot_interval * 5)
		#If integer is odd then & 1 will be 1 else 0. So this is doing -1 or 1
		var bottom_or_top = (i&1)*2-1
		tw.parallel().tween_callback(self, "line_bullets",[
			#Starting position
			#+SCREEN_CENTER_Y*bottom_or_top*1.25
			Vector2(i*90, SCREEN_CENTER_Y+(SCREEN_CENTER_Y+100)*bottom_or_top), 
			#Movement direction
			Vector2(0,bottom_or_top*-330)
		]).set_delay(i * shot_interval * 5)
	for i in range(1,10):
		var bottom_or_top = (i&1)*2-1
		tw.parallel().tween_callback(self, "line_bullets",[
			Vector2(SCREEN_RIGHT-150-i*90, SCREEN_CENTER_Y+(SCREEN_CENTER_Y+100)*bottom_or_top), 
			Vector2(0,bottom_or_top*-330)
		]).set_delay((i+10) * shot_interval * 5)
	tw.tween_callback(self, "_clear_magma_wave_state")


func _set_magma_wave_theta(theta:float):
	if _magma_wave_targets.empty() or _magma_wave_base_y.empty():
		return

	var y_offset = sin(theta) * _magma_wave_amplitude
	for i in range(_magma_wave_targets.size()):
		var target = _magma_wave_targets[i]
		if is_instance_valid(target):
			target.position.y = _magma_wave_base_y[i] + y_offset


func _fire_bullet_pair():
	var room = get_parent()
	var player = get_node("/root/Node2D").get_player()
	$ShootSound2.play()
	for g in guns:
		for i in range(-1, 2):
			var bi:Node2D = small_bullet.instance()
			bi.color = Color("#c700ff")
			bi.position = g.position + g.bullet_spawn_pos
			room.add_child(bi)
			bi.add_to_group("bullets")
			#var d_normalized = bi.position.direction_to(player.position).normalized()
			bi.init(
				Vector2.LEFT*10,
				false
			)

#Spawns 4 or 5 large bullets that spread out. Yes I know the code is horrible.
func _alt_bullets(even_or_odd_integer:int=0):
	var room = get_parent()
	var tw = create_tween()
	tw.set_parallel()
	tw.tween_callback($ShootSound,"play")
	#If integer is odd then & 1 will add +1 to LIM
	var LIM = 4 + (even_or_odd_integer & 1)
	var RANGE = SCREEN_SIZE.y-100
	var SPACING = RANGE/LIM
	for i in range(LIM):
		var y_pos = SCREEN_CENTER_Y+((i)-LIM/2.0)*SPACING+SPACING/2
		
		var bi = large_bullet.instance()
		#bi.visible = false
		#We have to make it so when k==3 it's zero
		#bi.position = Vector2(position.x+200, y_pos)
		bi.position = position
		#bi.position = self.position
		room.add_child(bi)
		bi.add_to_group("bullets")
		
		tw.tween_property(bi,"visible",true,0.0)
		tw.tween_property(bi,"position",Vector2(position.x, y_pos),.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		
		var velocity = Vector2.LEFT*300
		var ret = tw.tween_callback(bi,"init",[velocity, 0])
		#ret.set_delay(1.1)
		
#Spawns 4 or 5 large bullets that spread out. Yes I know the code is horrible.
func line_bullets(starting_position:Vector2, direction:Vector2):
	var room = get_parent()
	var tw = create_tween()
	tw.set_parallel()
	tw.tween_callback($ShootSound,"play")
	#$ShootSound.play()
	for i in range(4):
		
		var bi = large_bullet.instance()
		bi.visible = true
		#We have to make it so when k==3 it's zero
		#bi.position = Vector2(position.x+200, y_pos)
		bi.position = starting_position
		#bi.position = self.position
		room.add_child(bi)
		bi.add_to_group("bullets")
		
		#tw.tween_property(bi,"visible",true,0.0)
		#tw.tween_property(bi,"position",Vector2(position.x, y_pos),.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		
		#var velocity = Vector2.LEFT*300
		var ret = tw.tween_callback(bi,"init",[direction, 0]).set_delay(.4*i)
		#bi.init(direction, 0)
		#ret.set_delay(.5)

func _clear_magma_wave_state():
	_magma_wave_targets.clear()
	_magma_wave_base_y.clear()
	_magma_wave_amplitude = 0.0
