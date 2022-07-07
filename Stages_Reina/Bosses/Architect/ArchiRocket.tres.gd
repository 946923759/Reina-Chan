extends KinematicBody2D

export(int, 1, 50) var maxHealth = 10
var curHealth;
# warning-ignore:unused_class_variable
var is_reflecting = false;

enum DIRECTION {
	#UPLEFT,
	#LEFT,
	#DOWNLEFT,
	#UP,
	#DOWN,
	#UPRIGHT,
	#RIGHT,
	#DOWNRIGHT
	UPLEFT,   UP,   UPRIGHT,
	LEFT,           RIGHT
	DOWNLEFT, DOWN, DOWNRIGHT
}
var shouldGoTowards:int=DIRECTION.LEFT
var harderRockets=false
#func getNextClosest(currentDirection,intendedDirection):
#	if intendedDirection == DIRECTION.LEFT:
#		match

#This is only if you didn't override objectTouched!
#There might be cases where you need to override it.
export(int,0,25) var player_damage = 1

onready var sprite = $AnimatedSprite
onready var hurtSound = $HurtSound
var explosion = preload("res://Stages/EnemyExplosion.tscn")
var smallExplosion = preload("res://Stages/EnemyExplodeSmall.tscn")

func init(startingDirection=DIRECTION.LEFT,canChangeDirections=false,_harderRockets=false):
	#shouldGoTowards=DIRECTION.LEFT if facingLeft else DIRECTION.RIGHT
	shouldGoTowards=startingDirection
	harderRockets=_harderRockets
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
var lastChange:Vector2
var timeSinceChange:float=0
func _physics_process(delta):
	#move_and_slide(Vector2(0,300))

	handle_sprite_direction()
			
	
	"""var playerPos = get_node("/root/Node2D/Player").global_position
	var movX = 0
	if playerPos.x > global_position.x+50:
		movX = 5
	elif playerPos.x < global_position.x-50:
		movX=-5
			
	var movY = 0
	if playerPos.y > global_position.y+30:
		movY = 5
	elif playerPos.y < global_position.y-30:
		movY = -5
	
	if movX < 0:
		if movY > 0:
			shouldGoTowards = DIRECTION.DOWNLEFT
		elif movY < 0:
			shouldGoTowards = DIRECTION.UPLEFT
		else:
			shouldGoTowards = DIRECTION.LEFT
	elif movX > 0:
		if movY > 0:
			shouldGoTowards = DIRECTION.DOWNRIGHT
		elif movY < 0:
			shouldGoTowards = DIRECTION.UPRIGHT
		else:
			shouldGoTowards = DIRECTION.RIGHT
	else:
		if movY > 0:
			shouldGoTowards = DIRECTION.DOWN
		elif movY < 0:
			shouldGoTowards = DIRECTION.UP"""
	
	"""if timeSinceChange > .1: # and lastChange!=Vector2(movX,movY)
		lastChange=Vector2(movX,movY)
		timeSinceChange=0
	else:
		timeSinceChange+=delta"""
	
	if harderRockets:
		var playerPos = get_node("/root/Node2D/").get_player().global_position
		
		if shouldGoTowards==DIRECTION.LEFT or shouldGoTowards==DIRECTION.RIGHT:
			lastChange.y=0
			if playerPos.y > global_position.y+30:
				lastChange.y = 2
			elif playerPos.y < global_position.y-30:
				lastChange.y = -2
				
			
			if shouldGoTowards==DIRECTION.RIGHT:
				lastChange.x+=1
			else:
				lastChange.x+=-1
		elif shouldGoTowards==DIRECTION.DOWN:
			lastChange.y+=1
	else:
		if shouldGoTowards==DIRECTION.RIGHT:
			lastChange.x=10
		elif shouldGoTowards==DIRECTION.LEFT:
			lastChange.x=-10
		elif shouldGoTowards==DIRECTION.DOWN:
			lastChange.y=10
	
	var collision = move_and_collide(lastChange) #Vector2(movX,movY)
	if collision != null:
		killSelf()
	
	
	if !sprite.use_parent_material:
		whiteTime += delta
		if whiteTime > .1:
			sprite.use_parent_material = true
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

#We want an isAlive var so we can play the death animation only one time
var isAlive = true
#damage is called by the player weapon, so don't rename it.
func damage(amount):
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
		obj.call("player_touched",self,player_damage)
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
