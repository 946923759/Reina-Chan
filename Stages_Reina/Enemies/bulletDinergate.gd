extends KinematicBody2D

onready var vis = $VisibilityNotifier2D
onready var shootSound = $ShootSound
onready var reflectSound = $ReflectSound

var DAMAGE_AMOUNT:int=1

func _ready():
	set_process(false)
	set_physics_process(false)
	#$ShootSound.play()
	

#For KinematicBody2D only.
var movement: Vector2
func init(t_movement):
	movement = t_movement
	set_physics_process(true)
	
	# warning-ignore:return_value_discarded
	$Area2D.connect("body_entered",self,"objectTouched")
# warning-ignore:return_value_discarded
	#$Area2D.connect("body_exited",self,"clearLastTouched")
	#Why is this called on init and not _ready()?
	shootSound.play()

func objectTouched(obj):
	#print("intersecting!")
	if obj.has_method("player_touched"): #If enemy touched player
		#lastTouched = obj
		obj.call("player_touched",self,1)
		#print("hurt player")
	#elif obj.has_method("enemy_touched"): #If enemy touched bullet
	#	obj.call("enemy_touched",self)


var cooldown:float = 0.5
#For KinematicBody2D only.
func _physics_process(_delta):
	cooldown -= _delta
	if !vis.is_on_screen() and cooldown<=0:
		#print("Bullet "+name+" exited screen")
		queue_free()
	var collision = move_and_collide(movement)
	if collision != null:
		#print(String(OS.get_ticks_msec())+" Bullet collided!")
		var obj = collision.collider
		if false: #obj.get("is_reflecting") == true
			#print(String(OS.get_ticks_msec())+" Bullet reflected!")
			reflectSound.play()
			if obj.has_method("add_collision_exception_with"):
				obj.add_collision_exception_with(self)
			movement = Vector2(movement.x*-1,-10)
			move_and_collide(movement)
		else:
			if obj.has_method("player_touched"): #If enemy touched player
				obj.call("player_touched",self,DAMAGE_AMOUNT)
			queue_free()
		
