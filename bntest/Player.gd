extends Node2D

var lifeMax:int = 3000
var curHP=lifeMax
export(Vector2) var charaPos=Vector2(0,0)
var platformCenter:Vector2
export(bool) var leftSide=true
export(int) var PN = 0

var INPUT = load("res://bntest/INPUTMAN.gd")

onready var sprite:AnimatedSprite = $AnimatedSprite

func setPos():
	position=platformCenter+Vector2(charaPos.x*160,charaPos.y*96)

func _ready():
	sprite.flip_h = !leftSide
	
func init(platformCenter:Vector2):
	self.platformCenter=platformCenter
	setPos()

func get_input(delta):
	if Input.is_action_pressed(INPUT.BACK[PN]):
		sprite.set_animation("shoot")
	else:
		sprite.set_animation("default")
	#TODO: CHECK OBSTACLES!!
	if Input.is_action_just_pressed(INPUT.UP[PN]):
		if charaPos.y>0:
			charaPos.y-=1
	elif Input.is_action_just_pressed(INPUT.DOWN[PN]):
		if charaPos.y<2:
			charaPos.y+=1
	elif Input.is_action_just_pressed(INPUT.RIGHT[PN]):
		if leftSide and charaPos.x<2:
			charaPos.x+=1
		elif !leftSide and charaPos.x<5:
			charaPos.x+=1
	elif Input.is_action_just_pressed(INPUT.LEFT[PN]):
		if leftSide and charaPos.x>0:
			charaPos.x-=1
		elif !leftSide and charaPos.x > 3:
			charaPos.x-=1
	else:
		return
	setPos()
	#print(position)
	
	
	
func _physics_process(delta):
	get_input(delta)
	
#func _ready():
	
