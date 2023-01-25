extends "res://Stages/EnemyBaseScript.gd"

var boulder = preload("res://Various Objects/Boulder.tscn")
var boulderSmall = preload("res://Various Objects/BoulderSmall.tscn")
var molotov = preload("res://Stages_Reina/Enemies/Skorp/SkMolotov.tscn")

enum STATES {
	IDLE,
	JUMPINIT,
	JUMP,
	JUMP_INTO_SKY,
	FALL_FROM_SKY,
	FIRE_INIT,
	FIRE_SHORT,   #If player is somewhat close
	FIRE_LONG,    #If player is in the middle
	MOLOTOV_INIT, #If player is sitting in the corner like a lamer
	MOLOTOV_WAIT1,
	#MOLOTOV_WAIT2,
	MOLOTOV,
	MOLOTOV_FINISH
}
var curState = STATES.IDLE
var gravity:float=0.0
export(int) var ceiling_pos_to_spawn_rocks=0

onready var footstep = $footstep
onready var heavyLanding = $HeavyLanding
onready var fireSound = $fireSound
onready var fireAnim = $Particles2DSmall
onready var fireAnimBig = $Particles2DBig
onready var fakeBottle = $FakeBottle
onready var debugDistance = $DebugDistance
var player:KinematicBody2D

var rng = RandomNumberGenerator.new()

func update_flip():
	#if facing==DIRECTION.LEFT:
	sprite.flip_h=(facing==DIRECTION.LEFT)
	$FireArea2D2.position.x=332*facing
	fireAnimBig.scale.x=4*facing
	fireAnimBig.position.x=116*facing
	fakeBottle.position.x=44*facing
	fakeBottle.flip_h=(facing==DIRECTION.LEFT)

func _init():
	set_physics_process(false)

func _ready():
	fireAnim.emitting=false
	fireAnimBig.emitting=false
	fireSound.playing=false
	$FireArea2D1.monitoring=false
	$FireArea2D2.monitoring=false
	# warning-ignore:return_value_discarded
	$FireArea2D2.connect("body_entered",self,"objectTouched")
	$FireArea2D2.connect("body_exited",self,"clearLastTouched")
	
	fakeBottle.visible=false
	sprite.set_animation("default")
	
	set_physics_process(false)
	update_flip()
	is_reflecting=true

	debugDistance.visible=OS.is_debug_build()

func spawn_boulders():
	for _i in range(3):
		var range_:int=0
		if facing==DIRECTION.LEFT:
			range_=rng.randi_range(1,10)
		else:
			range_=rng.randi_range(9,19)
		var e = boulder.instance()
		e.position = Vector2(range_*64,-64*rng.randi_range(0,4))
		#e.position.y-=32
		get_parent().add_child(e)
		#print("Spawned falling boulder at "+String(e.global_position))
	#Get fucked lol
	var e = boulder.instance()
	e.position.y-=64*rng.randi_range(0,4)
	get_parent().add_child(e)
	e.global_position.x=player.global_position.x

var moveTimer:float=0.0
var stateTimer:float=0.0
var timesJumped:int=0
var timesMolotov:int=0
var justShotFire:bool=false
#This is NOT facing because we don't need the miniboss to flip its
#sprite ever
var moveDirection:int=1
func _physics_process(delta):
	match curState:
		STATES.IDLE:
			var velocity = move_and_slide(Vector2(moveDirection*100,gravity), Vector2(0, -1), true)
			moveTimer+=delta
			stateTimer+=delta
			if stateTimer>1:
				if timesJumped<1:
					timesJumped+=1
					curState=STATES.JUMPINIT
				else:
					timesJumped=0
					if (Globals.playerData.gameDifficulty < Globals.Difficulty.MEDIUM):
						if randi()%2==0:
							if timesMolotov>1:
								timesMolotov=0
								sprite.set_animation("jump")
								curState=STATES.JUMP_INTO_SKY
							else:
								timesMolotov+=1
								curState=STATES.MOLOTOV_INIT
						else:
							curState=STATES.FIRE_INIT
							sprite.set_animation("fire")
					else:
						var distanceFromPlayer=abs(global_position.x-player.global_position.x)/64
						if (distanceFromPlayer>9 or justShotFire):
							justShotFire=false
							if timesMolotov>1:
								timesMolotov=0
								#sprite.playing=false
								sprite.set_animation("jump")
								curState=STATES.JUMP_INTO_SKY
							else:
								timesMolotov+=1
								curState=STATES.MOLOTOV_INIT
						else:
							curState=STATES.FIRE_INIT
							sprite.set_animation("fire")
				stateTimer=0
				#moveTimer=0
			#NOT elif, we still want to reset this!
			if moveTimer>1:
				moveDirection*=-1
				moveTimer=0
		STATES.JUMPINIT:
			gravity = -500
			curState=STATES.JUMP
		STATES.JUMP:
			var velocity = move_and_slide(Vector2(0,gravity), Vector2(0, -1), true)
			gravity+=delta*1200
			if is_on_floor():
				
				spawn_boulders()
				footstep.play()
				player.get_node("Camera2D").shakeCamera(2.0)
				curState=STATES.IDLE
		STATES.JUMP_INTO_SKY:
			if position.y > -150: #if not at the top of the room (y is 0 at the top, add some offset to hide the whole sprite)
				move_and_slide(Vector2(0,-1000), Vector2(0, -1), true)
			else:
				global_position.x=player.global_position.x
				curState=STATES.FALL_FROM_SKY
		STATES.FALL_FROM_SKY:
			if stateTimer==0.0:
				#var parent_pos = get_parent().position
				for i in range(3):
					var e = boulderSmall.instance()
					e.position = Vector2(position.x+i*32-32,-32*rng.randi_range(0,4))
					#e.position.y-=32
					get_parent().add_child(e)
				gravity = 1000
				stateTimer+=.1
			elif stateTimer > 1.3:
				stateTimer+=delta
				if player.global_position.x<global_position.x:
					facing=DIRECTION.LEFT
				else:
					facing=DIRECTION.RIGHT
				update_flip()
				var velocity = move_and_slide(Vector2(0,gravity), Vector2(0, -1), true)
				gravity+=delta*1200
				if is_on_floor():
					spawn_boulders()
					stateTimer=0
					heavyLanding.play()
					
					player.get_node("Camera2D").shakeCamera(4.0) #Magnitude
					#device, weak magnitude, strong magnitude, duration
					Input.start_joy_vibration(0,.5,.5,.2)
					
					curState=STATES.FIRE_INIT
					sprite.playing=true
					sprite.set_animation("fire")
				if stateTimer>4:
					printerr("Skorpion is stuck??? Teleporting downwards as a failsafe.")
					self.position.y+=100
					stateTimer=1.31
			else:
				stateTimer+=delta
		STATES.FIRE_INIT:
			if sprite.frame>=5:
				fireSound.playing=true
				#var distanceFromPlayer=abs(global_position.x-player.global_position.x)/64
				if true: #No need for the small one.
					fireAnimBig.emitting=true
					#curState=STATES.FIRE_LONG
				else:
					$FireArea2D1.monitoring=true
					fireAnim.emitting=true
				is_reflecting=false
				curState=STATES.FIRE_SHORT
			
		STATES.FIRE_SHORT:
			stateTimer+=delta
			if stateTimer>=2:
				fireAnim.emitting=false
				fireAnimBig.emitting=false
				fireSound.playing=false
				$FireArea2D1.monitoring=false
				$FireArea2D2.monitoring=false
				sprite.set_animation("default")
				justShotFire=true
				stateTimer=0
				curState=0
				is_reflecting=true
			elif stateTimer>=.8: #Too hard to make it extend, so just wait until the fire is full...
				$FireArea2D2.monitoring=true
		STATES.MOLOTOV_INIT:
			sprite.set_animation("ThrowReady")
			sprite.playing=false
			fakeBottle.position.y=-500
			fakeBottle.visible=true
			gravity=5
			curState=STATES.MOLOTOV_WAIT1
		STATES.MOLOTOV_WAIT1:
			#TODO: This doesn't work properly, if delta is small it goes faster
			gravity+=delta*40
			fakeBottle.position.y=min(fakeBottle.position.y+gravity,-152)
			if fakeBottle.position.y>=-152:
				fakeBottle.visible=false
				sprite.playing=true
				curState=STATES.MOLOTOV
		STATES.MOLOTOV:
			if sprite.frame==3:
				print("Spawn molotov")
				var e = molotov.instance()
				#This is actually a complete guess and I have no idea
				#how it works. But it works, and that's all that
				#matters.
				e.position = position+fakeBottle.position
				var v:Vector2 = (player.global_position-global_position).normalized()*Vector2(abs(player.global_position.x-global_position.x)/64*.75,40)
				v.y=-4
				#v.x*=2
				#print(v.normalized()*100)
				#e.position.y-=32
				get_parent().add_child(e)
				e.init(facing,v)
				sprite.set_animation("ThrowFinish")
				curState=STATES.MOLOTOV_FINISH
		STATES.MOLOTOV_FINISH:
			if sprite.frame==3:
				sprite.set_animation("default")
				curState=STATES.IDLE
				
	if debugDistance.visible:
		debugDistance.text=String(stepify((global_position.x-player.global_position.x)/64,.01))


#Maybe get_player() should be used instead?
func _on_CameraAdjuster_body_entered(body):
	if body.has_method("player_touched"):
		if is_instance_valid(player):
			print("SKORP: Already obtained a player object, maybe Player 2?")
		player=body
		set_physics_process(true)
		print("SKORP: Player touched activation trigger!")
