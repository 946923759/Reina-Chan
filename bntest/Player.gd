extends "res://bntest/EntityBase.gd"
signal chip_in_hand_changed(chipName, attackPower, numChipsInHand)

#Base PLAYER/CPU_PLAYER stuff I guess
const MOVEMENT_COOLDOWN = 0.15


# This is filed front to back
# because it's faster
# That means the "topmost" of your hand
# will be the one at the last position.
# This is a static size for speed reasons,
# So use numChipsInHand to check instead.
var chipsInHand = []
var numChipsInHand = 0

var all_attack_datas = [
	{
		name="LongSword",
		damage=80,
		iconX=30,
		iconY=1,
		ref = preload("res://bntest/chips/SwordLong.tscn")
	},
	{
		name="WideSword",
		damage=80,
		iconX=21,
		iconY=1,
		ref = preload("res://bntest/chips/SwordWide.tscn")
	},
	{
		name="Sword",
		damage=80,
		iconX=18,
		iconY=1,
		ref = preload("res://bntest/chips/SwordAttack.tscn")
	},
	{
		name="Cannon",
		damage=40,
		iconX=0,
		iconY=0,
		ref = preload("res://bntest/chips/Cannon.tscn")
	},
	{
		name="Hi-Cannon",
		damage=100,
		iconX=1,
		iconY=0,
		ref = preload("res://bntest/chips/HiCannon.tscn")
	},
	{
		name="M-Cannon",
		damage=180,
		iconX=2,
		iconY=0,
		ref = preload("res://bntest/chips/M-Cannon.tscn")
	},
	{
		name="cube",
		damage=200,
		iconX=21,
		iconY=3,
		ref = preload("res://bntest/chips/SpawnCube.tscn")
	},
	{
		name="Heal20",
		damage=20,
		iconX=13,
		iconY=4,
		ref = preload("res://bntest/chips/SpawnCube.tscn")
	}
]

#ONLY FOR PLAYER CLASS!!
export(int) var PN = 0
export(NodePath) var target_hp_display
export(NodePath) var target_chip_display

var INPUT = load("res://Player Files/8bitPlayer/INPUTMAN.gd")

onready var sprite:AnimatedSprite = $AnimatedSprite

#why does this have a set/get when the cooldown is 
#only applied if the player moves???
func set_pos(new_pos):
	
	if charaPos != new_pos:
		movement_cooldown = MOVEMENT_COOLDOWN
	.set_pos(new_pos)

func set_health(h:int):
	.set_health(h)
	if target_hp_display:
		get_node(target_hp_display).text = String(health)


func chip_used_emit():
	if numChipsInHand>0:
		var chipMeta = chipsInHand[numChipsInHand-1]
		emit_signal("chip_in_hand_changed", chipMeta.name, chipMeta.damage, numChipsInHand)
		$ChipMiniDisplay/Chip1.frame_coords=Vector2(chipMeta.iconX, chipMeta.iconY)
		if target_chip_display:
			get_node(target_chip_display).text = chipMeta.name
	else:
		if target_chip_display:
			get_node(target_chip_display).text = ""
	
	for i in range(5):
		$ChipMiniDisplay.get_child(i).visible= i < numChipsInHand
	

func debug_refill_chips():
	
	chipsInHand = all_attack_datas
	numChipsInHand = all_attack_datas.size()
	
	chip_used_emit()

func _ready():
	sprite.flip_h = facing==FACING.LEFT
	sprite.connect("animation_finished",sprite,"play",["default"])
	sprite.play('default')
	
	debug_refill_chips()

func init(stageRef:Node2D):
	.init(stageRef)
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

func die():
	.die()
	sprite.disconnect("animation_finished",sprite,"play")
	sprite.set_animation("die")

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
	if Input.is_action_just_pressed(INPUT.FORWARD[PN]) and not occupied_by_chip and numChipsInHand>0:
		#Abandon all hope, ye who enter
		var inst = chipsInHand[numChipsInHand-1].ref.instance()
		
		var attackPos = charaPos+Vector2(facing,0)
		stage.push_attack(inst,self,attackPos,facing)
		if inst.is_part_of_player:
			occupied_by_chip = inst
		
		numChipsInHand-=1
		chip_used_emit()
		
	if Input.is_action_pressed(INPUT.BACK[PN]):
		shoothold+=delta
		if shoothold > .5 and playcharge == false:
			playcharge = true
	
	if Input.is_action_just_pressed(INPUT.THIRD[PN]):
		debug_refill_chips()
	
	#TODO: CHECK OBSTACLES!!
	if movement_cooldown <= 0.0:
		var newCharaPos = charaPos
		if Input.is_action_pressed(INPUT.UP[PN]):
			if newCharaPos.y>0:
				newCharaPos.y-=1
		elif Input.is_action_pressed(INPUT.DOWN[PN]):
			if newCharaPos.y<2:
				newCharaPos.y+=1
		#TODO: This makes no sense, it should be checking if the
		# player owns this panel
		elif Input.is_action_pressed(INPUT.RIGHT[PN]):
			if facing==FACING.RIGHT and charaPos.x<2:
				newCharaPos.x+=1
			elif facing==FACING.LEFT and charaPos.x<5:
				newCharaPos.x+=1
		elif Input.is_action_pressed(INPUT.LEFT[PN]):
			if facing==FACING.RIGHT and charaPos.x>0:
				newCharaPos.x-=1
			elif facing==FACING.LEFT and charaPos.x > 3:
				newCharaPos.x-=1
		else:
			return
		var o = stage.get_obj_at_pos(newCharaPos,false)
		if not o:
			set_pos(newCharaPos)
		#print(position)
	

	
var movement_cooldown:float=0
var hurt_cooldown:float=0
var occupied_by_chip = null
func _physics_process(delta):
	if hurt_cooldown>0.0:
		hurt_cooldown-=delta
	elif movement_cooldown>0.0:
		movement_cooldown-=delta
	
	# Player is using a chip, so they can't move.
	# Pass all inputs to the chip for attack sequences
	# (Like knife chip, or hadouken)
	if occupied_by_chip and is_instance_valid(occupied_by_chip):
		occupied_by_chip.player_input(PN)
	else:
		occupied_by_chip=null
		get_input(delta)
	
func attack_default():
	$shoot.play()
	
	#Maybe divide this up into a sub-function
	if facing==FACING.RIGHT:
		for i in range(charaPos.x+facing,6,facing):
			var o = stage.get_obj_at_pos(Vector2(i,charaPos.y))
			if o:
				o.apply_damage(1)
				break
	else:
		for i in range(charaPos.x+facing,0,facing):
			var o = stage.get_obj_at_pos(Vector2(i,charaPos.y))
			if o:
				o.apply_damage(1)
				break
		

func release_chip_lock():
	occupied_by_chip=null
