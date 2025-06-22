extends "res://Stages_Reina/Bosses/BossBase.gd"

enum STATE {
	IDLE,
	TELEPORT_OUT,
	TELEPORT_IN_SETUP,
	TELEPORT_IN,
	READY_SHOOT,
	SHOOT_HORIZONTAL,
	SPAWN_ENEMIES,
	SPAWN_LAVA,
	TELEPORT_LAVA,
	RISE_LAVA,
	LOWER_LAVA
}
var prev_state = STATE.SHOOT_HORIZONTAL
var curState = STATE.IDLE
var next_state = STATE.IDLE
var idleTime:float =0
var progress:float = 0.0

var player:KinematicBody2D

const b1 = preload("res://Stages_Reina/Bosses/Agent/bulletAgent.tscn")
const b2 = preload("res://Stages_Reina/Enemies/bulletDanmaku.tscn")
const enemy_to_spawn = preload("res://Stages_Reina/Enemies/Scout.tscn")
const explosion = preload("res://Stages/EnemyExplodeSmall.tscn")
const lava_drop = preload("res://Stages_Reina/Bosses/Agent/Droplet_Lava.tscn")

export(NodePath) var lava_path
var lava:Node2D
var starting_lava_position:Vector2

var gun_points = []

func _ready():
	for n in get_children():
		if n is Position2D:
			gun_points.append(n.position)
			
	if lava_path:
		lava = get_node(lava_path)
		starting_lava_position = lava.position
		
	$CanvasLayer/Label.visible = $CanvasLayer/Label.visible and OS.is_debug_build()

func fire_spread(root:Node2D, startPos:Vector2):
	var startingAngle = Vector2(-8,0)
	for j in range(5):
		var bi = b2.instance()
		root.add_child(bi)
		bi.position = startPos
		#bi.global_position = startPos
		#bi.CubicSpread=Vector2((j-2)*2,0)
		#var newAngle = startingAngle
		#newAngle.x=newAngle.x+(j-2)
		bi.special_type = 5
		bi.init(Vector2(-5,0),j==0)

func fire_bullet(root:Node2D, position:Vector2, velocity:Vector2):
	var bi = b1.instance()
	bi.position = position
	root.add_child(bi)
	bi.init(velocity)
		

func _physics_process(delta):
	if !enabled:
		if player==null: #TODO: This should probably be in the base class
			player=get_node("/root/Node2D/").get_player()
		return
		
	var player_block_position:Vector2 = get_room_position_of_node(player)/64.0
	$CanvasLayer/Label.text = String(player_block_position)

	
	if health <= 15:
		starting_lava_position.y -= delta*10
		lava.position.y = min(lava.position.y, starting_lava_position.y)
	
	if idleTime > 0:
		idleTime-=delta
		move_and_slide(Vector2(0,200))
		#if curState == STATE.IDLE:
		return
		#move_and_slide(Vector2(0,200))
			
		
	match curState:
		STATE.IDLE:
			#if next_state == null:
			if health > 20:
				if randi()%2==0 and player_block_position.y < 7:
					#This should only trigger if you're on the top platforms
					next_state = STATE.SPAWN_LAVA
				else:
					next_state = STATE.TELEPORT_IN_SETUP
				
			else:
				if prev_state == STATE.TELEPORT_LAVA:
					next_state = STATE.SPAWN_ENEMIES
				elif randi()%2==0 and player_block_position.y < 7:
					next_state = STATE.TELEPORT_LAVA
				else:
					next_state = STATE.TELEPORT_IN_SETUP
			
			prev_state = next_state
			curState = STATE.TELEPORT_OUT
		STATE.TELEPORT_OUT:
			sprite.play("warpOut")
			idleTime=15.0/60.0
			curState = next_state
		STATE.TELEPORT_IN_SETUP:
			#is_reflecting = true
			var new_position:Vector2 = Vector2.ZERO
			if player_block_position.y < 7:
				new_position.y = 6
			else:
				new_position.y = 10.2
				
			if player_block_position.x < 4: #If near left
				new_position.x = 17
			elif player_block_position.x > 16: #If near right
				new_position.x = 2
			else:
				#Random
				if randi()%2==0:
					new_position.x = 17
				else:
					new_position.x = 2
			set_room_position(new_position*64)
#			if Rect2(1,1,4.5,3).has_point(player_block_position):
#				set_room_position(Vector2(10,5.2)*64)
#			elif Rect2(7,1,6,6).has_point(player_block_position):
#				set_room_position(Vector2(10,5.2)*64)
#			elif player_block_position.x < 7:
#				set_room_position(Vector2(10,10.2)*64)
#			elif player_block_position.x > 13:
#				set_room_position(Vector2(10,10.2)*64)
			
			facing = DIRECTION.LEFT if get_room_position_of_node(player).x < get_room_position().x else DIRECTION.RIGHT
			sprite.flip_h = (facing == DIRECTION.RIGHT)
			idleTime = .1
			curState += 1
			next_state = STATE.READY_SHOOT
		STATE.TELEPORT_IN:
			$TeleportSound.play()
			sprite.play("warpIn")
			idleTime = .2
			curState = next_state
			is_reflecting = false
		STATE.READY_SHOOT:
			sprite.play("guns")
			idleTime = .85
			curState += 1
		STATE.SHOOT_HORIZONTAL:
			#fire_spread(get_parent(), position)
			
			var t:SceneTreeTween = create_tween()
			for j in range(16):
				#print(gun_points[j])
				t.tween_callback(self,"fire_bullet",[get_parent(), position + gun_points[j%4]*Vector2(-facing,1), Vector2(facing*13, 0)]).set_delay(.05)
				
			curState = 0
			idleTime = 1
		STATE.SPAWN_ENEMIES:
			var room = get_parent().get_parent()
			for i in range(2):
				var inst:Node2D = enemy_to_spawn.instance()
				#$CheckEnemiesKilled.add_enemy(inst)
				var random_position:Vector2 = Vector2(rand_range(1,9), rand_range(2,10))
				if player_block_position.x < 10:
					random_position.x += 10
				
				#random_position.y
				
				inst.position = random_position*64.0
				#inst.sleepTime = .5
				var ex = explosion.instance()
				ex.get_node("s1").volume_db = -80
				ex.position = inst.position
				room.add_child(inst)
				room.add_child(ex)
			idleTime = 1
			curState = STATE.TELEPORT_IN_SETUP
			next_state = STATE.SHOOT_HORIZONTAL
			#curState = STATE.IDLE
		STATE.SPAWN_LAVA:
			var room = get_parent().get_parent()
			
			if progress >= 3.0:
				curState = STATE.IDLE
				progress = 0.0
				randomize()
			else:
				var inst:Node2D = lava_drop.instance()
				if progress < 2.0:
					while true:
						var random_position:Vector2 = Vector2(rand_range(1,19), 3)
						if random_position.x > player_block_position.x+1 or random_position.x < player_block_position.x-1:
							inst.position = random_position*64.0
							break
				else:
					inst.position = Vector2(player_block_position.x, 3)*64.0
				room.add_child(inst)
				progress+=1.0
			idleTime = .4
			
			
			
		STATE.TELEPORT_LAVA:
			set_room_position(Vector2(6,-5)*64)
			#is_reflecting = true
			curState = STATE.RISE_LAVA
			$LavaRising.play()
			progress = 0.0
#			set_room_position(Vector2(2,3.8)*64)
#			facing = DIRECTION.RIGHT
#			sprite.flip_h = (facing == DIRECTION.RIGHT)
#			idleTime = .1
#			curState = STATE.TELEPORT_IN
#			next_state = STATE.RISE_LAVA
		STATE.RISE_LAVA:
			move_and_slide(Vector2(0,200))
			if progress > .4:
				$LavaRising.stop()
			else:
				progress+=delta
				
			var lava_block_pos = (get_room_position_of_node(lava)-lava.top_left_position).y/64.0
			#$CanvasLayer/Label.text = String(lava_block_pos)
			var lava_top = 10.75
			if Globals.playerData.gameDifficulty > Globals.Difficulty.EASY:
				lava_top = 9.9
			
			if lava_block_pos > 14.0:
				lava.position.y -= delta*40
			elif lava_block_pos > 12.0:
				lava.position.y -= delta*75
			elif lava_block_pos > lava_top:
				lava.position.y -= delta*125
			else:
				$LavaSound.play()
				curState = STATE.LOWER_LAVA
		STATE.LOWER_LAVA:
			move_and_slide(Vector2(0,200))
			if lava.position.y < starting_lava_position.y:
				lava.position.y += delta*125
			else:
				$LavaRising.stop()
				curState = STATE.TELEPORT_IN_SETUP
				#next_state = STATE.TELEPORT_IN_SETUP
