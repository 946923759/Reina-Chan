extends "res://Stages_Reina/Bosses/BossBase.gd"

var rocket = preload("res://Stages_Reina/Bosses/Ouroboros/OuroborosRocket_v2.tscn")
onready var wheels = $Wheels
onready var rocketSound = $LaunchRocket

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

func _ready():
	wheels.visible=false

#Override this so the wheels intro anim gets played too
func playIntro(playSound=true,showHPbar=true)->AudioStreamPlayer:
	$Wheels.playIntro()
	return .playIntro(playSound,showHPbar)


func shootRocket(offset:Vector2):
	rocketSound.play()
	var e = rocket.instance()
	var pos = position+wheels.w2.position + offset
	
	e.position = pos
	get_parent().add_child(e)
	
	#DIRECTION enum in the rocket, homing rockets, and if rockets should speed up
	e.init(3 if facing==-1 else 4,false,curHP<=14) 
	
	add_collision_exception_with(e) # Make bullet and this not collide

var firstRun:bool=true
func _process(delta):
	if !enabled:
		return
	elif firstRun:
		wheels.set_process(true)
		firstRun=false
	elif idleTime>=0:
		idleTime-=delta
		return
	
	match curState:
		STATE.IDLE:
			pass
		STATE.SHOOTING1:
			$Wheels.play("shoot")
			curState=STATE.SHOOTING2
		STATE.SHOOTING2:
			if shots<1 and wheels.frame>=3:
				shots+=1
				shootRocket(Vector2(20*facing, -18))
			elif shots<2 and wheels.frame>=4:
				shootRocket(Vector2(20*facing, -6))
				shots+=1
			elif shots<3 and wheels.frame>=14:
				shootRocket(Vector2(20*facing, 6))
				shots+=1
			elif shots<4 and wheels.frame>=15:
				shootRocket(Vector2(20*facing, 18))
				shots+=1
			elif shots >=4:
				shots=0
				curState=STATE.IDLE
