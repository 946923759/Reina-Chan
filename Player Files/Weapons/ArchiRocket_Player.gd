extends KinematicBody2D

# warning-ignore:unused_class_variable
var reflected = false

onready var vis = $VisibilityNotifier2D
onready var reflectSound = $ReflectSound

enum DIRECTION {LEFT=-1,RIGHT=1}
var shouldGoTowards:int=DIRECTION.RIGHT


onready var sprite = $AnimatedSprite
var explosion = preload("res://Stages/EnemyExplosion.tscn")
var smallExplosion = preload("res://Stages/EnemyExplodeSmall.tscn")

func init(startingDirection=DIRECTION.RIGHT):
	#shouldGoTowards=DIRECTION.LEFT if facingLeft else DIRECTION.RIGHT
	shouldGoTowards=startingDirection
	handle_sprite_direction()

func handle_sprite_direction():
	sprite.flip_h=(shouldGoTowards==DIRECTION.RIGHT)

func _ready():
	#assert(curHealth)
	#sprite.flip_h = (shouldGoTowards == DIRECTION.RIGHT)
	handle_sprite_direction()
	set_physics_process(true);
# warning-ignore:return_value_discarded
	$Area2D.connect("body_entered",self,"enemy_touched")
	#add_collision_exception_with($Area2D)
# warning-ignore:return_value_discarded
	#$Area2D.connect("body_exited",self,"clearLastTouched")
# warning-ignore:return_value_discarded
	#$Area2D.connect("area_entered",self,"objectTouched")
	sprite.play()



#The duration that the sprite has been colored white.
var lastChange:Vector2
func _physics_process(_delta):
	#move_and_slide(Vector2(0,300))

	handle_sprite_direction()
	
	lastChange.y=0
	if Input.is_action_pressed("ui_down"):
		lastChange.y = 2
	elif Input.is_action_pressed("ui_up"):
		lastChange.y = -2
	lastChange.x+=shouldGoTowards
	
	
	
	if !vis.is_on_screen():
		queue_free()
	var collision = move_and_collide(lastChange)
	if !reflected and collision != null:
		#print(String(OS.get_ticks_msec())+" Bullet collided!")
		var obj = collision.collider
		enemy_touched(obj)

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
		print("Reflected")
		reflected=true
		#print(String(OS.get_ticks_msec())+" Bullet reflected!")
		reflectSound.play()
		killSelf(false,true)
	else:
		if obj.has_method("damage"):
			obj.call("damage",2,Globals.Weapons.Architect)
		killSelf()


#We want an isAlive var so we can play the death animation only one time
var isAlive = true

func killSelf(_bigExplode=false,_noSound=false):
	#print(self.name+" queued to be killed.")
	isAlive = false
	set_physics_process(false)
	sprite.visible = false
	sprite.stop()
	#dropRandomItem()
	
	
	var e
	if false: #I don't like it
		e = explosion.instance()
	else:
		e = smallExplosion.instance()	
	e.position = position
	get_parent().add_child(e)
	
	self.queue_free()
