extends StaticBody2D
signal enemy_destroyed()

export(int, 1, 50) var MAX_HEALTH = 10
#-1 to move left, 1 to move right
enum DIRECTION {LEFT = -1, RIGHT = 1}
export(DIRECTION) var facing = DIRECTION.LEFT
#This is only if you didn't override objectTouched!
#There might be cases where you need to override it.
export(int,0,25) var player_damage = 1
export(bool) var use_large_explosion = true
export(bool) var drop_item_on_death = true

#We want an isAlive var so we can play the death animation only one time
var isAlive = true
var current_health:int = 10;
var is_reflecting = true;
var lastTouched:KinematicBody2D
var current_state:int = 0
#The duration that the sprite has been colored white.
var whiteTime = 0

onready var sprite = $AnimatedSprite
onready var hurt_sound = $HurtSound

var explosion = preload("res://Stages/EnemyExplosion.tscn")
var smallExplosion = preload("res://Stages/EnemyExplodeSmall.tscn")
var health = preload("res://Various Objects/pickupHealthBig.tscn")
var smallHealth = preload("res://Various Objects/pickupHealthSmall.tscn")

func _ready():
	current_health = MAX_HEALTH
	#assert(curHealth)
	sprite.flip_h = (facing == DIRECTION.RIGHT)
	set_physics_process(true);
# warning-ignore:return_value_discarded
	$Hitbox.connect("body_entered",self,"object_touched_this_obj_hitbox")
# warning-ignore:return_value_discarded
	$Hitbox.connect("body_exited",self,"clearLastTouched")
# warning-ignore:return_value_discarded
	$Hitbox.connect("body_entered",self,"object_touched_this_obj_hurtbox")
	sprite.play()

func _process(delta):
	if !sprite.use_parent_material:
		whiteTime += delta
		if whiteTime > .1:
			sprite.use_parent_material = true

	if !isAlive:
		processDeathAnimation(delta)
		return
	
	if lastTouched != null:
		lastTouched.call("player_touched",self,player_damage)



func clearLastTouched(_obj):
	lastTouched=null

#This occurs when a player object enters the Hitbox area2d
func object_touched_this_obj_hitbox(obj:KinematicBody2D):
	if !is_instance_valid(obj):
		return
	#print("Body intersecting with miniboss hitbox!")
	if obj.has_method("player_touched"): #If enemy touched player
		lastTouched = obj
		#obj.call("player_damage",self,player_damage, 0 if facing==DIRECTION.LEFT else 1)
		obj.player_touched(self, player_damage)

#Assume areas are bullets only, since players have a collision box
#If you want to give the miniboss a seperate hitbox, turn off layer/mask
#4 for the hitbox and add your own then connect this func
func object_touched_this_obj_hurtbox(obj:KinematicBody2D):
	if !is_instance_valid(obj):
		return
	#print("Area (Projectile) intersecting with miniboss hurtbox!")
	#object_touched_this_obj_hurtbox(obj.get_parent())
	#var obj_parent:KinematicBody2D = area.get_parent()
	if obj.has_method("enemy_touched"): #If enemy touched bullet
		if !obj.reflected:
			#print("called enemy_touched_alt")
			obj.call("enemy_touched_alt", self, false)

#damage is called by the player weapon, so don't rename it.
func damage(amount:int,damageType):
	current_health -= amount
	#print("Took damage!")
	if current_health <= 0:
		if isAlive:
			die()
	else:
		#set false so the white tint shader will show up.
		hurt_sound.play()
		sprite.use_parent_material = false
		whiteTime = 0

func die():
	set_physics_process(false)
	$Hitbox.set_deferred("monitoring",false)
	sprite.set_animation("die")
	#curState=STATES.DEAD
	isAlive = false

var elapsed:float = 0.0
var anim:int = 0
var explodePos:PoolVector2Array = [
	Vector2(-12,-12),
	Vector2(12,12),
	Vector2(0,4),
]

#var originalXPosition
var movLeft:int=1
func processDeathAnimation(delta):
	elapsed-=delta
	sprite.position.y+=delta*3
	sprite.position.x+=delta*12*movLeft
	if sprite.position.x > .5:
		movLeft=-1
	elif sprite.position.x < -.5:
		movLeft=1
	if anim==3:
		if elapsed <=0:
			anim+=1
	elif elapsed<=0.0 and anim < 3:
		print("Play anim"+String(anim))
		playExplode(explodePos[anim])
		anim+=1
		if anim == 3:
			elapsed=.5
			sprite.modulate.a=.5
		else:
			elapsed=.4
	elif anim==4:
		#print(self.name+" queued to be killed.")
		emit_signal("enemy_destroyed")
		dropRandomItem()
		queue_free()
		
	
	#self.queue_free()
func playExplode(pos):
	var e
	if use_large_explosion:
		e = explosion.instance()
	else:
		e = smallExplosion.instance()
	e.position = position+pos*16
	get_parent().add_child(e)

#Why is this even here? This should be a subroutine in Globals or something
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
	#print("Drop result: "+String(r))
	if r < 93:    #Nothing
		return
	elif r < 108: #Small weapon
		pass
	elif r < 123: #small health
		#print("Drop small health")
		var h = smallHealth.instance()
		h.position = position
		h.linear_velocity = Vector2(0,-400)
		get_parent().add_child(h)
	elif r < 125: #Large weapon
		pass
	elif r < 127: #Large health
		#print("Drop large health")
		var h = health.instance()
		h.position = position
		h.add_central_force(Vector2(0,-200))
		get_parent().add_child(h)
	else:         #1-Up
		pass
