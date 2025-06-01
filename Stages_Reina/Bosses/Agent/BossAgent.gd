extends "res://Stages_Reina/Bosses/BossBase.gd"

enum STATE {
	IDLE,
	TELEPORT_OUT,
	TELEPORT_IN_SETUP,
	TELEPORT_IN,
	READY_SHOOT,
	SHOOT_HORIZONTAL,
	TELEPORT_LAVA,
	RISE_LAVA,
	LOWER_LAVA
}
var curState = STATE.IDLE
var next_state = STATE.IDLE
var idleTime:float =0

var player:KinematicBody2D

const b1 = preload("res://Stages_Reina/Bosses/Agent/bulletAgent.tscn")
const b2 = preload("res://Stages_Reina/Enemies/bulletDanmaku.tscn")

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
		
	var player_block_position:Vector2 = get_room_position_of_node(player)/64
	#$CanvasLayer/Label.text = String(player_block_position)

	
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
				next_state = STATE.TELEPORT_IN_SETUP
			else:
				next_state = STATE.TELEPORT_LAVA
			
			curState = STATE.TELEPORT_OUT
		STATE.TELEPORT_OUT:
			sprite.play("warpOut")
			idleTime=15.0/60.0
			curState = next_state
		STATE.TELEPORT_IN_SETUP:
			if Rect2(1,1,4.5,3).has_point(player_block_position):
				set_room_position(Vector2(10,5.2)*64)
			elif Rect2(7,1,6,6).has_point(player_block_position):
				set_room_position(Vector2(10,5.2)*64)
			elif player_block_position.x < 7:
				set_room_position(Vector2(10,10.2)*64)
			elif player_block_position.x > 13:
				set_room_position(Vector2(10,10.2)*64)
			
			facing = DIRECTION.LEFT if get_room_position_of_node(player).x < get_room_position().x else DIRECTION.RIGHT
			sprite.flip_h = (facing == DIRECTION.RIGHT)
			idleTime = .1
			curState += 1
			next_state = STATE.READY_SHOOT
		STATE.TELEPORT_IN:
			sprite.play("warpIn")
			idleTime = .2
			curState = next_state
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
		STATE.TELEPORT_LAVA:
			set_room_position(Vector2(6,-5)*64)
			is_reflecting = true
			curState = STATE.RISE_LAVA
#			set_room_position(Vector2(2,3.8)*64)
#			facing = DIRECTION.RIGHT
#			sprite.flip_h = (facing == DIRECTION.RIGHT)
#			idleTime = .1
#			curState = STATE.TELEPORT_IN
#			next_state = STATE.RISE_LAVA
		STATE.RISE_LAVA:
			move_and_slide(Vector2(0,200))
			var lava_block_pos = (get_room_position_of_node(lava)-lava.top_left_position).y/64.0
			$CanvasLayer/Label.text = String(lava_block_pos)
			if lava_block_pos > 14.0:
				lava.position.y -= delta*40
			elif lava_block_pos > 12.0:
				lava.position.y -= delta*75
			elif lava_block_pos > 10.75:
				lava.position.y -= delta*125
			else:
				curState = STATE.LOWER_LAVA
		STATE.LOWER_LAVA:
			move_and_slide(Vector2(0,200))
			if lava.position.y < starting_lava_position.y:
				lava.position.y += delta*125
			else:
				curState = STATE.TELEPORT_IN_SETUP
				#next_state = STATE.TELEPORT_IN_SETUP
