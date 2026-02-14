extends Area2D
signal enemy_killed

enum STATES {
	WAIT = 0,
	SHOOTING,
	TURNING
}

const OFFSETS = [
	Vector2(1,-1),   #normal
	Vector2(3,-11), #Angle
	Vector2(-1,-7)  #Upwards
]

const CHARGE_OFFSETS = {
	"charging": Vector2(92,-52),
	"chargingAngle" : Vector2(92,-108),
	"chargingUp": Vector2(0,-160)
	
}

var curState = 0
var player:KinematicBody2D
var timer:float = 0.0

export(NodePath) var bullet_attach_path
var bullet_ActorFrame

export(int, 1, 50) var maxHealth = 10
var curHealth;

#This is only if you didn't override objectTouched!
#There might be cases where you need to override it.
export(int,0,25) var player_damage = 1

# is_reflecting is handled by the weapon, not the enemy
# warning-ignore:unused_class_variable
var is_reflecting = false;

#-1 to move left, 1 to move right
enum DIRECTION {LEFT = -1, RIGHT = 1}
export(DIRECTION) var facing = DIRECTION.LEFT

var lastTouched
#The duration that the sprite has been colored white.
var whiteTime = 0

onready var sprite:AnimatedSprite = $AnimatedSprite
onready var hurtSound:AudioStreamPlayer2D = $HurtSound
onready var shader = $AnimatedSprite.material
onready var charge:AnimatedSprite = $charge

var bullet = preload("res://Stages_Reina/Enemies/nemeum homing shot.tscn")
var explosion = preload("res://Stages/EnemyExplosion.tscn")

func _ready():
	if facing==DIRECTION.RIGHT: #Offset assumes facing left so reverse it
		sprite.offset.x*=-1
	sprite.flip_h = (facing == DIRECTION.RIGHT)
	curHealth = maxHealth
	
	if not bullet_attach_path:
		bullet_ActorFrame = get_parent()
	else:
		bullet_ActorFrame = get_node(bullet_attach_path)
	
	self.connect("body_entered",self,"objectTouched")
	self.connect("area_entered",self,"areaTouched")
	self.connect("body_exited",self,"clearLastTouched")

func reset():
	set_physics_process(false)
	charge.visible = false
	sprite.set_animation('default')
	sprite.offset=Vector2.ZERO
	curState = 0

func _process(delta):
	"""
	You CANNOT use a shader parameter for this, setting a shader param
	affects all objects using the same shader. Therefore you have to
	turn the shader off and on like this.
	However, you can swap shaders by assigning one to the enemy node, and
	when the enemy is hurt it will swap to the glow shader.
	The glow shader also supports alpha masking, but due to the global
	shader issue you'd probably want all the alpha mask values to be the same.
	"""
	if !sprite.use_parent_material:
		whiteTime += delta
		if whiteTime > .1:
			sprite.use_parent_material = true

func _physics_process(delta):
	if not is_instance_valid(player):
		player=get_node("/root/Node2D").get_player()
	
	if timer>0:
		timer-=delta
		return
	
	match curState:
		STATES.WAIT:
			#sprite.set_animation("charging")
			charge.frame=0
			#charge.visible=false
			curState=STATES.SHOOTING
			#charge.position.x = 80*facing
			pass
		STATES.SHOOTING:
			if charge.frame==7:
				charge.visible=false
				#$Area2D.monitoring = true
				var bi = bullet.instance()
				var pos = global_position + charge.position
				
				bullet_ActorFrame.add_child(bi)
				bi.global_position = pos
				#Have to adjust it a little since the player's position is at the top left of the collision box,
				#not the center.
				#charge.position should be taken into account but it's messing it up right now
				var v:Vector2 = player.global_position-global_position + Vector2(30,40)
				v=v.normalized()*400
				if facing==DIRECTION.LEFT and player.global_position.x > global_position.x:
					v.x=-400
				elif facing==DIRECTION.RIGHT and player.global_position.x < global_position.x:
					v.x=400
				#v*=3
				#if abs(v.x) > 100:
				#	v*=abs(v.x)/100
				#print(v)
				#v.x=min(player.global_position.x-global_position.x,500)
				#v.y=player.global_position.y+(-1 if player.global_position.y<0 else 1)*abs(player.global_position.x-global_position.x-v.x)
				#print(v.normalized())
				bi.init(v, 2)
				
				#self.add_collision_exception_with(bi)# Make bullet and this not collide
				#sleepTime=1
				#print("Fired bullet.")
				timer=.2
				#Surely there is a better way to do this?
				match sprite.animation:
					"charging":
						sprite.set_animation("fired")
					"chargingUp":
						sprite.set_animation("firedUp")
					"chargingAngle":
						sprite.set_animation("firedAngle")
				
				if (
					(player.global_position.x > global_position.x and facing==DIRECTION.LEFT) 
				 or (player.global_position.x < global_position.x and facing==DIRECTION.RIGHT)
				):
					curState=STATES.TURNING
					if sprite.animation=="firedUp":
						sprite.set_animation("turningUp")
						sprite.offset = Vector2(-3*facing,-11)
					else:
						sprite.set_animation("turning")
						sprite.offset=Vector2(facing,-1)
					facing*=-1
				else:
					timer=1
					curState=STATES.WAIT
					
			else:
				if (player.global_position.x > global_position.x-100
				and player.global_position.x < global_position.x+100
				and player.global_position.y+40 < global_position.y):
					sprite.set_animation("chargingUp")
					sprite.offset = Vector2(-3*facing,-11)
				elif facing==DIRECTION.LEFT and (player.global_position.x < global_position.x
				and player.global_position.y+40 < global_position.y-40):
					sprite.set_animation("chargingAngle")
					sprite.offset=Vector2(facing,-7)
				elif facing==DIRECTION.RIGHT and (player.global_position.x > global_position.x
				and player.global_position.y+40 < global_position.y):
					sprite.set_animation("chargingAngle")
					sprite.offset=Vector2(facing,-7)
				else:
					sprite.set_animation("charging")
					sprite.offset=Vector2(facing,-1)
				charge.position = CHARGE_OFFSETS[sprite.animation]
				charge.position.x*=facing
				charge.visible=true
		STATES.TURNING:
			if sprite.frame==5:
				curState=STATES.WAIT
			elif sprite.frame>=3:
				sprite.flip_h=facing==DIRECTION.RIGHT
				if sprite.animation=="turningUp":
					sprite.offset = Vector2(-3*facing,-11)
				else:
					sprite.offset=Vector2(facing,-1)

func objectTouched(obj):
	#print("intersecting!")
	if obj.has_method("player_touched"): #If this obj touched player
		lastTouched = obj
		obj.call("player_touched",self,player_damage)
	elif obj.has_method("enemy_touched"): #If this obj touched bullet from player
		obj.call("enemy_touched",self)

#Assume areas are bullets only, since players have a collision box
func areaTouched(obj):
	#objectTouched(obj.get_parent())
	var obj_parent = obj.get_parent()
	if obj_parent.has_method("enemy_touched"): #If enemy touched bullet
		obj_parent.call("enemy_touched",self)

func clearLastTouched(_obj):
	lastTouched=null
	
#We want an isAlive var so we can play the death animation only one time
var isAlive = true
#damage is called by the player weapon, so don't rename it.
func damage(amount,damageType=0):
	curHealth -= amount
	#print("Took damage!")
	if curHealth <= 0:
		if isAlive:
			die()
	else:
		#set false so the white tint shader will show up.
		hurtSound.play()
		sprite.use_parent_material = false
		whiteTime = 0

func die():
	print(self.name+" queued to be killed.")
	isAlive = false
	set_physics_process(false)
	sprite.visible = false
	sprite.stop()
	
	var e = explosion.instance()
	e.position = position
	get_parent().add_child(e)
	
	emit_signal("enemy_killed")
	
	self.queue_free()
