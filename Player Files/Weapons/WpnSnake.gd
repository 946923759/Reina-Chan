extends KinematicBody2D

onready var raycast:RayCast2D = $RayCast2D
onready var enemyRaycast = $EnemyCheck

var smallExplosion = preload("res://Stages/EnemyExplodeSmall.tscn")

var dir:int
func init(dir_:int):
	dir=dir_
	raycast.cast_to.x=40*dir_
	enemyRaycast.cast_to.x=35*dir_
	$Sprite.flip_h=dir_==1
	
var totalTime:float=0
var cooldown:float=0
func _physics_process(delta):
	totalTime+=delta
	cooldown-=delta
	
	if totalTime>=15:
		killSelf(true)
		return
	
	move_and_slide(Vector2(dir*300,220).rotated(rotation),Vector2(0,-1),false)
	if raycast.is_colliding() and cooldown<=0:
		self.rotation_degrees-=90*dir
		cooldown=.1

	#var obj=enemyRaycast.get_collider()
	#if obj:
	#	print("Collide!")
	#	enemy_touched_alt(obj,obj.get("is_reflecting") == true)
		
	
# If bullet touched an enemy, the enemy hitbox will call this function.
# Why does the enemy need a hitbox? Because collision won't happen unless
# it's on the exact frame...
func enemy_touched(obj):
	enemy_touched_alt(obj,obj.get("is_reflecting") == true)

#Because I clearly don't know what I'm doing
func enemy_touched_alt(obj,reflect):
	#If whatever called this function can get damaged by a bullet, damage it.
	#TODO: This doesn't account for damage types or effectiveness or whatever...
	if reflect:
		if cooldown<=0:
			self.dir*=-1
			self.rotation_degrees*=-1
			$Sprite.flip_h=dir==1
			cooldown=.1
	else:
		if obj.has_method("damage"):
			obj.call("damage",2,Globals.Weapons.Ouroboros)
		killSelf()

func killSelf(silent:bool=false):
	var e = smallExplosion.instance()
	e.position = position
	get_parent().add_child(e)
	if silent:
		e.sound.volume_db=-999
	self.queue_free()


func _on_VisibilityNotifier2D_screen_exited():
	#print("grenade freed")
	queue_free()
