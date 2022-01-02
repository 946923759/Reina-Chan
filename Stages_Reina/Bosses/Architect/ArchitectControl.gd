extends KinematicBody2D

#-1 to move left, 1 to move right
enum DIRECTION {LEFT = -1, RIGHT = 1}
export(DIRECTION) var facing = DIRECTION.LEFT
var lastTouched
var enabled:bool = false
var curHP:int = 28 #All bosses in mega man have 28 health.
onready var sprite = $AnimatedSprite
onready var HPBar = $CanvasLayer/bar
onready var hurtSound = $HurtSound

#This is only if you didn't override objectTouched!
#There might be cases where you need to override it.
export(int,0,25) var player_damage = 1

var rocket = preload("res://Stages_Reina/Bosses/Architect/ArchiRocket.tscn")
var deathAnimation = preload("res://Animations/deathAnimation.tscn")

func _ready():
# warning-ignore:return_value_discarded
	$Area2D.connect("body_entered",self,"objectTouched")
# warning-ignore:return_value_discarded
	$Area2D.connect("body_exited",self,"clearLastTouched")
# warning-ignore:return_value_discarded
	#Absolutely kicking myself for not using the enemy base script right now
# warning-ignore:return_value_discarded
	$Area2D.connect("area_entered",self,"areaTouched")


func playIntro(playSound=true,showHPbar=true):
	#$AnimatedSprite.animation="intro"
	$AnimatedSprite.play("intro")
	if showHPbar:
		var seq := TweenSequence.new(get_tree())
		HPBar.set_process(true)
		seq.append(HPBar,"position:x",1235,.1)
# warning-ignore:return_value_discarded
		seq.append(HPBar,"curHP",1,1.5)
# warning-ignore:return_value_discarded
		seq.append_callback(HPBar,"set_process",[false])
	if playSound:
		$AudioStreamPlayer.play()
		return $AudioStreamPlayer
	#1235
	#$AudioStreamPlayer.connect("finished",callback,)

enum STATE {
	IDLE,
	SHOOTING1,
	SHOOTING2,
	MOVING,
	IDLE2,
	JUMPING,
	JUMPING2,
	SHOOTDOWN
}
var curState = STATE.SHOOTING1
var idleTime:float =0
var shots:int = 0
var shouldMoveLeft:bool=true
var tempVelocity:Vector2
#var is_on_floor_:bool
#The duration that the sprite has been colored white.
var whiteTime = 0
func _physics_process(delta):
	if not enabled:
# warning-ignore:return_value_discarded
		move_and_slide(Vector2(0,200))
	else:
		sprite.playing=true
		sprite.flip_h = (facing == DIRECTION.RIGHT)
		if !sprite.use_parent_material:
			whiteTime += delta
			if whiteTime > .1:
				sprite.use_parent_material = true
				
		
		if curState==STATE.IDLE:
			sprite.set_animation("Idle")
			idleTime+=delta
			if idleTime > .2:
				if curHP<=14 and randi()%2==0:
					curState=STATE.JUMPING
				else:
					curState = STATE.MOVING
		elif curState==STATE.SHOOTING1:
			sprite.set_animation("Fire")
			if sprite.frame==2:
				shots+=1
				$LaunchRocket.play()
				var e = rocket.instance()
				var pos = position + Vector2(67*facing, -40)
				
				e.position = pos
				get_parent().add_child(e)
				
				#DIRECTION enum in the rocket, homing rockets, and if rockets should speed up
				e.init(3 if facing==-1 else 4,false,curHP<=14) 
				
				add_collision_exception_with(e) # Make bullet and this not collide
# warning-ignore:return_value_discarded
				move_and_slide(Vector2(facing*-200,200))
				curState=STATE.SHOOTING2
		elif curState==STATE.SHOOTING2:
			idleTime+=delta
			if shots < 3:
				if idleTime > .2:
					idleTime=0
					curState=STATE.SHOOTING1
			else:
				if idleTime > .4:
					shots=0
					idleTime=0
					sprite.play("Idle")
					curState=STATE.IDLE
				elif idleTime > .3:
					sprite.set_animation("ReturnToIdle")
		elif curState==STATE.MOVING:
			sprite.set_animation("WalkLoop")
			#TODO: There has GOT to be a better way to code this
			if shouldMoveLeft:
				facing=DIRECTION.LEFT
				# How can we know how much to walk by?
				# Since the start boss tile is always 3 blocks from the door,
				# And the boss is a child of the boss tile, we can assume
				# The safe bounds of the room are -96 and 864.
				
				if position.x >= -96:
					#player run speed = 350
# warning-ignore:return_value_discarded
					move_and_slide(Vector2(facing*500,200))
				else:
					shouldMoveLeft=!shouldMoveLeft
					facing=facing*-1
					curState=STATE.IDLE2
			else:
				facing=DIRECTION.RIGHT
				if position.x <= 864-16*4:
# warning-ignore:return_value_discarded
					move_and_slide(Vector2(facing*500,200))
				else:
					shouldMoveLeft=!shouldMoveLeft
					facing=facing*-1
					curState=STATE.IDLE2
		elif curState==STATE.IDLE2:
			idleTime+=delta
			if idleTime>.2:
				idleTime=0
				curState = STATE.SHOOTING1
		elif curState==STATE.JUMPING:
			sprite.set_animation("Jump")
			tempVelocity=Vector2(facing*350,-1400)
			curState=STATE.JUMPING2
		elif curState==STATE.JUMPING2:
			tempVelocity=move_and_slide(tempVelocity,Vector2(0, -1))
			tempVelocity.y += 2500 * delta
			if is_on_floor():
				shots=0
				curState=STATE.IDLE
				facing=facing*-1
			elif tempVelocity.y>600 and shots < 3:
				curState=STATE.SHOOTDOWN
			elif tempVelocity.y>-400:
				sprite.set_animation("rocketDown")
		elif curState == STATE.SHOOTDOWN:
			shots+=1
			$LaunchRocket.play()
			var e = rocket.instance()
			var pos = position + Vector2(67*facing, 40)
			
			e.position = pos
			get_parent().add_child(e)
			
			#DIRECTION enum in the rocket, homing rockets, and if rockets should speed up
			e.init(6,true,true)
			
			add_collision_exception_with(e) # Make bullet and this not collide
			tempVelocity=Vector2(facing*350,-500)
			curState=STATE.JUMPING2

func objectTouched(obj):
	#print("intersecting!")
	if obj.has_method("player_touched"): #If enemy touched player
		lastTouched = obj
		obj.call("player_touched",self,player_damage)
	elif obj.has_method("enemy_touched"): #If enemy touched bullet
		obj.call("enemy_touched",self)

#Assume areas are bullets only, since players have a collision box
func areaTouched(obj):
	objectTouched(obj.get_parent())

func clearLastTouched(_obj):
	lastTouched=null

#We want an isAlive var so we can play the death animation only one time
var isAlive = true
func damage(amount):
	curHP -= amount
	#print("Took damage!")
	if curHP <= 0:
		if isAlive:
			killSelf()
	else:
		#set false so the white tint shader will show up.
		hurtSound.play()
		sprite.use_parent_material = false
		whiteTime = 0
		#print(curHP/28.0)
		HPBar.updateHP(curHP/28.0)
		
func killSelf():
	print(self.name+" queued to be killed.")
	HPBar.updateHP(0)
	isAlive = false
	set_physics_process(false)
	sprite.visible = false
	sprite.stop()
	
	$DieSound.play()
	var sp = deathAnimation.instance()
	sp.position=position
	get_parent().add_child(sp)
	#dropRandomItem()
	
	#self.queue_free()
	var player = get_node("/root/Node2D/Player")
	player.finishStage()
	#.lockMovement(999,Vector2())
	#get_node("/root/Node2D/VictorySound").play()
