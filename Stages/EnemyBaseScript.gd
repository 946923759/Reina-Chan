extends KinematicBody2D
signal enemy_killed

#export(int) var maxHealth;
export(int, 1, 50) var maxHealth = 10
var curHealth;

# is_reflecting is handled by the weapon, not the enemy
# warning-ignore:unused_class_variable
var is_reflecting = false;

#-1 to move left, 1 to move right
enum DIRECTION {LEFT = -1, RIGHT = 1}
export(DIRECTION) var facing = DIRECTION.LEFT
#export(bool) var is_left_or_right_aligned=false

#This is only if you didn't override objectTouched!
#There might be cases where you need to override it.
export(int,0,25) var player_damage = 1

#export(bool) var override_shape = false
export(Shape2D) var shapeOverride
export(Vector2) var collisionOffset = Vector2(0,0)
export(bool) var use_collision = true
export(bool) var use_large_explosion = false

onready var sprite:AnimatedSprite = $AnimatedSprite
onready var hurtSound:AudioStreamPlayer2D = $HurtSound
onready var shader = $AnimatedSprite.material

var explosion = preload("res://Stages/EnemyExplosion.tscn")
var smallExplosion = preload("res://Stages/EnemyExplodeSmall.tscn")

#This is needed to remove the shape later
var shapeOwnerID;

var lastTouched

func _ready():
	#assert(facing != 0)
	var shape;
	if shapeOverride != null:
		shape = shapeOverride
	else:
		shape = RectangleShape2D.new()
		assert(sprite.frames)
		#If you don't have a frameset named "default", it will crash here
		shape.set_extents(sprite.frames.get_frame("default",0).get_size())
	
	if facing==DIRECTION.RIGHT: #Offset assumes facing left so reverse it
		collisionOffset.x*=-1
		sprite.offset.x*=-1
	var area2D = $Area2D
	#var shapeID = shape.get_rid().get_id()
	area2D.shape_owner_add_shape(area2D.create_shape_owner(area2D), shape)
	if use_collision:
		shapeOwnerID = self.create_shape_owner(self)
		self.shape_owner_add_shape(shapeOwnerID, shape)
		self.shape_owner_set_transform(shapeOwnerID,Transform2D(Vector2(1,0),Vector2(0,1),collisionOffset))
	if OS.is_debug_build():
		self.get_node("CollisionShape2D FOR DEBUGGING ONLY").set_shape(shape)
		self.get_node("CollisionShape2D FOR DEBUGGING ONLY").position = collisionOffset

	#Set position
	area2D.position = collisionOffset
	
	
	#sprite.stop()
	#sprite.set_animation("default")
	#assert(maxHealth > 0)
	curHealth = maxHealth
	#assert(curHealth)
	sprite.flip_h = (facing == DIRECTION.RIGHT)
	set_physics_process(true);
# warning-ignore:return_value_discarded
	$Area2D.connect("body_entered",self,"objectTouched")
	$Area2D.connect("area_entered",self,"areaTouched")
# warning-ignore:return_value_discarded
	$Area2D.connect("body_exited",self,"clearLastTouched")
# warning-ignore:return_value_discarded
	#$Area2D.connect("area_entered",self,"objectTouched")
	sprite.play()


#The duration that the sprite has been colored white.
var whiteTime = 0
func _physics_process(delta):
	#move_and_slide(Vector2(0,300))
	#label.text = String(curHealth) + "/" + String(maxHealth)
	#label.text = String(curTime)

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
	#if $DebugShowFacing.visible:
	#	$DebugShowFacing.text = str(facing)
	if lastTouched != null:
		lastTouched.call("player_touched",self,player_damage)

#We want an isAlive var so we can play the death animation only one time
var isAlive = true
#damage is called by the player weapon, so don't rename it.
func damage(amount,damageType=0):
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
		lastTouched = obj
		obj.call("player_touched",self,player_damage)
	elif obj.has_method("enemy_touched"): #If enemy touched bullet
		obj.call("enemy_touched",self)

#Assume areas are bullets only, since players have a collision box
func areaTouched(obj):
	#objectTouched(obj.get_parent())
	var obj_parent = obj.get_parent()
	if obj_parent.has_method("enemy_touched"): #If enemy touched bullet
		obj_parent.call("enemy_touched",self)

func clearLastTouched(_obj):
	lastTouched=null
		
func killSelf():
	print(self.name+" queued to be killed.")
	isAlive = false
	set_physics_process(false)
	sprite.visible = false
	sprite.stop()
	dropRandomItem()
	
	
	var e
	if use_large_explosion:
		e = explosion.instance()
	else:
		e = smallExplosion.instance()	
	e.position = position
	#e.position.y-=32
	get_parent().add_child(e)
	
	emit_signal("enemy_killed")
	
	self.queue_free()
	
	
	#$Area2D.queue_free() #how to turn off monitoring, the broken way
	#if use_collision:
	#	shape_owner_clear_shapes(shapeOwnerID)
	#	set_collision_mask_bit(1,false)
	#	set_collision_mask_bit(3,false)
	#	set_collision_mask_bit(4,false)
	#	#set_collision_layer_bit(1,false)
	#$Explosion.emitting = true
	#$ExplosionSound.play()
# warning-ignore:return_value_discarded
	#$ExplosionSound.connect("finished",self,"queue_free")

var health = preload("res://Various Objects/HeartDrop.tscn")
var smallHealth = preload("res://Various Objects/SmallHeartDrop.tscn")

var ammo = preload("res://Various Objects/MPDrop.tscn")
var smallAmmo = preload("res://Various Objects/PickupAmmoSmall.tscn")

var oneUp = preload("res://Various Objects/1UP_Drop.tscn")
func dropRandomItem():
	
	#Nothing = 24/128
	#Bonus Ball = 69/128     93
	#Small Weapon = 15/128   108
	#Small Health = 15/128   123
	#Large Weapon = 2/128    125
	#Large Health = 2/128    127
	#1 Up = 1/128            128
	var r = randi() % 128 + 1
	#var r = 120
	
	if r < 93:    #Nothing
		#print("Drop result: Nothing")
		return
	elif r < 108: #Small weapon
		#print("Drop result: Small weapon")
		var h = smallAmmo.instance()
		h.position = position
		h.linear_velocity = Vector2(0,-400)
		get_parent().add_child(h)
		pass
	elif r < 123: #small health
		#print("Drop result: small health")
		var h = smallHealth.instance()
		h.position = position
		h.linear_velocity = Vector2(0,-400)
		get_parent().add_child(h)
	elif r < 125: #Large weapon
		var h = ammo.instance()
		h.position = position
		h.add_central_force(Vector2(0,-200))
		get_parent().add_child(h)
		pass
	elif r < 127: #Large health
		#print("Drop result: large health")
		var h = health.instance()
		h.position = position
		h.add_central_force(Vector2(0,-200))
		get_parent().add_child(h)
	else:         #1-Up
		#print("Drop result: 1-Up")
		var h = oneUp.instance()
		h.position = position
		h.add_central_force(Vector2(0,-200))
		get_parent().add_child(h)
