extends Node2D


# This is the central orb
onready var orb = $NemeumShot
onready var pos = position
# This holds the ones that circle around it
var circling = []

var radius:float=0.0
const MAX_RADIUS = 325
var mult = 200

func _ready():
	circling.resize(4)
	get_child(0).sprite.play('default')
	for i in range(1,5):
		var c = get_child(i)
		c.sprite.play("default")
		#Workaround weird bug where if this node is already in the tree it fires screen_exited and causes the node to delete itself
		c.get_node("VisibilityNotifier2D").disconnect("screen_exited",c,"_on_VisibilityNotifier2D_screen_exited")
		circling[i-1] = c

		c.position = Vector2(0,-1)
		var rotateBy:float = 2.0 * PI * i/4
		c.position=c.position.rotated(rotateBy)

func _process(delta):
	if Input.is_key_pressed(KEY_KP_4):
		pos.x -= delta*mult
	elif Input.is_key_pressed(KEY_KP_6):
		pos.x += delta*mult
	elif Input.is_key_pressed(KEY_KP_8):
		pos.y -= delta*mult
	elif Input.is_key_pressed(KEY_KP_2):
		pos.y += delta*mult
	elif Input.is_key_pressed(KEY_KP_5):
		radius=0

	self.position = pos

	$BitmapFont.text = String(round(pos.x)) + ", " + String(round(pos.y))

	#Scale down to 0.0 - 1.0
	var t:float = clamp(radius / MAX_RADIUS, 0.0, 1.0)
	#Get ease and scale back up
	var eased_growth:float = delta * 300 * easeOutQuad(1.0 - t)
	radius = min(radius + eased_growth, MAX_RADIUS)
	
	for c in circling:
		if is_instance_valid(c)==false:
			continue
			
		#Fade out?
		#if radius>800:
		#	c.modulate.a=min(0.0,(900-radius)/100)
		
		# 1 full circle (i.e. 2 * PI) every second, clockwise
		var rotateBy:float = PI * delta * -0.5
		
		
		#c.position=c.position.rotated(rotateBy)
		#Efficiency is for lamers
		#var offset = position.direction_to(c.position)*radius
		#c.position=offset.rotated(rotateBy)
		var nPos:Vector2 = c.position.rotated(rotateBy)
		#c.position=nPos
		c.position=Vector2(0,0).direction_to(nPos)*radius

static func easeOutQuad(x: float) -> float:
	return 1 - (1 - x) * (1 - x);