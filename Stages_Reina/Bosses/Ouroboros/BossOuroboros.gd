extends "res://Stages_Reina/Bosses/BossBase.gd"

var rocket = preload("res://Stages_Reina/Bosses/Ouroboros/OuroborosRocket_v2.tscn")
onready var wheels = $Wheels
onready var rocketSound = $LaunchRocket

enum ROCKET_DIRECTION {
	UPLEFT,   UP,   UPRIGHT,
	LEFT,           RIGHT
	DOWNLEFT, DOWN, DOWNRIGHT
}

enum STATE {
	IDLE,
	SHOOTING1,
	SHOOTING2,
	
	JUMP_BACKWARDS,
	JUMP_FORWARDS,
	JUMPING,
	
	SHOOT_UPWARDS
	#JUMP_FORWARDS,
	#JUMP_BACKWARDS,
	#MOVING,
	#IDLE2,
	#JUMPING,
	#JUMPING2,
	#SHOOTDOWN
}
var curState = STATE.JUMP_BACKWARDS
var idleTime:float =0
var shots:int = 0

func _ready():
	wheels.visible=false

#Override this so the wheels intro anim gets played too
func playIntro(playSound=true,showHPbar=true)->AudioStreamPlayer:
	$Wheels.playIntro()
	return .playIntro(playSound,showHPbar)


func shootRocket(rocketDirection:int,offset:Vector2,rightWheel:bool=false):
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
	e.init(rocketDirection,false,curHP<=14) 
	
	add_collision_exception_with(e) # Make bullet and this not collide

var velocity:Vector2
var firstRun:bool=true
func _physics_process(delta):
	if !enabled:
		return
	#elif firstRun:
	#	wheels.set_process(true)
	#	firstRun=false
	elif idleTime>=0:
		idleTime-=delta
		return
	
	match curState:
		STATE.IDLE:
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
				shootRocket(3 if facing==-1 else 4,Vector2(20*facing, -18))
			elif shots<2 and wheels.frame>=4:
				shootRocket(3 if facing==-1 else 4,Vector2(20*facing, -6))
				shots+=1
			elif shots<3 and wheels.frame>=14:
				shootRocket(3 if facing==-1 else 4,Vector2(20*facing, 6))
				shots+=1
			elif shots<4 and wheels.frame>=15:
				shootRocket(3 if facing==-1 else 4,Vector2(20*facing, 18))
				shots+=1
			elif shots >=4:
				shots=0
				curState=STATE.IDLE
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
				shootRocket(ROCKET_DIRECTION.UPLEFT,Vector2(20*facing, -18))
			else:
				shootRocket(ROCKET_DIRECTION.LEFT,Vector2(20*facing, -18),true)
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
			#curState=STATE.IDLE
