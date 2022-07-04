extends "res://Stages_Reina/Bosses/BossBase.gd"

#Special handler for her intro animation because
#we want it to always animate
func _on_AnimatedSprite_animation_finished():
	if sprite.animation=="intro":
		sprite.play("idle")
		$SpinnyFrame.appear()

#Why make new bullet when this one works a million times over right?
const bullet = preload("res://Stages_Reina/Enemies/EnemyChargeShot.tscn")
const bulletSmall = preload("res://Stages_Reina/Enemies/bulletDinergate.tscn")

#export(Vector2) var room_top_left=Vector2(108,140)

enum STATE {
	IDLE,
	SHOOTING1,
	SHOOT_NO_MOVE,
	SHOOT_TOP_INIT,
	SHOOT_TOP
	RETURN_CIRCLING
}
var curState = STATE.SHOOT_TOP_INIT
var idleTime:float =0
var shots:int = 0
var justShot:bool=false
#var shouldMoveLeft:bool=true
var tempVelocity:Vector2
onready var spinnyFrame = $SpinnyFrame

var player:KinematicBody2D

var startingPosition:Vector2
var topLeft:Vector2
func _ready():
	topLeft = get_parent().get_parent().global_position
	startingPosition=self.position
	facing=DIRECTION.LEFT
	
	$DebugLabel3.visible=OS.is_debug_build()

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

func fireBulletSmall():
	for i in range(3):
		var bi = bulletSmall.instance()
	
		#In case the shot can't be dodged at this moment switch to the next one
		var spr = spinnyFrame.getSprite(i)
		#print(spr.position)
		var pos = position + spr.position*4 #-Vector2(facing*-18,3)*4
		bi.position = pos
		get_parent().add_child(bi)
		var v:Vector2 = (player.global_position-spr.global_position).normalized()*10
		print(v)
		bi.init(v)
		print("Fired!")

func _physics_process(delta):
	if idleTime>=0:
		idleTime-=delta
		return
	elif not enabled:
		return
		
	if player==null: #TODO: This should probably be in the base class
		player=get_node("/root/Node2D/").get_player()
	
	if OS.is_debug_build():
		$DebugLabel3.text=String((global_position-topLeft)/64)

	match curState:
		STATE.SHOOTING1:
			if shots > 2:
				move_and_slide(Vector2(0,200),Vector2(0, -1))
				if is_on_floor():
					shots=0
					curState=STATE.SHOOT_TOP
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
		STATE.SHOOT_TOP_INIT:
			spinnyFrame.set_float_to_top((topLeft/64+Vector2(10,3))*64)
			idleTime=1
			bulletCounter=0
			curState=STATE.SHOOT_TOP
		STATE.SHOOT_TOP:
			if bulletCounter < 3:
				fireBulletSmall()
				idleTime=.5
				bulletCounter+=1
			else:
				bulletCounter=0
				idleTime=1
				spinnyFrame.set_return_circling()
				curState=STATE.IDLE
		#STATE.RETURN_CIRCLING:
		#	spinnyFrame.set_circling()
		#	idleTime=1
				
	#Not sure why this isn't working automatically
	._physics_process(delta)
