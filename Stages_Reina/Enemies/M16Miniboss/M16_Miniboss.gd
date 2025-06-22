extends "res://Stages/EnemyBaseScript.gd"

var bullet = preload("res://Stages_Reina/Enemies/bulletDinergate.tscn")
var grenade = preload("res://Stages_Reina/Enemies/EnemyGrenade.tscn")

#var leftStageBound 

enum STATES {
	RUNNING1,
	SHOOTING,
	RUNNING2,
	THROWING,
	JUMPING_AND_SHOOTING,
	DEAD1,
	DEAD2,
	DEAD3
}
var curState=STATES.RUNNING1
var numShots = 0

var player
onready var startingPosition:Vector2=self.position
func _ready():
	#player = get_node_or_null("/root/Node2D").get_player()
	#if !is_instance_valid(player):
	#	print("M16: No player!")
	pass

var timer:float=0.0
var timeToRun:float=0.0
var gravity:float=0.0

func _physics_process(delta):
	if !is_instance_valid(player):
		player = get_node_or_null("/root/Node2D").get_player()
		return
	#	print("M16: No player!")
	
	#$Label.text=String(is_on_floor())
	
	if timer>=0:
		timer-=delta
		return
	if curHealth<=0:
		if curState<5:
			gravity=-200
			curState=STATES.DEAD2
			
			#To signify that she died
			var e
			if use_large_explosion:
				e = explosion.instance()
			else:
				e = smallExplosion.instance()	
			e.position = position
			#e.position.y-=32
			get_parent().add_child(e)
			
		match curState:
			#STATES.DEAD1:
			#	gravity=-200
			#	curState=STATES.DEAD2
			STATES.DEAD2:
				sprite.set_animation("Hurt")
				move_and_slide(Vector2(facing*-200,gravity), Vector2(0, -1), true)
				gravity += 3500 * delta
				if sprite.frame==2 and is_on_floor():
					timeToRun=0
					gravity=-200
					
					set_collision_layer_bit(1,false)
					set_collision_mask_bit(1,false)
					set_collision_mask_bit(4,false)
					curState=STATES.DEAD3
			STATES.DEAD3:
				sprite.set_animation("JumpStart")
				move_and_slide(Vector2(0,gravity), Vector2(0, -1), true)
				gravity-=2500*delta
				timeToRun+=delta
				#Hardcoded so she checks about 12 blocks above her starting position
				#it would be better to use the tile scale
				#but I don't care
				if timeToRun>10 or position.y < startingPosition.y-600:
					die2()
		return
	
	match curState:
		STATES.RUNNING1,STATES.RUNNING2:
			var velocity = move_and_slide(Vector2(facing*300,200), Vector2(0, -1), true)
			if is_on_floor():
				if velocity.x > 1 or velocity.x < -1:
					sprite.set_animation("WalkLoop")
				else:
					sprite.set_animation("Idle")
			if is_on_wall():
				facing=facing*-1
			timeToRun+=delta
			if timeToRun>2:
				timeToRun=0
				curState+=1
		STATES.JUMPING_AND_SHOOTING:
			if timeToRun>6 and is_on_floor():
				timeToRun=0
				curState=STATES.THROWING
			else:
				var velocity = move_and_slide(Vector2(facing*200,gravity), Vector2(0, -1), true)
				gravity+=delta*1200
				if is_on_floor():
					gravity=-600
					timer=.05
					sprite.set_animation("Idle")
				elif gravity > 0:
					sprite.set_animation("Falling")
				else:
					sprite.set_animation("JumpStart")
				if is_on_wall():
					facing=facing*-1
				timeToRun+=delta
		STATES.SHOOTING:
			sprite.set_animation("IdleShoot")
			facing=1 if (player.global_position.x > global_position.x) else -1
			if numShots <3:
				var bi = bullet.instance()
				var pos = position + Vector2(30*facing, 0)
				
				bi.position = pos
				get_parent().add_child(bi)
				bi.init(Vector2(5*facing,0))
				
				self.add_collision_exception_with(bi)# Make bullet and this not collide
				#sleepTime=1
				#print("Fired bullet.")
				timer=.1
				numShots+=1
			else:
				numShots=0
				curState+=1
		STATES.THROWING:
			sprite.set_animation("Grenade")
			facing=1 if (player.global_position.x > global_position.x) else -1
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
			timer=1
			if curHealth<maxHealth/2:
				curState=STATES.JUMPING_AND_SHOOTING
			else:
				curState=0
	sprite.flip_h=facing==DIRECTION.LEFT
	#sprite.offset.x=25*facing

#Overrides base class because lmao
func die():
	return
	
func die2():
	print(self.name+" queued to be killed.")
	isAlive = false
	set_physics_process(false)
	sprite.visible = false
	sprite.stop()
	
	emit_signal("enemy_killed")
	self.queue_free()
