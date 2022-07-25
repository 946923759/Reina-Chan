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
const b = preload("res://Stages_Reina/Enemies/bulletDanmaku.tscn")

#export(Vector2) var room_top_left=Vector2(108,140)

enum STATE {
	IDLE,
	SHOOTING1,
	SHOOT_NO_MOVE,
	SHOOT_TOP_INIT,
	SHOOT_TOP,
	RETURN_CIRCLING,
	SHOOT_SPREAD_INIT,
	SHOOT_SPREAD,
	SHOOT_CURTAIN, #Alternate to SHOOT_SPREAD
	GROUND_ATTACK_1,
	GROUND_ATTACK_2,
	CURTAINS
}
var curState = STATE.SHOOT_SPREAD_INIT
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
	is_reflecting=true
	topLeft = get_parent().get_parent().global_position
	startingPosition=self.position
	print("[Scarecrow] StartPos: "+String(startingPosition))
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
	#print(pos.y)
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
	
		var spr = spinnyFrame.getSprite(i)
		#print(spr.position)
		var pos = position + spr.position*4 #-Vector2(facing*-18,3)*4
		bi.position = pos
		get_parent().add_child(bi)
		var v:Vector2 = (player.global_position-spr.global_position).normalized()*10
		#print(v)
		bi.init(v)
		#print("[Scarecrow] Fired!")

func fire_spread(root:Node2D,startPos:Vector2):
	var startingAngle = Vector2(0,8)
	for j in range(5):
		var bi = b.instance()
		root.add_child(bi)
		bi.global_position = startPos
		bi.CubicSpread=Vector2((j-2)*2,-2)
		var newAngle = startingAngle
		newAngle.x=newAngle.x+(j-2)
		bi.init(newAngle,j==0)
			
func gen_curtain(root:Node2D,centerPos:Vector2,numToGenerate:int=9,delay:float=0):
	var spread = 64
	var v = Vector2(0,8)
	for j in range(numToGenerate):
		var bi = b.instance()
		root.add_child(bi)
		bi.global_position = centerPos
		
		bi.special_type=2
		bi.destination_spread_xpos=Vector2(bi.position.x+(float(j)-numToGenerate/2)*128.0,.3)
		if numToGenerate%2==0:
			bi.destination_spread_xpos.x+=64
		bi.timer-=delay
		bi.init(v,j==5)

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
		$DebugLabel3.text+="\n"+String(position/64) + String(position)

	match curState:
		STATE.SHOOTING1:
			if shots > 2:
				move_and_slide(Vector2(0,200),Vector2(0, -1))
				if is_on_floor():
					shots=0
					if randi()%2==0:
						curState=STATE.GROUND_ATTACK_1
					else:
						#I like it if it's random.
						if randi()%2==0:
							curState=STATE.SHOOT_TOP
						elif curHP<=14:
							curState=STATE.SHOOT_SPREAD_INIT
						else:
							curState=STATE.SHOOT_TOP_INIT
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
			is_reflecting=true
			facing=DIRECTION.LEFT if global_position.x > player.global_position.x else DIRECTION.RIGHT
			sprite.flip_h=(facing==DIRECTION.LEFT)
			spinnyFrame.set_flipped(sprite.flip_h)
			idleTime=1
			shots=0
			bulletCounter=0
			if curHP < 14 and randi()%2==0:
				curState=STATE.SHOOT_SPREAD_INIT
			else:
				curState=STATE.SHOOTING1
		STATE.SHOOT_NO_MOVE:
			fireBullet()
			idleTime=1.7
		STATE.SHOOT_TOP_INIT:
			spinnyFrame.set_float_to_top((topLeft/64+Vector2(10,3))*64)
			idleTime=1
			is_reflecting=false
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
		STATE.SHOOT_SPREAD_INIT:
			is_reflecting=false
			spinnyFrame.set_float_to_top_spread((topLeft/64+Vector2(10,2))*64)
			if bulletCounter==0:
				var t:Tween = $Tween
				t.interpolate_property(self,"global_position",null,
					topLeft+Vector2(10,6)*64,
					1.0
				)
				t.start()
				bulletCounter+=1
				idleTime=1
#			if position.y > startingPosition.y-300:
#				var movT:int=0
#				if position.x > 11*64 or position.x < 9*64:
#					#If Scarecrow is to the right she moves left,
#					#If she's to the left she moves right.
#					#I'm pretty sure there's some way to do this
#					#using pure math but I couldn't figure it out
#					if 10-position.x/64 > 1:
#						movT=1
#					else:
#						movT=-1
#
#				move_and_slide(Vector2(movT*300,-300),Vector2(0, -1))
			else:
				#idleTime=1
				bulletCounter=0
				if randi()%2==0: #randi()%2==0
					curState=STATE.SHOOT_SPREAD
				else:
					curState=STATE.SHOOT_CURTAIN
		STATE.SHOOT_SPREAD:
			if bulletCounter<1:
				fire_spread(get_parent(),spinnyFrame.getSprite(0).global_position)
				fire_spread(get_parent(),spinnyFrame.getSprite(1).global_position)
				fire_spread(get_parent(),spinnyFrame.getSprite(2).global_position)
				bulletCounter+=1
				idleTime=.5
			elif position.y < startingPosition.y:
				move_and_slide(Vector2(0,300),Vector2(0, -1))
				spinnyFrame.set_return_circling()
			else:
				curState=STATE.GROUND_ATTACK_1
				bulletCounter=0
		STATE.SHOOT_CURTAIN:
			if bulletCounter==0:
				var r = get_parent().get_parent()
				gen_curtain(r,spinnyFrame.getSprite(1).global_position)
				gen_curtain(r,spinnyFrame.getSprite(1).global_position,10,1)
				gen_curtain(r,spinnyFrame.getSprite(1).global_position,9,2)
				bulletCounter+=1
				idleTime=2
			else:
				
				var returnPos:Vector2 = startingPosition
				if global_position.x < player.global_position.x:
					returnPos.x-=12*64
				$Tween.interpolate_property(self,"position",null,returnPos,1)
				$Tween.start()
				spinnyFrame.set_return_circling(1.0,2.0)
				idleTime=3.0
				curState=STATE.IDLE
		STATE.GROUND_ATTACK_1:
			#DUDE I JUST LOVE HOW THE BITS ARE 1-INDEXED IN THE GUI
			#BUT 0-INDEXED WHEN USING THE COMMAND BECAUSE THAT
			#MAKES SENSE
			set_collision_layer_bit(1,false)
			#set_collision_mask_bit(4,false)
			#set_collision_layer_bit(4,false)
			move_and_slide(Vector2(0,200),Vector2(0, -1))
			if position.y > startingPosition.y+300:
				curState=STATE.GROUND_ATTACK_2
				bulletCounter=0
				idleTime=.5
		STATE.GROUND_ATTACK_2:
			if bulletCounter==0:
				global_position.x=player.global_position.x
				get_parent().get_node("DustCloud").position=Vector2(position.x,startingPosition.y)
				get_parent().get_node("DustCloud/AnimationPlayer").play("default")
				#facing=DIRECTION.LEFT if global_position.x > player.global_position.x else DIRECTION.RIGHT
				facing=DIRECTION.LEFT if position.x > 10*64 else DIRECTION.RIGHT
				sprite.flip_h=(facing==DIRECTION.LEFT)
				spinnyFrame.set_flipped(sprite.flip_h)
				bulletCounter+=1
			move_and_slide(Vector2(0,-200),Vector2(0, -1))
			if position.y <= startingPosition.y:
				get_parent().get_node("DustCloud").position=position
				get_parent().get_node("DustCloud/AnimationPlayer").play("default")
				curState=STATE.IDLE
				set_collision_layer_bit(1,true)
				#set_collision_mask_bit(4,true)
		#STATE.RETURN_CIRCLING:
		#	spinnyFrame.set_circling()
		#	idleTime=1
				
	#Not sure why this isn't working automatically, because
	#_physics_process can't normally be overridden (godot will execute both)
	._physics_process(delta)
