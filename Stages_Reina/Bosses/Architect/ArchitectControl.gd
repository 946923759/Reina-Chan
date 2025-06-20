extends "res://Stages_Reina/Bosses/BossBase.gd"

var rocket = preload("res://Stages_Reina/Bosses/Architect/ArchiRocket_v2.tscn")

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
#Sets starting movement, so if architect is facing left, she will
#move left first. Otherwise if she is facing right, she will move right.
onready var shouldMoveLeft:bool = (facing==DIRECTION.LEFT)
var tempVelocity:Vector2

onready var rocketSound = $LaunchRocket
#var is_on_floor_:bool
func _physics_process(delta):
	if not enabled:
		return
	
	sprite.playing=true
	sprite.flip_h = (facing == DIRECTION.RIGHT)
	
	if curState==STATE.IDLE:
		sprite.set_animation("Idle")
		idleTime+=delta
		if idleTime > .2:
			if health<=14 and randi()%2==0:
				curState=STATE.JUMPING
			else:
				curState = STATE.MOVING
	elif curState==STATE.SHOOTING1:
		sprite.set_animation("Fire")
		if sprite.frame==2:
			shots+=1
			rocketSound.play()
			var e = rocket.instance()
			var pos = position + Vector2(67*facing, -40)
			
			e.position = pos
			get_parent().add_child(e)
			
			#DIRECTION enum in the rocket, homing rockets, and if rockets should speed up
			e.init(3 if facing==-1 else 5,false,health<=14) 
			
			add_collision_exception_with(e) # Make bullet and this not collide
# warning-ignore:return_value_discarded
			move_and_slide(Vector2(facing*-200,200))
			curState=STATE.SHOOTING2
	elif curState==STATE.SHOOTING2:
		idleTime+=delta
		if shots < 3:
			if idleTime > .2:
				idleTime=0
				curState=STATE.SHOOTING1
		else:
			if idleTime > .4:
				shots=0
				idleTime=0
				sprite.play("Idle")
				curState=STATE.IDLE
			elif idleTime > .3:
				sprite.set_animation("ReturnToIdle")
	elif curState==STATE.MOVING:
		sprite.set_animation("WalkLoop")
		#TODO: There has GOT to be a better way to code this
		if shouldMoveLeft:
			facing=DIRECTION.LEFT
			# How can we know how much to walk by?
			# The room is width of 1152 (subtracted walls), but each block is 64 pixels wide
			# so subtract 2*64+32 from each side
			# note that architect is centered so add 32 pixels
			
			if get_room_position().x >= 3*64+32:
				#player run speed = 350
# warning-ignore:return_value_discarded
				move_and_slide(Vector2(facing*500,200))
			else:
				shouldMoveLeft=!shouldMoveLeft
				facing=facing*-1
				curState=STATE.IDLE2
		else:
			facing=DIRECTION.RIGHT
			if get_room_position().x <= ROOM_WIDTH*64-3*64-32:
# warning-ignore:return_value_discarded
				move_and_slide(Vector2(facing*500,200))
			else:
				shouldMoveLeft=!shouldMoveLeft
				facing=facing*-1
				curState=STATE.IDLE2
	elif curState==STATE.IDLE2:
		idleTime+=delta
		if idleTime>.2:
			idleTime=0
			curState = STATE.SHOOTING1
	elif curState==STATE.JUMPING:
		sprite.set_animation("Jump")
		tempVelocity=Vector2(facing*350,-1400)
		curState=STATE.JUMPING2
	elif curState==STATE.JUMPING2:
		tempVelocity=move_and_slide(tempVelocity,Vector2(0, -1))
		tempVelocity.y += 2500 * delta
		if is_on_floor():
			shots=0
			curState=STATE.IDLE
			facing=facing*-1
		elif tempVelocity.y>600 and shots < 3:
			curState=STATE.SHOOTDOWN
		elif tempVelocity.y>-400:
			sprite.set_animation("rocketDown")
	elif curState == STATE.SHOOTDOWN:
		shots+=1
		$LaunchRocket.play()
		var e = rocket.instance()
		var pos = position + Vector2(67*facing, 40)
		
		e.position = pos
		get_parent().add_child(e)
		
		#DIRECTION enum in the rocket, homing rockets, and if rockets should speed up
		e.init(7,true,true)
		
		add_collision_exception_with(e) # Make bullet and this not collide
		tempVelocity=Vector2(facing*350,-500)
		curState=STATE.JUMPING2

