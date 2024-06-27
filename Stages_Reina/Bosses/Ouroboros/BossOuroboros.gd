extends "res://Stages_Reina/Bosses/BossBase.gd"

var rocket = preload("res://Stages_Reina/Bosses/Ouroboros/OuroborosRocket_v2.tscn")
var rocketSky =preload("res://Stages_Reina/Bosses/Ouroboros/OuroborosRocketSky.tscn")
onready var wheels = $Wheels
onready var rocketSound = $LaunchRocket

enum ROCKET_DIRECTION {
	UPLEFT,   UP,   UPRIGHT,
	LEFT,     NONE, RIGHT     #NONE is needed for left to right remapping
	DOWNLEFT, DOWN, DOWNRIGHT
}
func flipDirectionsForRight(f:int,d:int)->int:
	if f==DIRECTION.LEFT: #Don't need to flip
		return d
	elif d==ROCKET_DIRECTION.UPLEFT or \
		 d==ROCKET_DIRECTION.LEFT or \
		 d==ROCKET_DIRECTION.DOWNLEFT:
		return d+2
	#elif d==ROCKET_DIRECTION.LEFT:
	#	return ROCKET_DIRECTION.RIGHT
	#elif d==ROCKET_DIRECTION.DOWNLEFT:
	#	return ROCKET_DIRECTION.DOWNRIGHT
	return d

enum STATE {
	IDLE,
	SHOOTING1,
	SHOOTING2,
	
	HOP_TO_LEFT,
	HOP_TO_RIGHT,
	
	JUMP_BACKWARDS,
	JUMP_FORWARDS,
	JUMPING,
	
	SHOOT_UPWARDS,
	
	SHOOT_SKY_1,
	SHOOT_SKY_2,
	SHOOT_SKY_3,
	SHOOT_SKY_4,
	SHOOT_SKY_RETURN, #Probably not needed, idle can wait until touches ground
	#JUMP_FORWARDS,
	#JUMP_BACKWARDS,
	#MOVING,
	#IDLE2,
	#JUMPING,
	#JUMPING2,
	#SHOOTDOWN
	NUM_STATES
}
var stateToString:PoolStringArray = [
	"Idle",
	"Shooting1",
	"Shooting2",
	"Hop towards left",
	"Hop towards right",
	"Jump Backwards",
	"Jump Forwards",
	"Jumping",
	"Shoot Upwards",
	"Shoot Sky 1",
	"Shoot Sky 2",
	"Shoot Sky 3",
	"Shoot Sky 4 (2nd loop)",
	"Return",
	"NUM_STATES (You shouldn't see this)"
]

var curState = STATE.JUMP_BACKWARDS
var idleTime:float =0
var shots:int = 0

func _ready():
	$CanvasLayer/Label.visible=$CanvasLayer/Label.visible and OS.is_debug_build()
	wheels.visible=false
	$Wheels.flip_h = (facing == DIRECTION.RIGHT)

#Override this so the wheels intro anim gets played too
func playIntro(playSound=true,showHPbar=true)->AudioStreamPlayer:
	$Wheels.playIntro()
	return .playIntro(playSound,showHPbar)


func shootRocket(rocketDirection:int,offset:Vector2,rightWheel:bool=false)->Node2D:
	rocketSound.play()
	var e = rocket.instance()
	var pos = position + offset
	if rightWheel:
		pos+=wheels.w1.position
	else:
		pos+=wheels.w2.position
	
	e.position = pos
	get_parent().add_child(e)
	
	#DIRECTION enum in the rocket, homing rockets, and if rockets should speed up
	e.init(rocketDirection,false,curHP<=14) # 
	
	add_collision_exception_with(e) # Make bullet and this not collide
	return e

#rocketDirection is mostly irrelevant here
func shootRocketSky(destXPos:float,offset:Vector2,rightWheel:bool=false,waitTime:float=1.0)->Node2D:
	rocketSound.play()
	var e = rocketSky.instance()
	var pos = position + offset
	if rightWheel:
		pos+=wheels.w1.position
	else:
		pos+=wheels.w2.position
	
	print("[Ouroboros] Spawning rocket at pos "+String(pos)+" (relative to parent)")
	e.position = pos
	get_parent().add_child(e)
	
	var spd = 24.5
	if Globals.playerData.gameDifficulty > Globals.Difficulty.MEDIUM:
		spd=28.0
		waitTime-=.9
	
	e.init2(ROCKET_DIRECTION.UPLEFT,destXPos,waitTime,spd) 
	
	add_collision_exception_with(e) # Make bullet and this not collide

	return e

var velocity:Vector2
var firstRun:bool=true
func _physics_process(delta):
	if !enabled:
		return
	if Input.is_key_pressed(KEY_1):
		curState=STATE.SHOOT_SKY_1
		#I have no idea why, but weird shit happens if you don't return here.
		#Maybe because the input is being repeated every frame?
		return
	elif Input.is_key_pressed(KEY_2):
		curState=STATE.SHOOT_SKY_2
		return
	#elif firstRun:
	#	wheels.set_process(true)
	#	firstRun=false
	elif idleTime>=0:
		idleTime-=delta
		return
	
	#$CanvasLayer/Label.text = stateToString[curState]
	#var stageRoot = get_node_or_null("/root/Node2D")
	#if stageRoot:
	#	$CanvasLayer/Label.text+="\n"+String(stageRoot.pos2cell(get_room_position()))+String(get_room_position()/64)
	
	if get_room_position().y/64 > 20:
		printerr("[Ouroboros] Fell outside the room??? "+String(get_room_position()))
		position = Vector2(0,-256)
	
	match curState:
		STATE.IDLE:
			sprite.play("default")
			shots=0
			if randi()%2==0:
				$Wheels.play("shootAngle")
				curState=STATE.JUMP_BACKWARDS
			else:
				curState=STATE.SHOOTING1
			idleTime=1
		STATE.SHOOTING1:
			$Wheels.play("shoot")
			$Wheels.frame=0
			curState=STATE.SHOOTING2
		STATE.SHOOTING2:
			if shots<1 and wheels.frame>=3:
				shots+=1
				shootRocket(flipDirectionsForRight(facing,ROCKET_DIRECTION.LEFT),Vector2(20*facing, -18))
			elif shots<2 and wheels.frame>=4:
				shootRocket(flipDirectionsForRight(facing,ROCKET_DIRECTION.LEFT),Vector2(20*facing, -6))
				shots+=1
			elif shots<3 and wheels.frame>=14:
				shootRocket(flipDirectionsForRight(facing,ROCKET_DIRECTION.LEFT),Vector2(20*facing, 6))
				shots+=1
			elif shots<4 and wheels.frame>=15:
				shootRocket(flipDirectionsForRight(facing,ROCKET_DIRECTION.LEFT),Vector2(20*facing, 18))
				shots+=1
			elif shots >=4:
				shots=0
				if get_room_position().x/64>10:
					if curHP<14: # and randi()%2==0
						curState=STATE.SHOOT_SKY_1
					else:
						curState=STATE.HOP_TO_LEFT
				else:
					curState=STATE.HOP_TO_RIGHT
				
		STATE.HOP_TO_LEFT, STATE.HOP_TO_RIGHT:
			if curState==STATE.HOP_TO_RIGHT:
				facing=DIRECTION.RIGHT
			else:
				facing=DIRECTION.LEFT
				
			velocity = move_and_slide(velocity,Vector2(0,-1),true)
			if is_on_floor():
				if (curState==STATE.HOP_TO_LEFT and get_room_position().x/64 > 4) or \
				   (curState==STATE.HOP_TO_RIGHT and get_room_position().x/64 < 14):
					sprite.play("jump forward")
					sprite.frame=0
					velocity=Vector2(400*facing,-220)
				else:
					facing*=-1
					curState=STATE.IDLE
			else:
				velocity.y+=1200*delta
			$CanvasLayer/Label.text+="\n"+String(velocity)+"\n"+String(is_on_floor())
#		STATE.HOP_TO_RIGHT: #TODO: Surely there is a better way to code this!?!??!
#			facing=DIRECTION.RIGHT
#			velocity = move_and_slide(velocity,Vector2(0,-1),true)
#			if is_on_floor():
#				if getPosRelativeToRoom().x/64 < 16:
#					sprite.play("jump forward")
#					sprite.frame=0
#					velocity=Vector2(400*facing,-220)
#				else:
#					facing*=-1
#					curState=STATE.IDLE
#			else:
#
#				velocity.y+=1200*delta
				
		STATE.JUMP_FORWARDS:
			velocity=Vector2(400*facing,-220)
			sprite.play("jump forward")
			curState=STATE.JUMPING
		STATE.JUMP_BACKWARDS:
			velocity=Vector2(-400*facing,-220)
			sprite.play("jump backward")
			curState=STATE.JUMPING
		STATE.JUMPING:
			velocity = move_and_slide(velocity,Vector2(0,-1),true)
			velocity.y+=1200*delta
			if is_on_floor():
				velocity=Vector2(0,0)
				sprite.play("default")
				curState=STATE.SHOOT_UPWARDS
		STATE.SHOOT_UPWARDS:
			if shots%2==0:
				shootRocket(flipDirectionsForRight(facing,ROCKET_DIRECTION.UPLEFT),Vector2(20*facing, -18))
			else:
				shootRocket(flipDirectionsForRight(facing,ROCKET_DIRECTION.LEFT),Vector2(20*facing, -18),true)
			shots+=1
			if shots>3:
				shots=0
				curState=STATE.IDLE
			else:
				#If even, jump backwards, else jump forwards by adding 1 to enum
				curState=STATE.JUMP_BACKWARDS+shots%2
				
				if curHP<14:
					idleTime=.1
				else:
					idleTime=.2
		STATE.SHOOT_SKY_1:
			velocity = move_and_slide(velocity,Vector2(0,-1),true)
			velocity.y+=1200*delta
			if is_on_floor():
				if get_room_position().x < 13*64:
					velocity=Vector2(-400*facing,-220)
					sprite.play("jump backward")
					#$CanvasLayer/Label.text+="\nRight"
				elif get_room_position().x > 17*64:
					velocity=Vector2(400*facing,-220)
					sprite.play("jump forward")
					#$CanvasLayer/Label.text+="\nLeft"
				else:
					sprite.play("jump backward")
					velocity = Vector2(-200*facing,-1100)
					curState=STATE.SHOOT_SKY_2
					#$CanvasLayer/Label.text+="\nUp"
		STATE.SHOOT_SKY_2:
			velocity = move_and_slide(velocity,Vector2(0,-1),true)
			velocity.y+=1200*delta
			if is_on_floor():
				sprite.play("default")
				$Wheels.play("shootAngle")
				#Just in case physics doesn't work
				if get_room_position().x/64 < 18 or get_room_position().y/64 > 4:
					set_room_position(Vector2(20*64,3.3*64))
					#global_position = Vector2(319*64,99.3*64)
				idleTime=.5
				shots=0
				curState=STATE.SHOOT_SKY_3
		STATE.SHOOT_SKY_3, STATE.SHOOT_SKY_4:
			move_and_slide(Vector2(0,100),Vector2(0,-1),true)
			
			#(12 - 12 or 12 - 13) + 3 + 4*shots
			var shotX:float=STATE.SHOOT_SKY_3-curState+3+4*shots
			if shots>=4: #Reverse it so it's right to left
				shotX=STATE.SHOOT_SKY_3-curState+2+4*(shots-4)
				
			#randf returns a value between 0 and 1
			shotX+=randf()-.5
			var waitTimer:float=.2
			
			#if shots>4:
			#	waitTimer+=2
			
			#destXPos, offset, rightWheel (reverse dir), wait time
			var s = shootRocketSky(shotX,Vector2(20*facing, -18),shots>4,waitTimer)
			if OS.is_debug_build():
				if shots>=4:
					s.marker.modulate=Color.red
			shots+=1
			idleTime=waitTimer
			if shots>=8:
				shots=0
				if curState==STATE.SHOOT_SKY_3:
					curState+=1
				else:
					curState+=1
					velocity=Vector2(400*facing,-220)
					sprite.play("jump forward")
		STATE.SHOOT_SKY_RETURN:
			velocity = move_and_slide(velocity,Vector2(0,-1),true)
			velocity.y+=1200*delta
			if is_on_floor():
				velocity=Vector2(0,0)
				sprite.play("default")
				curState=0
			pass
	sprite.flip_h = (facing == DIRECTION.RIGHT)
	#We can't do the -1 scale trick because it flips the positions
	#of the left and the right wheel
	$Wheels.flip_h = (facing == DIRECTION.RIGHT)


func killSelf():
	$Wheels.is_dead=true
	.killSelf()
