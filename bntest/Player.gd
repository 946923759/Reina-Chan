extends Node2D

#For base class (God why am I using godot for this)
enum OBJECT_TYPE {
	PLAYER,
	CPU_PLAYER, #Navis and similar
	ENEMY,
	IMMOVABLE_OBJECT #Rocks, Cubes
}

export(Vector2) var charaPos=Vector2(0,0) setget set_pos
var platformCenter:Vector2
export(bool) var leftSide=true

#Inherit these and change
var type = OBJECT_TYPE.PLAYER
const maximum_health:int = 3000
var health:int=maximum_health setget set_health

#Base PLAYER/CPU_PLAYER stuff I guess
const MOVEMENT_COOLDOWN = 0.15
var chipsInHand = [] #lol lmao

#ONLY FOR PLAYER CLASS!!
export(int) var PN = 0
export(NodePath) var target_hp_display

var INPUT = load("res://Player Files/8bitPlayer/INPUTMAN.gd")

onready var sprite:AnimatedSprite = $AnimatedSprite

func set_pos(new_pos):
	
	if charaPos != new_pos:
		movement_cooldown = MOVEMENT_COOLDOWN
		charaPos = new_pos
	position=platformCenter+Vector2(charaPos.x*160,charaPos.y*96)

func _ready():
	sprite.flip_h = !leftSide
	sprite.connect("animation_finished",sprite,"play",["default"])
	sprite.play('default')
	
func init(platformCenter:Vector2):
	self.platformCenter=platformCenter
	set_pos(charaPos)
	if target_hp_display:
		get_node(target_hp_display).text = String(health)

func set_health(h:int):
	health = h
	if target_hp_display:
		get_node(target_hp_display).text = String(health)

#apply_hitstun is not necessary, directly subtracting health will trigger set_health?
func apply_damage(damage_amount:int=0, attacker:Node2D=null, apply_hitstun:bool=true):
	$hurt.play()
	sprite.play('hurt')
	sprite.frame=0
	hurt_cooldown=.3
	#health-=damage_amount
	set_health(health-damage_amount)

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
		var newCharaPos = charaPos
		if Input.is_action_pressed(INPUT.UP[PN]):
			if newCharaPos.y>0:
				newCharaPos.y-=1
		elif Input.is_action_pressed(INPUT.DOWN[PN]):
			if newCharaPos.y<2:
				newCharaPos.y+=1
		elif Input.is_action_pressed(INPUT.RIGHT[PN]):
			if leftSide and charaPos.x<2:
				newCharaPos.x+=1
			elif !leftSide and charaPos.x<5:
				newCharaPos.x+=1
		elif Input.is_action_pressed(INPUT.LEFT[PN]):
			if leftSide and charaPos.x>0:
				newCharaPos.x-=1
			elif !leftSide and charaPos.x > 3:
				newCharaPos.x-=1
		else:
			return
		set_pos(newCharaPos)
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
			break
