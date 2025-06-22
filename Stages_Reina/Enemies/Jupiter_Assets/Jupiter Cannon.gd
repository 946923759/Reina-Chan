extends "res://Stages/MinibossBase.gd"

onready var sprite2 = $Sprite_prongs
onready var sprite_laser = $Laser

onready var explSound = $MiniExplodeSound

var bullet = preload("res://Stages_Reina/Enemies/bulletDinergate.tscn")


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

func _ready():
	
	$LaserCharging.connect("finished",self,"fireLaser")
	#$LaserFire.connect("finished",self,"recharge")
	
	#The bullets pass through the static body 2d on bad computers so yeah here's my fix
	$WhatTheFuckIsWrongWithGodot.monitoring=true
	# warning-ignore:return_value_discarded
	$WhatTheFuckIsWrongWithGodot.connect("body_entered",self,"bottomTouched")
	$WhatTheFuckIsWrongWithGodot.connect("area_entered",self,"areaBottomTouched")
	
	# Test mode
	#current_health = floor(MAX_HEALTH/2)-1


var waitTime:float =0.0
var numShots:int = 0
func _physics_process(delta):
	
	if current_health <= MAX_HEALTH/2:
		waitTime+=delta
		if not exploded:
			explodeTopHalf()
			current_state=STATES.WAIT_BOTTOM
		if current_state==STATES.WAIT_BOTTOM:
			if waitTime > 1:
				current_state=STATES.SHOOT_BOTTOM
				print("shoot bottom")
				waitTime=0
		elif current_state==STATES.SHOOT_BOTTOM:
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
					current_state=STATES.WAIT_BOTTOM
	else:
		if current_state==STATES.WAIT:
			waitTime+=delta
			if waitTime>1:
				waitTime=0
				current_state=STATES.CHARGING
				sprite.animation="charging"
				$LaserCharging.play()
		if current_state==STATES.COOLDOWN:
			waitTime+=delta
			if waitTime>.8:
				waitTime=0
				recharge()
		
func fireLaser():
	current_state=STATES.FIRE
	$laserArea2D.monitoring=true
	$LaserFire.play()
	#$Tween.
	var seq := get_tree().create_tween()
	sprite_laser.scale.y=1
	seq.tween_property(sprite_laser,'toDraw',64+16+16+5,.1).set_trans(Tween.TRANS_QUAD)
	sprite.animation="fire"
	sprite2.visible=true
	current_state=STATES.COOLDOWN
	
func recharge():
	$laserArea2D.monitoring=false
	sprite2.visible=false
	sprite_laser.toDraw=0
	sprite.animation="wait"
	#var seq := get_tree().create_tween()
	#seq.tween_property($Sprite,'scale:y',0,.1).set_trans(Tween.TRANS_QUAD)
	current_state=STATES.WAIT

var exploded=false
func explodeTopHalf():
	print("Miniboss half dead! "+String(current_health)+"/"+String(MAX_HEALTH))

	$LaserCharging.stop()
	$LaserFire.stop()
	sprite2.visible=false
	sprite_laser.visible=false
	#$LaserFire.visible=false
	$laserArea2D.monitoring=false
	

	$Hitbox.monitoring=false
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

#This is for the TOP HALF! NOT THE BOTTOM!
func object_touched_this_obj_hitbox(obj):
	#print("intersecting!")
	if obj.has_method("player_touched"): #If enemy touched player
		lastTouched = obj
		obj.call("player_send_flying",self,player_damage,0 if facing==DIRECTION.LEFT else 1)
	elif obj.has_method("enemy_touched"): #If enemy touched bullet
		if !obj.reflected:
			#print("called enemy_touched_alt")
			obj.call("enemy_touched_alt",self,exploded)
			
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
