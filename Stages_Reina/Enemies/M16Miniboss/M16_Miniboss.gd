extends "res://Stages/EnemyBaseScript.gd"

var bullet = preload("res://Stages_Reina/Enemies/bulletDinergate.tscn")
var grenade = preload("res://Stages_Reina/Enemies/EnemyGrenade.tscn")

#var leftStageBound 

enum STATES {
	RUNNING1,
	SHOOTING,
	RUNNING2,
	THROWING,
}
var curState=0
var numShots = 0

var player
func _ready():
	player = get_node_or_null("/root/Node2D/Player")
	if !is_instance_valid(player):
		print("M16: No player!")

var timer:float=0.0
var timeToRun:float=0.0
func _physics_process(delta):
	
	#$Label.text=String(is_on_floor())
	
	if timer>=0:
		timer-=delta
		return
	
	match curState:
		STATES.RUNNING1,STATES.RUNNING2:
			var velocity = move_and_slide(Vector2(facing*300,200), Vector2(0, -1), true)
			if is_on_floor():
				if velocity.x > 1 or velocity.x < -1:
					sprite.set_animation("walk")
				else:
					sprite.set_animation("default")
			if is_on_wall():
				facing=facing*-1
			timeToRun+=delta
			if timeToRun>2:
				timeToRun=0
				curState+=1
		STATES.SHOOTING:
			sprite.set_animation("shoot")
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
			sprite.set_animation("throw")
			facing=1 if (player.global_position.x > global_position.x) else -1
			#if sprite.frame==1:
			var a = [grenade.instance(),grenade.instance(),grenade.instance()]
			for i in range(a.size()):
				var bi = a[i]
				var pos = position + Vector2(15*facing, -16)
				bi.position = pos
				get_parent().add_child(bi)
				bi.init(facing,Vector2(Vector2(5*facing*(i+1),-5)))
			for i in range(a.size()):
				self.add_collision_exception_with(a[i])# Make bullet and this not collide
				a[i].add_collision_exception_with(a[0])
				a[i].add_collision_exception_with(a[1])
				a[i].add_collision_exception_with(a[2])
			timer=1
			curState=0
	sprite.flip_h=facing==DIRECTION.RIGHT
	sprite.offset.x=25*facing
