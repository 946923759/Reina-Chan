extends "res://Stages_Reina/Bosses/BossBase.gd"

#Special handler for her intro animation because
#we want it to always animate
func _on_AnimatedSprite_animation_finished():
	if sprite.animation=="intro":
		sprite.play("idle")
		$SpinnyFrame.appear()

#Why make new bullet when this one works a million times over right?
const bullet = preload("res://Stages_Reina/Enemies/EnemyChargeShot.tscn")

enum STATE {
	IDLE,
	SHOOTING1,
	SHOOT_NO_MOVE
}
var curState = STATE.SHOOT_NO_MOVE
var idleTime:float =0
var shots:int = 0
var justShot:bool=false
#var shouldMoveLeft:bool=true
var tempVelocity:Vector2
onready var spinnyFrame = $SpinnyFrame

var startingPosition:Vector2
func _ready():
	startingPosition=self.position
	facing=DIRECTION.LEFT

# Originally the counter was random but it
# wasn't random enough so I just made it rotate
var bulletCounter:int = 0
func fireBullet():
	var bi = bullet.instance()
	
	#In case the shot can't be dodged at this moment switch to the next one
	var spr = spinnyFrame.getSprite(bulletCounter)
	#print(spr.position)
	var pos = position + spr.position*4 #-Vector2(facing*-18,3)*4
	print(pos.y)
	if pos.y < -60 and pos.y > -80:
		pos = position + spinnyFrame.getSprite(bulletCounter+1).position*4 #-Vector2(facing*-18,3)*4

	bi.position = pos
	get_parent().add_child(bi)
	bi.init(facing)
	bulletCounter+=1
	if bulletCounter>2:
		bulletCounter=0

func _physics_process(delta):
	if idleTime>=0:
		idleTime-=delta
		return
	match curState:
		STATE.SHOOTING1:
			if shots > 2:
				move_and_slide(Vector2(0,200),Vector2(0, -1))
				if is_on_floor():
					shots=0
					curState=STATE.IDLE
			elif shots > 1:
				move_and_slide(Vector2(0,-200),Vector2(0, -1))
				if position.y<=startingPosition.y-16*4*3:
					fireBullet()
					shots+=1
			elif shots == 1:
				move_and_slide(Vector2(0,-200),Vector2(0, -1))
				if position.y<=startingPosition.y-16*4*2:
					fireBullet()
					shots+=1
			elif shots == 0:
				fireBullet()
				shots+=1
		STATE.IDLE:
			idleTime=1
			shots=0
			curState=STATE.SHOOTING1
		STATE.SHOOT_NO_MOVE:
			fireBullet()
			idleTime=1.7
	#Not sure why this isn't working automatically
	._physics_process(delta)
