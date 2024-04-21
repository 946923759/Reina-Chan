extends Node2D

var lifeMax:int = 3000
var curHP=lifeMax
export(Vector2) var charaPos=Vector2(0,0)
var platformCenter:Vector2
export(bool) var leftSide=true
export(int) var PN = 0
export(NodePath) var target_hp_display

var INPUT = load("res://bntest/INPUTMAN.gd")

onready var sprite:AnimatedSprite = $AnimatedSprite

func setPos():
	position=platformCenter+Vector2(charaPos.x*160,charaPos.y*96)

func _ready():
	sprite.flip_h = !leftSide
	sprite.connect("animation_finished",sprite,"play",["default"])
	
func init(platformCenter:Vector2):
	self.platformCenter=platformCenter
	setPos()
	if target_hp_display:
		get_node(target_hp_display).text = String(curHP)

func apply_damage(damage_amount:int=0, attacker:Node2D=null):
	$hurt.play()
	sprite.play('hurt')
	sprite.frame=0
	hurt_cooldown=.3
	curHP-=damage_amount
	if target_hp_display:
		get_node(target_hp_display).text = String(curHP)

var shoothold:float = 0.0
var playcharge = false
func get_input(delta):
	if Input.is_action_just_released(INPUT.BACK[PN]):
		sprite.set_animation("shoot")
		shoothold=0.0
		attack_default()
	elif hurt_cooldown > 0:
		pass
	elif movement_cooldown > 0:
		sprite.play('move')
	elif movement_cooldown < 0:
		movement_cooldown = 0.0
		sprite.play('default')
	#elif sprite.animation == "shoot":
		#if sprite.frame == 13:
		#	sprite.play("default")
		#if frames
	#else:
		#sprite.set_animation("default")
		
	if Input.is_action_pressed(INPUT.BACK[PN]):
		shoothold+=delta
		if shoothold > .5 and playcharge == false:
			playcharge = true
			
	#TODO: CHECK OBSTACLES!!
	if movement_cooldown <= 0.0:
		var origCharaPos = charaPos
		if Input.is_action_pressed(INPUT.UP[PN]):
			if charaPos.y>0:
				charaPos.y-=1
		elif Input.is_action_pressed(INPUT.DOWN[PN]):
			if charaPos.y<2:
				charaPos.y+=1
		elif Input.is_action_pressed(INPUT.RIGHT[PN]):
			if leftSide and charaPos.x<2:
				charaPos.x+=1
			elif !leftSide and charaPos.x<5:
				charaPos.x+=1
		elif Input.is_action_pressed(INPUT.LEFT[PN]):
			if leftSide and charaPos.x>0:
				charaPos.x-=1
			elif !leftSide and charaPos.x > 3:
				charaPos.x-=1
		else:
			return
		if charaPos != origCharaPos:
			movement_cooldown = 0.15
			setPos()
		#print(position)
	

	
var movement_cooldown:float=0
var hurt_cooldown:float=0
func _physics_process(delta):
	if hurt_cooldown>0.0:
		hurt_cooldown-=delta
	elif movement_cooldown>0.0:
		movement_cooldown-=delta
	get_input(delta)
	
func attack_default():
	$shoot.play()
	var root = get_node("../../")
	for i in range(charaPos.x+1,6):
		var o = root.get_obj_at_pos(Vector2(i,charaPos.y))
		if o:
			o.apply_damage(1)
