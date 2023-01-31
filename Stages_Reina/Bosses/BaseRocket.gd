extends KinematicBody2D

export(int, 1, 50) var maxHealth = 3
var curHealth;
# warning-ignore:unused_class_variable
var is_reflecting = false;

enum DIRECTION {
	UPLEFT,   UP,   UPRIGHT,
	LEFT,           RIGHT
	DOWNLEFT, DOWN, DOWNRIGHT
}
var shouldGoTowards:int=DIRECTION.LEFT

#This is only if you didn't override objectTouched!
#There might be cases where you need to override it.
export(int,0,25) var damage_to_player = 1

export(int, FLAGS, 
	"Buster",
	"Architect",
	"Alchemist",
	"Ouroboros",
	"Scarecrow",
	"???",
	"???",
	"???",
	"???",
	"Glorylight",
	"Grenade") var weaponCanDamage=2047 #Use a calculator in programmer mode for this number


onready var sprite = $AnimatedSprite
onready var hurtSound = $HurtSound
var explosion = preload("res://Stages/EnemyExplosion.tscn")
var smallExplosion = preload("res://Stages/EnemyExplodeSmall.tscn")

func init(startingDirection_=DIRECTION.LEFT,canChangeDirections=false,_harderRockets=false):
	#shouldGoTowards=DIRECTION.LEFT if facingLeft else DIRECTION.RIGHT
	shouldGoTowards=startingDirection_
	#harderRockets=_harderRockets
	handle_sprite_direction()

func handle_sprite_direction():
	#if shouldGoTowards < DIRECTION.UP:
	#	sprite.flip_h=false
	
	#This can be optimized somewhat by checking if the direction is < down and
	#then turning off flip_h but it probably doesn't matter
	match shouldGoTowards:
		DIRECTION.LEFT:
			sprite.flip_h=false
			sprite.flip_v=false
			sprite.set_animation("default")
		DIRECTION.UPLEFT:
			sprite.flip_h=false
			sprite.flip_v=false
			sprite.set_animation("angle")
			sprite.rotation_degrees=0
		DIRECTION.UP:
			sprite.flip_h=false
			sprite.flip_v=false
			sprite.rotation_degrees=90
			sprite.set_animation("default")
		DIRECTION.UPRIGHT:
			sprite.flip_h=true
			sprite.flip_v=false
			sprite.set_animation("angle")
			sprite.rotation_degrees=0
		DIRECTION.RIGHT:
			sprite.flip_h=true
			sprite.flip_v=false
			sprite.set_animation("default")
			sprite.rotation_degrees=0
		DIRECTION.DOWNRIGHT:
			sprite.flip_h=true
			sprite.flip_v=true
			sprite.set_animation("angle")
			sprite.rotation_degrees=0
		DIRECTION.DOWN:
			sprite.flip_h=false
			sprite.flip_v=false
			sprite.set_animation("default")
			sprite.rotation_degrees=270
		DIRECTION.DOWNLEFT:
			sprite.flip_h=false
			sprite.flip_v=true
			sprite.set_animation("angle")
			sprite.rotation_degrees=0

func _ready():
	curHealth = maxHealth
	#assert(curHealth)
	#sprite.flip_h = (shouldGoTowards == DIRECTION.RIGHT)
	handle_sprite_direction()
	set_physics_process(true);
# warning-ignore:return_value_discarded
	$Area2D.connect("body_entered",self,"objectTouched")
# warning-ignore:return_value_discarded
	#$Area2D.connect("body_exited",self,"clearLastTouched")
# warning-ignore:return_value_discarded
	#$Area2D.connect("area_entered",self,"objectTouched")
	sprite.play()



#The duration that the sprite has been colored white.
var whiteTime = 0
var curVelocity:Vector2=Vector2(0,0)
func _physics_process(delta):
	handle_sprite_direction()

	var collision = move_and_collide(curVelocity) #Vector2(movX,movY)
	if collision != null:
		killSelf()
	
	if !sprite.use_parent_material:
		whiteTime += delta
		if whiteTime > .1:
			sprite.use_parent_material = true


#We want an isAlive var so we can play the death animation only one time
var isAlive = true
#damage is called by the player weapon, so don't rename it.
func damage(amount,_damageType:int=0):
	if !(weaponCanDamage & 1<<_damageType):
		return
	curHealth -= amount
	#print("Took damage!")
	if curHealth <= 0:
		if isAlive:
			killSelf()
	else:
		#set false so the white tint shader will show up.
		hurtSound.play()
		sprite.use_parent_material = false
		whiteTime = 0
		
func objectTouched(obj):
	#print("intersecting!")
	if obj.has_method("player_touched"): #If enemy touched player
		#lastTouched = obj
		obj.call("player_touched",self,damage_to_player)
		killSelf(true)
	elif obj.has_method("enemy_touched"): #If enemy touched bullet
		obj.call("enemy_touched",self)

#func clearLastTouched(_obj):
#	lastTouched=null
		
func killSelf(bigExplode=false):
	print(self.name+" queued to be killed.")
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
