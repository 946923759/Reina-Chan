extends StaticBody2D
signal enemy_destroyed()

#export(int) var maxHealth;
export(int, 1, 50) var maxHealth = 10
var curHealth;
# warning-ignore:unused_class_variable
var is_reflecting = true;
#-1 to move left, 1 to move right
enum DIRECTION {LEFT = -1, RIGHT = 1}
export(DIRECTION) var facing = DIRECTION.LEFT

#This is only if you didn't override objectTouched!
#There might be cases where you need to override it.
export(int,0,25) var player_damage = 1

export(bool) var use_large_explosion = true

onready var sprite = $AnimatedSprite
onready var sprite2 = $Sprite_prongs
onready var sprite_laser = $Laser

onready var hurtSound = $HurtSound
onready var explSound = $MiniExplodeSound

var explosion = preload("res://Stages/EnemyExplosion.tscn")
var smallExplosion = preload("res://Stages/EnemyExplodeSmall.tscn")

var health = preload("res://Various Objects/HeartDrop.tscn")
var smallHealth = preload("res://Various Objects/SmallHeartDrop.tscn")

var bullet = preload("res://Stages_Reina/Enemies/bulletDinergate.tscn")

var lastTouched


#After 50% health, top cannon flips and then it starts shooting the bottom?
enum STATES {
	WAIT = 0,
	CHARGING,
	FIRE,
	COOLDOWN,
	DEAD,
	SHOOT_BOTTOM,
	WAIT_BOTTOM
}
var curState:int = STATES.WAIT

func _ready():
	curHealth = maxHealth
	#assert(curHealth)
	sprite.flip_h = (facing == DIRECTION.RIGHT)
	set_physics_process(true);
# warning-ignore:return_value_discarded
	$Area2D.connect("body_entered",self,"objectTouched")
	#Absolutely kicking myself for not using the enemy base script right now
	$Area2D.connect("area_entered",self,"areaTouched")
# warning-ignore:return_value_discarded
	$Area2D.connect("body_exited",self,"clearLastTouched")
# warning-ignore:return_value_discarded
	#$Area2D.connect("area_entered",self,"objectTouched")
	sprite.play()
	
	$LaserCharging.connect("finished",self,"fireLaser")
	#$LaserFire.connect("finished",self,"recharge")
	
	#The bullets pass through the static body 2d on bad computers so yeah here's my fix
	$WhatTheFuckIsWrongWithGodot.monitoring=true
	# warning-ignore:return_value_discarded
	$WhatTheFuckIsWrongWithGodot.connect("body_entered",self,"bottomTouched")
	$WhatTheFuckIsWrongWithGodot.connect("area_entered",self,"areaBottomTouched")
	
	# Test mode
	#curHealth = floor(maxHealth/2)-1


var waitTime:float =0.0
var numShots:int = 0
func _process(delta):
	if curState==STATES.DEAD:
		processDeathAnimation(delta)
		return
	
	#Is floor() even necessary here? maxHealth is an int
	if curHealth <= floor(maxHealth/2):
		waitTime+=delta
		if not exploded:
			explodeTopHalf()
			curState=STATES.WAIT_BOTTOM
		if curState==STATES.WAIT_BOTTOM:
			if waitTime > 1:
				curState=STATES.SHOOT_BOTTOM
				print("shoot bottom")
				waitTime=0
		elif curState==STATES.SHOOT_BOTTOM:
			#waitTime+=delta
			if waitTime > .2:
				if numShots < 3:
					var bi = bullet.instance()
					var pos = position + Vector2(150*facing, 150)
					
					bi.position = pos
					get_parent().add_child(bi)
					bi.init(Vector2(5*facing,0))
					
					#add_collision_exception_with(bi) # Make bullet and this not collide
					waitTime=0
					numShots+=1;
				else:
					#sleepTime = 1
					numShots = 0
					curState=STATES.WAIT_BOTTOM
	else:
		if curState==STATES.WAIT:
			waitTime+=delta
			if waitTime>1:
				waitTime=0
				curState=STATES.CHARGING
				sprite.animation="charging"
				$LaserCharging.play()
		if curState==STATES.COOLDOWN:
			waitTime+=delta
			if waitTime>.8:
				waitTime=0
				recharge()
		
func fireLaser():
	curState=STATES.FIRE
	$laserArea2D.monitoring=true
	$LaserFire.play()
	#$Tween.
	var seq := TweenSequence.new(get_tree())
	sprite_laser.scale.y=1
	seq.append(sprite_laser,'toDraw',64+16+16+5,.1).set_trans(Tween.TRANS_QUAD)
	sprite.animation="fire"
	sprite2.visible=true
	curState=STATES.COOLDOWN
	
func recharge():
	$laserArea2D.monitoring=false
	sprite2.visible=false
	sprite_laser.toDraw=0
	sprite.animation="wait"
	#var seq := TweenSequence.new(get_tree())
	#seq.append($Sprite,'scale:y',0,.1).set_trans(Tween.TRANS_QUAD)
	curState=STATES.WAIT

var exploded=false
func explodeTopHalf():
	print("Miniboss half dead! "+String(curHealth)+"/"+String(maxHealth))

	$LaserCharging.stop()
	$LaserFire.stop()
	sprite2.visible=false
	sprite_laser.visible=false
	#$LaserFire.visible=false
	$laserArea2D.monitoring=false
	

	$Area2D.monitoring=false
	sprite.animation="gun"
	exploded=true
	#Allows bottom half to be damaged (top half is handled by objectTouched method)
	is_reflecting=false
	var e
	if use_large_explosion:
		e = explosion.instance()
	else:
		e = smallExplosion.instance()
	e.position = position
	e.position.y-=32
	get_parent().add_child(e)
	
	

# warning-ignore:return_value_discarded
	#$Area2D.connect("body_exited",self,"clearLastTouched")

#The duration that the sprite has been colored white.
var whiteTime = 0
func _physics_process(delta):
	#move_and_slide(Vector2(0,300))
	#label.text = String(curHealth) + "/" + String(maxHealth)
	#label.text = String(curTime)

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
	

#This is for the TOP HALF! NOT THE BOTTOM!
func objectTouched(obj):
	print("intersecting!")
	if obj.has_method("player_touched"): #If enemy touched player
		lastTouched = obj
		obj.call("player_send_flying",self,player_damage,0 if facing==DIRECTION.LEFT else 1)
	elif obj.has_method("enemy_touched"): #If enemy touched bullet
		if !obj.reflected:
			#print("called enemy_touched_alt")
			obj.call("enemy_touched_alt",self,exploded)
			
#Assume areas are bullets only, since players have a collision box
func areaTouched(obj):
	#var obj_parent = 
	objectTouched(obj.get_parent())
	#if obj_parent.has_method("enemy_touched"): #If enemy touched bullet
	#	obj_parent.call("enemy_touched_alt",self,exploded)
			
#Bottom half
func bottomTouched(obj):
	if !isAlive:
		return
	#print("intersecting!")
	if obj.has_method("player_touched"): #If enemy touched player
		lastTouched = obj
		obj.call("player_send_flying",self,player_damage,0 if facing==DIRECTION.LEFT else 1)
		lastTouched=null
	elif obj.has_method("enemy_touched"): #If enemy touched bullet
		if !obj.reflected:
			#print("called enemy_touched_alt")
			obj.call("enemy_touched_alt",self,!exploded)
			
func areaBottomTouched(obj):
	bottomTouched(obj.get_parent())

func clearLastTouched(_obj):
	lastTouched=null
		
func killSelf():
	isAlive = false
	set_physics_process(false)
	#$Area2D.monitoring=false
	$Area2D.set_deferred("monitoring",false)
	$WhatTheFuckIsWrongWithGodot.set_deferred("monitoring",false)
	#sprite.visible = false
	#sprite.stop()
	sprite.set_animation("die")
	curState=STATES.DEAD


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
