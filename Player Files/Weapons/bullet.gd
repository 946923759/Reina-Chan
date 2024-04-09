extends KinematicBody2D

onready var vis = $VisibilityNotifier2D
onready var reflectSound = $ReflectSound

var reflected = false
var damageType:int=0

func _ready():
	#It's already set true in the editor UI...
	#set_contact_monitor(true)
	#set_max_contacts_reported(1)
	
	#For RigidBody2D only.
	#self.connect("body_entered",self,"expire")
	#$Timer.start()
	#pass
	set_process(false)
	set_physics_process(false)
	

#For KinematicBody2D only.
var movement
func init(t_movement,t_damageType:int=0):
	movement = t_movement
	damageType=t_damageType
	set_physics_process(true)

#For KinematicBody2D only.
func _physics_process(_delta):
	if !vis.is_on_screen():
		queue_free()
	var collision = move_and_collide(movement)
	if !reflected and collision != null:
		#print(String(OS.get_ticks_msec())+" Bullet collided!")
		var obj = collision.collider
		enemy_touched(obj)

#obj is the node of the collided object.
#func expire(obj):
#	if obj.has_method("hit_by_bullet"):
#		obj.call("hit_by_bullet")
#	#print("Bullet hit something")
#	queue_free()

# If bullet touched an enemy, the enemy hitbox will call this function.
# Why does the enemy need a hitbox? Because collision won't happen unless
# it's on the exact frame...
func enemy_touched(obj):
	enemy_touched_alt(obj,obj.get("is_reflecting") == true)

#Because I clearly don't know what I'm doing
func enemy_touched_alt(obj,reflect):
	if reflected:
		return
	#If whatever called this function can get damaged by a bullet, damage it.
	#TODO: This doesn't account for damage types or effectiveness or whatever...
	if reflect:
		reflected=true
		try_drain_reflection_health(obj)
		#print(String(OS.get_ticks_msec())+" Bullet reflected!")
		reflectSound.play()
		#if obj.has_method("add_collision_exception_with"):
		#	obj.add_collision_exception_with(self)
		
		# No reason not to do this, a reflected
		# bullet should no longer affect the
		# stage
		collision_layer = 0
		collision_mask = 0
		
		movement = Vector2(movement.x*-1,-10)
		move_and_collide(movement)
	else:
		if obj.has_method("damage"):
			obj.call("damage",1,damageType)
		queue_free()

func try_drain_reflection_health(obj):
	if obj.has_method("drain_reflection_health"):
		obj.call("drain_reflection_health",1,damageType)
