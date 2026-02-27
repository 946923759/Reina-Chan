extends "res://Stages_Reina/Bosses/BossBase.gd"

export(PackedScene) var lasers
export(PackedScene) var spinning_bullet
export(PackedScene) var markers_scene
export(PackedScene) var fire_anim_scene
export(NodePath) var breakable_blocks_container
export(NodePath) var lasers_container
const deathAnimationReversed = preload("res://Animations/deathAnimationReversed.tscn")

enum STATES {
	IDLE,
	RANDOMPICK,
	DESTROY_FLOOR,
	
	CIRCLE,
	THROW_AT_PLAYER,
	LASER,
	LASER_ROOM,
	LASER_GRID,
	LASER_ALTERNATING,
	RUSH_PLAYER_LOW,
	SPAWN_AND_THROW_HIGH
}
var curState:int = STATES.RANDOMPICK
var current_phase = 0

var tweener:SceneTreeTween
var room:Node2D
var player:KinematicBody2D
var markers:Node2D
var objects:Array = [null,null,null,null]
var objects_2:Array = [null, null, null, null]
var bullet_spawned_position:Vector2
var radius = 0.0
var idleTime = 0.0

var oldPositions:PoolVector2Array = PoolVector2Array()
onready var a1 = get_node("AnimatedSprite/AfterImage1")
onready var a2 = get_node("AnimatedSprite/AfterImage2")
onready var a3 = get_node("AnimatedSprite/AfterImage3")

onready var laser1 = $laser
onready var laser2 = $laser2
onready var lasers_inst = [$laser, $laser2]

func _on_AnimatedSprite_animation_finished():
	if sprite.animation == "intro" or sprite.animation == "attack":
		sprite.play("idle")

func _ready():
	assert(lasers,"You forgot to set the lasers packedscene!")
	#$AnimatedSprite/GlowEffect.begin()
	
	oldPositions.resize(6)
	a1.visible=false
	a2.visible=false
	a3.visible=false
	laser1.visible = false
	laser2.visible = false
	set_process(false)

func _input(event:InputEvent):
	#print('a')
	if event is InputEventKey:
		if Input.is_key_pressed(KEY_1):
			#var t = create_tween()
			#teleport(t, Vector2(10,5)*64)
			var inst = fire_anim_scene.instance()
			inst.scale = Vector2(4,4)
			inst.position = Vector2(get_room_position().x, (ROOM_HEIGHT-1.75)*64)
			#inst.position = get_room_position()
			room.add_child(inst)
		elif Input.is_key_pressed(KEY_2):
			var t = create_tween()
			spawn_lasers(t)
		elif Input.is_key_pressed(KEY_3):
			bullet_spin()
			var t = create_tween()
			t.tween_method(self,"bullet_spin_tween",0.0,2.1,2.1)
			t.tween_callback(self,"queue_free_bullets")
		elif Input.is_key_pressed(KEY_4):
			#var b = deathAnimationReversed.instance()
			#room.add_child(b)
			#b.global_position = global_position
			pass
			#var t = create_tween()
			#laser_room_dodge_alternating(t)
			curState = STATES.SPAWN_AND_THROW_HIGH
		elif Input.is_key_pressed(KEY_5):
			var t = create_tween()
			begin_laser_grid(t)
		elif Input.is_key_pressed(KEY_6):
			enabled = true
			curState = STATES.IDLE
			var t = create_tween()
			laser_room_dodge(t)
		elif Input.is_key_pressed(KEY_7):
			tweener = create_tween()
			throw_bullets_at_player(tweener)
		elif Input.is_key_pressed(KEY_0):
			health = 1
			HPBar.updateHP(health/28.0)

#var timing_laser_room:float=0.0

func _physics_process(delta):
	if not enabled:
		if player==null: #TODO: This should probably be in the base class
			player=get_node("/root/Node2D/").get_player()
			room = get_parent().get_parent()
			markers = markers_scene.instance()
			markers.visible = false
			room.add_child(markers)
		return
	if not isAlive:
		return
	
	sprite.flip_h = facing == DIRECTION.RIGHT
	if current_phase > 0:
		update_after_image()
	
	if idleTime > 0: #Don't subtract delta, the tweener takes care of it
		# warning-ignore:return_value_discarded
		move_and_slide(Vector2(0,200))
		#sprite.play("Idle")
		return
	elif is_instance_valid(tweener) and tweener.is_valid():
		#if curState==STATES.LASER_ROOM:
		#	timing_laser_room += delta
		return
		
	match curState:
		STATES.IDLE:
			pass
		STATES.RANDOMPICK:
			tweener = create_tween()
			teleport(tweener, Vector2(10,5)*64)
			
			var rand = randi()%3
# warning-ignore:integer_division
			if health < MAX_HP/2 or current_phase > 0:
				rand = randi()%4
			
			if rand == 0:
				curState = STATES.LASER
			elif rand == 1:
				#This is fucking impossible to dodge
				#curState = STATES.THROW_AT_PLAYER
				curState = STATES.SPAWN_AND_THROW_HIGH
			elif rand == 2:
				curState = STATES.LASER_ROOM
				if current_phase > 0:
					curState = STATES.LASER_ALTERNATING
			elif rand == 3:
				curState = STATES.LASER_GRID
		STATES.DESTROY_FLOOR:
			destroy_floor()
			tweener = create_tween()
			tweener.tween_callback(self,"set",["curState",STATES.RANDOMPICK]).set_delay(1.0)

		STATES.LASER:
			tweener = create_tween()
			spawn_lasers(tweener)
			teleport(tweener, Vector2(2,6)*64)
			teleport(tweener, Vector2(18,6)*64)
			
			#yield(tweener,"finished")
			curState = STATES.CIRCLE
		STATES.CIRCLE:
			tweener = create_tween()
			#If player on the right
			# This takes into account the position before the tweener starts
			if (get_room_position_of_node(player)/64).x > 10:
				facing = DIRECTION.RIGHT
				teleport(tweener, Vector2(4,8.5)*64)
				#tweener.tween_property(self,"idleTime",0.0,1).from(.5)
			else:
				facing = DIRECTION.LEFT
				teleport(tweener, Vector2(16,8.5)*64)
				#tweener.tween_property(self,"idleTime",0.0,1).from(.5)
			
			
			#Make a seperate tween since we want elisa to teleport during the spinning
			var newTween = create_tween()
			newTween.tween_callback(self,"bullet_spin").set_delay(.5)
			newTween.tween_method(self,"bullet_spin_tween",0.0,2.1,2.1)
			newTween.tween_callback(self,"queue_free_bullets")
			
			
			tweener.tween_callback(self,"set",["curState",STATES.RANDOMPICK]).set_delay(1.0)
		STATES.THROW_AT_PLAYER:
			tweener = create_tween()
			if (get_room_position_of_node(player)/64).x > 10:
				facing = DIRECTION.RIGHT
				teleport(tweener, Vector2(3,4)*64)
				#tweener.tween_property(self,"idleTime",0.0,1).from(.5)
			else:
				facing = DIRECTION.LEFT
				teleport(tweener, Vector2(17,4)*64)
			
			
			yield(tweener,"finished")
			tweener = create_tween()
			throw_bullets_at_player(tweener)
			#tweener.tween_callback(self,"queue_free_bullets").set_delay(4.0)
			
			tweener.tween_callback(self,"set",["curState",STATES.RANDOMPICK]).set_delay(1.0)
			#curState = STATES.RANDOMPICK

		STATES.LASER_ROOM:
			tweener = create_tween()
			laser_room_dodge(tweener)
			
			curState = STATES.CIRCLE
		STATES.LASER_GRID:
			tweener = create_tween()
			teleport(tweener, Vector2(10,-5)*64)
			begin_laser_grid(tweener)
			
			#If player on the right
			# This takes into account the position before the tweener starts
			if (get_room_position_of_node(player)/64).x > 10:
				facing = DIRECTION.RIGHT
				teleport(tweener, Vector2(4,8.5)*64)
				#tweener.tween_property(self,"idleTime",0.0,1).from(.5)
			else:
				facing = DIRECTION.LEFT
				teleport(tweener, Vector2(16,8.5)*64)
				#tweener.tween_property(self,"idleTime",0.0,1).from(.5)
				
			tweener.tween_callback(self,"set",["curState",STATES.RANDOMPICK])
		STATES.LASER_ALTERNATING:
			tweener = create_tween()
			teleport(tweener, Vector2(10,-5)*64)
			laser_room_dodge_alternating(tweener)
			
			tweener.tween_callback(self,"set",["curState",STATES.RUSH_PLAYER_LOW]).set_delay(1.0)
		STATES.RUSH_PLAYER_LOW:
			is_reflecting = false
			tweener = create_tween()
			
			var begin = Vector2(4,9.5)*64
			var end = Vector2(16,9.5)*64
			
			#If player on the right
			if (get_room_position_of_node(player)/64).x > 10:
				#facing = DIRECTION.RIGHT
				pass
			else:
				#facing = DIRECTION.LEFT
				var tmp = begin
				begin = end
				end = tmp
			
			teleport(tweener, begin)
			tweener.tween_method(self,"set_room_position",begin, end, 1.25).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
			tweener.tween_callback(self,"set",["curState",STATES.RANDOMPICK])
		STATES.SPAWN_AND_THROW_HIGH:
			tweener = create_tween()
			
			var begin:Vector2 = Vector2(4,4)*64
			var end:Vector2 = Vector2(16,4)*64
			
			#If player on the right
			if (get_room_position_of_node(player)/64).x > 10:
				facing = DIRECTION.RIGHT
			else:
				facing = DIRECTION.LEFT
				var tmp = begin
				begin = end
				end = tmp
			teleport(tweener, begin)
			#$CircleAttack.play()
			#tweener.tween_callback(sprite,"play",["attack"])
			tweener.tween_callback($CircleAttack,"play")
			tweener.tween_method(self,"set_room_position",begin, end, 1.0)
			#if end.x > begin.x:
			for i in range(4):
				var bi:Node2D = spinning_bullet.instance()
				var width = (end.x - begin.x)*(i/4.0)
				bi.position = Vector2(begin.x+width, begin.y)
				room.add_child(bi)
				bi.init2()
				objects_2[i]=bi
				bi.visible = false
				
				tweener.parallel().tween_property(bi,"visible",true,0.0).set_delay(.25*i)
			for i in range(4):
				tweener.tween_callback(self,"bullet_init",[i]).set_delay(.25)
			tweener.tween_callback(self,"set",["curState",STATES.RANDOMPICK])

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

onready var original_offset = sprite.offset
onready var original_scale = sprite.scale

func set_facing_within_tween():
	if (get_room_position_of_node(player)/64).x > get_room_position().x:
		facing = DIRECTION.RIGHT
		#tweener.tween_property(self,"idleTime",0.0,1).from(.5)
	else:
		facing = DIRECTION.LEFT

func teleport(t:SceneTreeTween, destination:Vector2, set_facing:bool=true) -> float:
	#set_room_position(Vector2(10,10))
	#return
	
	var tween_time = .25
	
	#var t = create_tween()
	#t.set_parallel(true)
	t.tween_property(self,"is_reflecting",true,0.0)
	
	t.tween_callback(sprite,"play",["teleport"])
	#t.tween_property(sprite,"scale",Vector2(0.0, 15.0), tween_time)
	#t.parallel().tween_property(sprite,"offset",Vector2(original_offset.x,-12), tween_time)
	#t.tween_property(sprite,"")
	#t.tween_callback()
	#t.tween_property(self,"position",self.)
	t.tween_callback(self,"set_room_position",[destination]).set_delay(tween_time)
	if set_facing:
		t.tween_callback(self,"set_facing_within_tween")
	#t.tween_property(sprite,"flip_h",facing == DIRECTION.LEFT,0.0)
	#sprite.flip_h = (facing == DIRECTION.RIGHT)
	t.tween_callback($TeleportSound,"play")
	t.tween_callback(sprite,"play",["teleport",true])
	#t.tween_property(sprite,"scale",original_scale, tween_time)
	#t.parallel().tween_property(sprite,"offset",original_offset, tween_time)
	t.tween_property(self,"is_reflecting",false,0.0).set_delay(tween_time)
	t.tween_callback(sprite,"play",["idle"])
	return tween_time + tween_time

func spawn_lasers(t:SceneTreeTween):
	
	var delay_between_lasers = .5
	if Globals.playerData.gameDifficulty >= Globals.Difficulty.HARD:
		delay_between_lasers = .25
	
	t.set_parallel(true)
	for i in range(3):
		var inst:Node2D = lasers.instance()
		var offset = (i&1)*2 - 1
		inst.position = Vector2(10+9*offset,2+i*4)*64
		if (i&1):
			inst.rotation_degrees = 180
		#print(inst.position, offset)
		room.add_child(inst)
		inst.laser_width = 0
		inst.visible=false

		var start_time = i * delay_between_lasers
		#t.tween_property(inst,"position:x",640,1).set_delay(start_time)
		t.tween_callback(inst,"play").set_delay(start_time)
		t.tween_property(inst,"visible",true,0.0).set_delay(start_time)
		t.tween_property(inst,"laser_width",17*64,.25).set_delay(start_time)
		t.parallel().tween_property(inst,"scale:y",0.0,.25).set_delay(.25+start_time)
		#t.tween_property(inst,)
		t.parallel().tween_callback(inst,"set_monitoring", [false]).set_delay(.5+.12+start_time)
		t.parallel().tween_callback(inst,"queue_free").set_delay(.75+start_time)
	t.set_parallel(false)
	
func spawn_laser_at_pos(position:Vector2, rotation:Vector2=Vector2.RIGHT):
	
	var inst:Node2D = lasers.instance()
	inst.laser_width = 0.0
	inst.visible = false
	#var offset = (i&1)*2 - 1
	#inst.position = Vector2(10+20*offset,2+i*4)*64
	inst.position = position
	inst.rotation = rotation.angle()
	room.add_child(inst)

	#var start_time = i*.25
	#t.tween_property(inst,"position:x",640,1).set_delay(start_time)
	#get_tree().create_tween().bind_node(self)
	var t = get_tree().create_tween().bind_node(inst)
	t.tween_callback(inst,"play")
	t.tween_property(inst,"visible",true,0.0)
	if rotation == Vector2.RIGHT or rotation == Vector2.LEFT:
		t.tween_property(inst,"laser_width",17*64,.25)
	else:
		t.tween_property(inst,"laser_width",9*64,.25)
	t.tween_property(inst,"scale:y",0.0,.25)
	t.tween_property(inst,"visible",false,0.0)
	#t.tween_callback(inst,"set_monitoring", [false])
	#t.parallel().tween_callback(inst,"queue_free").set_delay(.75+start_time)
	#t.tween_property(inst,)
	t.tween_callback(inst,"queue_free").set_delay(.25)

var total_time = 0.0
func bullet_spin():
	total_time = 0.0
	$CircleAttack.play()
	radius=50.0
	bullet_spawned_position = get_room_position()
	#var t = create_tween()
	for i in range(4):
		var bi:Node2D = spinning_bullet.instance()
		
		bi.position = Vector2(0,-radius)
		var rotateBy:float = 2.0 * PI * i/4
		bi.position=bi.position.rotated(rotateBy) + bullet_spawned_position
		#bi.position = get_room_position()
		#print(get_room_position())
		room.add_child(bi)
		bi.init2()
		objects[i]=bi
		
		#continue

		#var room_pos_starting = get_room_position()
		#t.tween_method(self,"outward_spinning_circle", 0.0, 200.0, 3.0, [i, 0.1, room_pos_starting])
		#t.tween_callback(bi,"queue_free")
		#x=radius*cos(t)
		#y=radius*sin(t) 
		#With the tween we want to increase the radius AND the rotation
	curState = STATES.CIRCLE

func bullet_spin_tween(cur_time:float):
	var delta = cur_time - total_time
	total_time = cur_time
	
	var any_valid_orbs:bool=false
	for o in objects:
		if is_instance_valid(o):
			any_valid_orbs=true
			break
	if any_valid_orbs==false:
		return
	
	radius+=delta*300
	
	for c in objects:
		if is_instance_valid(c)==false:
			continue
			
		#Fade out?
		if radius>800:
			c.modulate.a=min(0.0,(900-radius)/100)
		
		# 1 full circle (i.e. 2 * PI) every second, clockwise
		var rotateBy:float = .75 * PI * delta
		
		
		#c.position=c.position.rotated(rotateBy)
		#Efficiency is for lamers
		#var offset = position.direction_to(c.position)*radius
		#c.position=offset.rotated(rotateBy)
		var nPos:Vector2 = (c.position - bullet_spawned_position).rotated(rotateBy)
		#c.position=nPos
		c.position = bullet_spawned_position + Vector2(0,0).direction_to(nPos)*radius

	
func queue_free_bullets():
	for i in range(len(objects)):
		if is_instance_valid(objects[i]):
			objects[i].queue_free()

func throw_bullets_at_player(tweener:SceneTreeTween):
	#$CircleAttack.play()
	tweener.tween_callback(sprite,"play",["attack"])
	tweener.tween_callback($CircleAttack,"play")
	radius=150.0
	bullet_spawned_position = get_room_position()
	#var t = create_tween()
	for i in range(4):
		var bi:Node2D = spinning_bullet.instance()
		bi.position = bullet_spawned_position
		room.add_child(bi)
		bi.init2()
		objects_2[i]=bi
		
		var rotateBy:float = 2.0 * PI * i/4
		var newPos = Vector2(0,-radius).rotated(rotateBy) + bullet_spawned_position
		tweener.parallel().tween_property(bi,"position",newPos,.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	for i in range(4):
		tweener.tween_callback(self,"bullet_init",[i]).set_delay(.5)

func bullet_init(i):
#		if facing==DIRECTION.LEFT and player.global_position.x > global_position.x:
#			v.x=-400
#		elif facing==DIRECTION.RIGHT and player.global_position.x < global_position.x:
#			v.x=400
		#bi.init(v, 2)
	#tweener.tween_callback(objects[i],"init",[v,0]).set_delay(.25)
	#If the player runs into one of them before it can init it will already free
	if is_instance_valid(objects_2[i]):
		var v:Vector2 = player.global_position-objects_2[i].global_position + Vector2(20,20)
		print(v)
		v=v.normalized()*1000
		objects_2[i].init(v,0)
		objects_2[i].set_process(true)
	#tweener.parallel().tween_callback(objects[i],"set_process",[true])
	

func begin_laser_grid(tweener:SceneTreeTween):
	markers.draw_range = 0
	markers.visible = true
	
	var arr = []
	arr.resize(16)
	for i in range(8):
		arr[i] = Vector2(i*2+3,11)*64
	for i in range(8):
		arr[i+8] = Vector2(1,i*2+3)*64
	markers.markersToDraw = PoolVector2Array(arr)
	#markers.draw_range = 16
	#markers.update()
	tweener.tween_property(markers,"draw_range",12,.5)
	#tweener.tween_method(markers,"set_draw_range",0,12,1.0)
	
	
	#Opposite sides of the above markers
	for i in range(8):
		arr[i] = Vector2(i*2+3,1)*64
	for i in range(8):
		arr[i+8] = Vector2(19,i*2+3)*64
	
	var start_time = 1.20
	if current_phase > 0 or Globals.playerData.gameDifficulty >= Globals.Difficulty.HARD:
		start_time = .8
	tweener.set_parallel(true)
	tweener.tween_callback($LasersSound,"play").set_delay(start_time)
	for i in range(12):
		var inst:Node2D = lasers.instance()
		#var offset = (i&1)*2 - 1
		#inst.position = Vector2(10+20*offset,2+i*4)*64
		inst.visible = false
		inst.position = arr[i]
		inst.laser_width = 0.0
		#inst.rotation = rotation.angle()
		if i < 8:
			inst.rotation_degrees = 90
		else:
			inst.rotation_degrees = 180
		room.add_child(inst)

		#var start_time = i*.25
		#t.tween_property(inst,"position:x",640,1).set_delay(start_time)
		#get_tree().create_tween().bind_node(self)
		#var t = get_tree().create_tween().bind_node(inst)
		#tweener.tween_callback(inst,"play").set_delay(start_time)
		tweener.tween_property(inst,"visible",true,0.0).set_delay(start_time)
		if i >= 8:
			tweener.tween_property(inst,"laser_width",17*64,.25).set_delay(start_time)
		else:
			tweener.tween_property(inst,"laser_width",9*64,.25).set_delay(start_time)
		tweener.tween_property(inst,"scale:y",0.0,.25).set_delay(1+.12+start_time)
		tweener.tween_property(inst,"visible",false,0.0).set_delay(1+.12+start_time+.25)
		tweener.tween_callback(inst,"set_monitoring", [false]).set_delay(1+.12+start_time+.25)
		#t.tween_property(inst,"scale:y",0.0,.25)
		#t.tween_property(inst,"visible",false,0.0)
		#t.tween_callback(inst,"set_monitoring", [false])
		#t.tween_property(inst,)
		tweener.tween_callback(inst,"queue_free").set_delay(1.25+.12+start_time)
	tweener.set_parallel(false)
	tweener.tween_property(markers,"draw_range",0,0.0)


#func laser_room_dodge_left(tweener:SceneTreeTween, marker_delay_by:float=0.0, laser_delay_by:float=0.0):
#	var arr = []
#	var NUM_LASERS = 8
#	var starting_pos = Vector2(2,11)
#	arr.resize(NUM_LASERS)
#	for i in range(NUM_LASERS):
#		arr[i] = (starting_pos + Vector2(i,0))*64
#	tweener.tween_callback(markers,"update_draw",[PoolVector2Array(arr)]).set_delay(marker_delay_by)
#	tweener.tween_property(markers,"draw_range",NUM_LASERS,0.0).set_delay(marker_delay_by)
#
#	tweener.set_parallel(true)
#	for i in range(NUM_LASERS):
#		tweener.tween_callback(self,"spawn_laser_at_pos",[arr[i] - Vector2(0,10)*64, Vector2.DOWN]).set_delay(i*.1 + laser_delay_by)
#		#spawn_laser_at_pos(arr[i] - Vector2(0,10)*64, Vector2.DOWN)
#	tweener.set_parallel(false)
#	return NUM_LASERS*.1
#
#func laser_room_dodge_right(tweener:SceneTreeTween, marker_delay_by:float=0.0, laser_delay_by:float=0.0):
#	var arr = []
#	var NUM_LASERS = 9
#	var starting_pos = Vector2(10,11)
#	arr.resize(NUM_LASERS)
#	for i in range(NUM_LASERS):
#		arr[i] = (starting_pos + Vector2(i,0))*64
#	tweener.tween_callback(markers,"update_draw",[PoolVector2Array(arr)]).set_delay(marker_delay_by)
#	tweener.tween_property(markers,"draw_range",NUM_LASERS,0.0).set_delay(marker_delay_by)
#
#	tweener.set_parallel(true)
#	for i in range(NUM_LASERS):
#		tweener.tween_callback(self,"spawn_laser_at_pos",[arr[i] - Vector2(0,10)*64, Vector2.DOWN]).set_delay((NUM_LASERS-i)*.1 + laser_delay_by)
#		#spawn_laser_at_pos(arr[i] - Vector2(0,10)*64, Vector2.DOWN)
#	tweener.set_parallel(false)
#	return NUM_LASERS*.1

#var tmp_timing:float = 0.0
var last_time = 0.0
var total:float = 0.0
func spawn_fires(cur_time:float):
	#tmp_timing -= cur_time
	var delta = cur_time - last_time
	total += delta
	if total > .15:
		#print("Delta!")
		total -= .15
		#var width = ROOM_HEIGHT*64-get_room_position().y-64
		
		for l in lasers_inst:
			var inst:Node2D = fire_anim_scene.instance()
			inst.z_index = -1
			inst.position = Vector2(get_room_position().x+l.position.x, (ROOM_HEIGHT-1.75)*64)
			#print(inst.position)
			room.add_child(inst)
	last_time = cur_time
#	pass

func laser_room_dodge_tw(tweener:SceneTreeTween, begin:Vector2, end:Vector2, delay:float=0.0) -> float:
	
	delay += teleport(tweener, begin, false)
	
	#facing = DIRECTION.LEFT
	#tweener.tween_property(self,)
	
	#This will probably break horribly if room position != position
	var width = ROOM_HEIGHT*64-end.y-64-64 - 2
	#print(width)
	tweener.tween_callback(laser1,"play")
	tweener.tween_callback(laser1,"reset")
	tweener.tween_callback(laser2,"reset")
	

	tweener.set_parallel()
	for l in lasers_inst:
		tweener.tween_property(l,"laser_width",width,.3).from(0.0)

	#This moves Elisa
	var elisa_movement_time = 1.25
	if Globals.playerData.gameDifficulty <= Globals.Difficulty.EASY:
		elisa_movement_time = 1.50
	tweener.tween_method(self,"set_room_position",begin, end, elisa_movement_time).set_delay(.5)

	for l in lasers_inst:
		tweener.tween_property(l,"scale:y",0.0,.25).set_delay(elisa_movement_time).from(1.0)
		tweener.tween_property(l,"visible",false,0.0).set_delay(elisa_movement_time+.25)
		pass
	
	#Now we need something that will spawn fire every 5 frames or so...
	#We really shouldn't be using a tween for this but whatever I guess
	#last_time = 0.0
	#total = 0.0
	tweener.tween_property(self,"last_time",0.0,0.0)
	tweener.tween_property(self,"total",0.0,0.0)
	tweener.tween_method(self,"spawn_fires",0.0, 1.25, 1.00).set_delay(.5)
	
	tweener.set_parallel(false)
		
	#for l in lasers_inst:
	#	var newTw:SceneTreeTween = l.create_tween()
	#	newTw.tween_property(l,"laser_width",width,1.25).from(0.0).set_delay(delay)
	#	l.tween_out(newTw)
	
		
#	#print(ROOM_HEIGHT*64-get_room_position().y)
#	#Minus block at the bottom minus the 64 for the starting laser width
#	tweener.parallel().tween_property(laser1,"laser_width",width,1.25).from(0.0)
#	tweener.parallel().tween_property(laser2,"laser_width",width,1.25).from(0.0)
#	#tweener.tween_callback(laser1,"tween_out")
#	laser1.tween_out(tweener)
#	laser2.tween_out(tweener)
	return 1.75

func laser_room_dodge_left(tw:SceneTreeTween) -> float:
	#facing = DIRECTION.RIGHT
	tw.tween_property(self,"facing",DIRECTION.RIGHT,0.0)
	var begin := Vector2(2.5,3)*64
	var end := Vector2(16,3)*64
	return laser_room_dodge_tw(tw, begin, end)

func laser_room_dodge_right(tw:SceneTreeTween) -> float:
	#facing = DIRECTION.LEFT
	tw.tween_property(self,"facing",DIRECTION.LEFT,0.0)
	var begin := Vector2(17.5,3)*64
	var end := Vector2(4,3)*64
	return laser_room_dodge_tw(tw, begin, end)

func laser_room_dodge(tw:SceneTreeTween):
	markers.draw_range = 0
	markers.visible = false
	
	if (get_room_position_of_node(player)/64).x > 10:
		laser_room_dodge_right(tw)
		#laser_room_dodge_left(tw)
	else:
		laser_room_dodge_left(tw)
		#laser_room_dodge_right(tw)
		
	#teleport(tw, )

func laser_room_dodge_alternating(tweener:SceneTreeTween):
	if (get_room_position_of_node(player)/64).x > 10:
		for i in range(2,9):
			var ret = tweener.tween_callback(self,"spawn_laser_at_pos",[Vector2(i*2,1)*64, Vector2.DOWN])
			if i > 2:
				ret.set_delay(.25)
	else: #Right to left
		for i in range(8,1,-1):
			var ret = tweener.tween_callback(self,"spawn_laser_at_pos",[Vector2(i*2,1)*64, Vector2.DOWN])
			if i < 8:
				ret.set_delay(.25)
		
	pass

func outward_spinning_circle(cur_time:float, object_idx:int, radius:float=0.1, base_position:Vector2=Vector2.ZERO):
	objects[object_idx].position = base_position + Vector2(cur_time*radius*cos(cur_time), cur_time*radius*sin(cur_time) )
	#print(objects[object_idx].position)
			#x=radius*cos(t)
		#y=radius*sin(t) 

func die():
	queue_free_bullets()
	for i in range(len(objects_2)):
		if is_instance_valid(objects_2[i]):
			objects_2[i].queue_free()
	markers.visible = false
	if tweener.is_valid():
		tweener.kill()
	
	
	
	if current_phase == 0:
		HPBar.updateHP(0)
		isAlive = false
		curState = STATES.IDLE
		#enabled = false

		#collision_layer=0
		#collision_mask=0
		$Area2D.set_deferred("monitoring",false)
		$Area2D.set_deferred("monitorable",false)
		set_physics_process(false)
		
		sprite.visible = false
		sprite.stop()
		
		$DieSound.play()
		var sp = deathAnimation.instance()
		sp.position=position
		get_parent().add_child(sp)
		yield(get_tree().create_timer(3.0), "timeout")
		#yield($DieSound,"finished")
		is_reflecting = true
		resurrection()
	else:
		.die()


func resurrection():
	$ReviveSound.play()
	$ResurrectionVoice.play()
	set_room_position(Vector2(10,4)*64)
	var sp = deathAnimationReversed.instance()
	sp.position = position
	get_parent().add_child(sp)
	
	var tw = create_tween()
	tw.tween_method(HPBar,"updateHP",0.0,1.0,2.5)
	
	#If you pause during this it will bug out, so just don't pause or something
	yield(get_tree().create_timer(2.5), "timeout")
	
	#collision_layer=0
	#collision_mask=0
	
	sprite.visible = true
	sprite.play("idle")
	curState = STATES.DESTROY_FLOOR
	
	health = MAX_HP
	
	$Area2D.set_deferred("monitoring",true)
	$Area2D.set_deferred("monitorable",true)
	set_physics_process(true)
	isAlive = true
	current_phase = 1
	a1.visible = true
	a2.visible = true
	a3.visible = true
	$AnimatedSprite/GlowEffect.begin()
	
	#sprite.stop()

func destroy_floor():
	var n2 = get_node_or_null(lasers_container)
	if n2:
		n2.execute()
	else:
		printerr("Can't find laser container!!")
	
	yield(get_tree().create_timer(.5), "timeout")
	
	var n = get_node_or_null(breakable_blocks_container)
	if n:
		n.execute()
	else:
		printerr("Can't find breakable block container!!")
		
	
	
