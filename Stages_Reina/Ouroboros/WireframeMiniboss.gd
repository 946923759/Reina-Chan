extends "res://Stages/EnemyBaseScript.gd"

const b = preload("res://Stages_Reina/Enemies/nemeum homing shot.tscn")
const ball = preload("res://Stages_Reina/Ouroboros/BallDrop.tscn")

var radius:float=50.0
var objects:Array = [null,null,null,null]

enum STATES {
	RANDOMPICK,
	
	CIRCLE,
	DROP,
	
	FLASH_1,
	FLASH_2,
	
	DISAPPEAR,
	APPEAR, #Always goes to RANDOMPICK
}
var curState:int = STATES.RANDOMPICK

var ti = 0.0
var cooldown:float=0.0
var tweenTimer:float=0.0
var curDrop:int=0
var stageRoot:Node2D

func _ready():
	$Sprite.visible=true
	$Label.visible=OS.is_debug_build()

func _process(delta):
	ti+=delta
	
	#sprite.rotation_degrees+=delta*600
	#return
	
	if ti>.1:
		sprite.rotation_degrees+=15
		if sprite.rotation_degrees >= 360:
			sprite.rotation_degrees=0
		ti=0
	
	if cooldown>0:
		cooldown-=delta
		return
	
	if stageRoot==null:
		stageRoot=get_node_or_null("/root/Node2D")
		return

	match curState:
		STATES.RANDOMPICK:
			var i = randi()%3
			if i==1:
				curState=STATES.CIRCLE
			elif i==2:
				curState=STATES.FLASH_1
			else:
				curState=STATES.DROP
			
		STATES.CIRCLE:
			#$Sprite.modulate.a=0
			spawn()
			cooldown=2
			curState=STATES.DISAPPEAR
		STATES.DROP:
			spawn_ball()
			if curDrop==0:
				curDrop=1
			else:
				curDrop=0
				curState=STATES.DISAPPEAR
			cooldown=.5
		STATES.FLASH_1:
			$FlashAttack.play()
			cooldown=1.2
			var t:Tween = $Tween
			t.interpolate_property($Sprite,"scale",Vector2(0,0),Vector2(2.3,2.3),1.2,Tween.TRANS_CUBIC,Tween.EASE_IN)
			t.interpolate_property($Sprite,"modulate:a",0,0.8,1.2)
			t.start()
			curState=STATES.FLASH_2
		STATES.FLASH_2:
			$RenderSparkles.visible=true
			var player = get_node_or_null("/root/Node2D").get_player()
			#func lockMovement(time:float,n_velocity:Vector2,freeze_y_velocity:bool=true):
			player.lockMovement(2,Vector2(0,0),true)
			curState=STATES.DROP
		STATES.DISAPPEAR:
			var t:Tween = $Tween
			t.interpolate_property($Sprite,"modulate:a",null,0.0,.3)
			t.start()
			$RenderSparkles.visible=false
			
			self.modulate.a=max(0,1-tweenTimer)
			tweenTimer+=delta
			if tweenTimer>=1:
				#$Area2D.set_collision_layer_bit(0,false)
				#$Area2D.set_collision_mask_bit(0,false)
				$Area2D.monitoring=false

				curState=STATES.APPEAR
				cooldown=.5
				tweenTimer=0
				position=stageRoot.cell2pos(Vector2(4+randi()%14,randi()%5+4))
		STATES.APPEAR:
			self.modulate.a=min(1,tweenTimer)
			tweenTimer+=delta
			if tweenTimer>=1:
				$Area2D.monitoring=true
				tweenTimer=0
				curState=STATES.RANDOMPICK

func spawn():
	$CircleAttack.play()
	radius=50.0
	for i in range(4):
		var bi = b.instance()
		self.add_child(bi)
		bi.position = Vector2(0,-radius)
		var rotateBy:float = 2.0 * PI * i/4
		bi.position=bi.position.rotated(rotateBy)
		#bi.special_type=4
		bi.init2()
		#bi.init()
		objects[i]=bi
	#bi.init(Vector2(radius/4,0))
	#bi.init(Vector2(0,0))
	#print(get_child_count())

func spawn_ball():
	$Laser.play()
	var bi = ball.instance()
	get_parent().add_child(bi)
	bi.position=self.position
	bi.init(get_parent())
	#bi.position=self

#TODO: There's no reason for this to use physics_process
func _physics_process(delta):
	var any_valid_orbs:bool=false
	for o in objects:
		if is_instance_valid(o):
			any_valid_orbs=true
			break
	if any_valid_orbs==false:
		return
	
	radius+=delta*300
	
	for c in objects:
		if is_instance_valid(c)==false:
			continue
			
		
		if radius>800:
			c.modulate.a=min(0.0,(900-radius)/100)
		
		# 1 full circle (i.e. 2 * PI) every second, clockwise
		var rotateBy:float = .75 * PI * delta
		
		
		#c.position=c.position.rotated(rotateBy)
		#Efficiency is for lamers
		#var offset = position.direction_to(c.position)*radius
		#c.position=offset.rotated(rotateBy)
		var nPos:Vector2 = c.position.rotated(rotateBy)
		#c.position=nPos
		c.position=Vector2(0,0).direction_to(nPos)*radius
		
		# TODO: I'm pretty sure there's some way to just subtract it from
		# rotateBy instead of having to create 3 variables
		#movement = movement.rotated(rotateBy)
	#update()
	
func _input(_event):
	if Input.is_action_just_pressed("ui_up"):
		radius+=10
	elif Input.is_action_just_pressed("ui_down"):
		radius-=10
		#print("ayy lmao")
	
	#TODO: These keys shouldn't work unless the miniboss is on screen
	#if _event is InputEventKey and Input.is_key_pressed(KEY_5):
	#	spawn()
	#elif _event is InputEventKey and Input.is_key_pressed(KEY_6):
	#	spawn_ball()
	#update()

func damage(amount,damageType=0):
	#if true: #sprite.modulate.a<.8
	#	return
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
