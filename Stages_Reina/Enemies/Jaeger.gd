extends "res://Stages/EnemyBaseScript.gd"

enum STATES {
	WAIT = 0,
	INIT_SHOOT,
	SHOOTING,
	TURNING
}


var curState = 0
#onready var charge = $charge

#Testing
#var bullet = preload("res://Stages_Reina/Enemies/nemeum homing shot.tscn")
var bullet = preload("res://Stages_Reina/Enemies/bulletDinergate.tscn")
const bulletSpeed:float = 10.0
const cooldown:float = 1.0

var player:KinematicBody2D
var timer:float = 3.0 #Starting cooldown

func _physics_process(delta):
	if not is_instance_valid(player):
		player=get_node("/root/Node2D").get_player()
	if timer>0:
		timer-=delta
		return
	
	match curState:
		STATES.WAIT:
			sprite.play("default")
			timer=cooldown
			curState=STATES.SHOOTING
			pass
		#STATES.INIT_SHOOT:
		#	
		STATES.SHOOTING:
			sprite.play("shoot")
			#$Area2D.monitoring = true
			var bi = bullet.instance()
			var pos = position
			
			bi.position = pos+Vector2(facing*90,10)
			get_parent().add_child(bi)
			#Have to adjust it a little since the player's position is at the top left of the collision box,
			#not the center.
			#charge.position should be taken into account but it's messing it up right now
			var v:Vector2 = player.global_position-global_position + Vector2(30,40)
			v=v.normalized()*bulletSpeed
			if facing==DIRECTION.LEFT and player.global_position.x > global_position.x-200:
				v.x=bulletSpeed*-1
			elif facing==DIRECTION.RIGHT and player.global_position.x < global_position.x+200:
				v.x=bulletSpeed
			#v*=3
			#if abs(v.x) > 100:
			#	v*=abs(v.x)/100
			#print(v)
			#v.x=min(player.global_position.x-global_position.x,500)
			#v.y=player.global_position.y+(-1 if player.global_position.y<0 else 1)*abs(player.global_position.x-global_position.x-v.x)
			#print(v.normalized())
			bi.init(v)
			
			#self.add_collision_exception_with(bi)# Make bullet and this not collide
			#sleepTime=1
			#print("Fired bullet.")
			timer=1
			curState=STATES.WAIT
				
				
			
		STATES.TURNING:
			if sprite.frame==5:
				curState=STATES.WAIT
			elif sprite.frame>=3:
				sprite.flip_h=facing==DIRECTION.RIGHT
				if sprite.animation=="turningUp":
					sprite.offset = Vector2(-3*facing,-11)
				else:
					sprite.offset=Vector2(facing,-1)
