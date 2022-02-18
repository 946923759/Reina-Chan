extends Node2D

var lifeMax:int = 3000
var curHP=lifeMax
export(Vector2) var playerPos=Vector2(0,0)
var platformCenter:Vector2
export(bool) var leftSide=true
export(int) var PN = 0

var INPUT = load("res://bntest/INPUTMAN.gd")

onready var sprite:AnimatedSprite = $AnimatedSprite

func setPos():
	position=platformCenter+Vector2(playerPos.x*160,playerPos.y*96)

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
		if playerPos.y>0:
			playerPos.y-=1
	elif Input.is_action_just_pressed(INPUT.DOWN[PN]):
		if playerPos.y<2:
			playerPos.y+=1
	elif Input.is_action_just_pressed(INPUT.RIGHT[PN]):
		if leftSide and playerPos.x<2:
			playerPos.x+=1
		elif !leftSide and playerPos.x<5:
			playerPos.x+=1
	elif Input.is_action_just_pressed(INPUT.LEFT[PN]):
		if leftSide and playerPos.x>0:
			playerPos.x-=1
		elif !leftSide and playerPos.x > 3:
			playerPos.x-=1
	else:
		return
	setPos()
	#print(position)
	
	
	
func _physics_process(delta):
	get_input(delta)
	
#func _ready():
	
