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

var gravity:Vector2=Vector2(0,0)

func _physics_process(delta):
	totalTime+=delta
	cooldown-=delta
	
	if totalTime>=15:
		killSelf(true)
		return
	
	move_and_slide(Vector2(dir*300,220).rotated(rotation)+gravity,Vector2(0,-1),false)
	#$Label.text=String(get_slide_count())
	
	if !is_on_floor() and !is_on_ceiling() and !is_on_wall():
		gravity.y+=delta*500
		if gravity.y>100:
			rotation_degrees=0
	else:
		gravity.y=0
	
	#if get_slide_count()>3:
	#	position.x+=50
	if raycast.is_colliding() and cooldown<=0:
		self.rotation_degrees-=90*dir
		gravity.y=0
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
			# TODO: Damage to reflection shields should be done differently...?
			try_drain_reflection_health(obj)
	else:
		if obj.has_method("damage"):
			obj.call("damage",2,Globals.Weapons.Ouroboros)
		killSelf()
		
func try_drain_reflection_health(obj):
	if obj.has_method("drain_reflection_health"):
		obj.call("drain_reflection_health",2,Globals.Weapons.Ouroboros)

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
