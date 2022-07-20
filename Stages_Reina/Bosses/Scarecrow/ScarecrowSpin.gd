extends Node2D

onready var sprite1 = $Sprite
onready var sprite2 = $Sprite2
onready var sprite3 = $Sprite3

onready var t:Tween = $Tween

enum STATES {
	spinning,
	top,
	topSpread,
	danmaku
}
var curState = STATES.spinning

var player:KinematicBody2D

export(Vector2) var radius = Vector2(16,0)
var radius2
var radius3
export(float,0.1,5) var speed = 0.5

#HELP HOW DO I TRIG???????? I HAVEN'T DONE THIS IN 8 YEARS
func _ready():
	radius2=radius.rotated(2.0 * PI/3)
	radius3=radius.rotated(4.0 * PI/3)
	set_physics_process(false)
	sprite1.modulate.a=0
	sprite2.modulate.a=0
	sprite3.modulate.a=0
	
func appear():
	set_physics_process(true)
	
	t.interpolate_property(sprite1,"modulate:a",0.0,1.0,.3,Tween.TRANS_QUAD,Tween.EASE_IN)
	t.interpolate_property(sprite2,"modulate:a",0.0,1.0,.3,Tween.TRANS_QUAD,Tween.EASE_IN,.2)
	t.interpolate_property(sprite3,"modulate:a",0.0,1.0,.3,Tween.TRANS_QUAD,Tween.EASE_IN,.4)
	t.start()
	
func appear_quick():
	sprite1.modulate.a=1
	sprite2.modulate.a=1
	sprite3.modulate.a=1
	set_physics_process(true)

func disappear(time:float=0.3):
	if time<=0:
		sprite1.modulate.a=0
		sprite2.modulate.a=0
		sprite3.modulate.a=0
		set_physics_process(false)
	else:
		t.interpolate_property(sprite1,"modulate:a",null,0.0,time,Tween.TRANS_QUAD,Tween.EASE_IN)
		t.interpolate_property(sprite2,"modulate:a",null,0.0,time,Tween.TRANS_QUAD,Tween.EASE_IN)
		t.interpolate_property(sprite3,"modulate:a",null,0.0,time,Tween.TRANS_QUAD,Tween.EASE_IN)
		t.interpolate_callback(self,time,"set_physics_process",false)
		t.start()
	
	
	
func set_flipped(flip:bool):
	sprite1.flip_h=flip
	sprite2.flip_h=flip
	sprite3.flip_h=flip

#This shouldn't be using physics process, but whatever
var timer:float=0.0
func _physics_process(delta):
	if timer>=0.0:
		timer-=delta
		return
	
	#sprite1.get_node("Label").text="1\nRot: "+String(sprite1.rotation_degrees)
	if curState==STATES.spinning:
		# 1 full circle (i.e. 2 * PI) every second, clockwise
		var rotateBy:float = 2.0 * PI * delta*speed
		
		# TODO: I'm pretty sure there's some way to just subtract it from
		# rotateBy instead of having to create 3 variables
		radius = radius.rotated(rotateBy)
		radius2 = radius2.rotated(rotateBy)
		radius3 = radius3.rotated(rotateBy)

		# 1 full circle (i.e. 2 * PI) every 4 seconds, counter-clockwise
		# radius = radius.rotated(2 * PI * delta * -0.25)

		$Sprite.position = radius
		$Sprite2.position= radius2
		$Sprite3.position= radius3
	elif curState==STATES.top: #I miss preprocessor functions
		var p_pos = player.global_position
		sprite1.rotation_degrees=sprite1.global_position.angle_to_point(p_pos)*180/PI
		sprite2.rotation_degrees=sprite2.global_position.angle_to_point(p_pos)*180/PI
		sprite3.rotation_degrees=sprite3.global_position.angle_to_point(p_pos)*180/PI

func set_float_to_top(goTowards:Vector2):
	curState=STATES.top
	#This is needed because they aim towards the player.
	player=get_node("/root/Node2D/").get_player()
	
	t.interpolate_property(sprite1,"global_position",null,goTowards+Vector2(-1,1)*64,1,Tween.TRANS_CUBIC,Tween.EASE_OUT)
	t.interpolate_property(sprite2,"global_position",null,goTowards,1,Tween.TRANS_CUBIC,Tween.EASE_OUT)
	t.interpolate_property(sprite3,"global_position",null,goTowards+Vector2(1,1)*64,1,Tween.TRANS_CUBIC,Tween.EASE_OUT)
	
#	t.interpolate_property(sprite1,"rotation_degrees",null,-45,1,Tween.TRANS_CUBIC,Tween.EASE_OUT)
#	t.interpolate_property(sprite2,"rotation_degrees",null,-45,1,Tween.TRANS_CUBIC,Tween.EASE_OUT)
#	t.interpolate_property(sprite3,"rotation_degrees",null,-45,1,Tween.TRANS_CUBIC,Tween.EASE_OUT)
#

	t.start()
	#return 1.0
	
func set_float_to_top_spread(goTowards:Vector2):
	curState=STATES.topSpread
	
	t.interpolate_property(sprite1,"global_position",null,goTowards+Vector2(-4,0)*64,1,Tween.TRANS_CUBIC,Tween.EASE_OUT)
	t.interpolate_property(sprite2,"global_position",null,goTowards,1,Tween.TRANS_CUBIC,Tween.EASE_OUT)
	t.interpolate_property(sprite3,"global_position",null,goTowards+Vector2(4,0)*64,1,Tween.TRANS_CUBIC,Tween.EASE_OUT)
	
	var rot:int = get_parent().facing*90
	t.interpolate_property(sprite1,"rotation_degrees",null,rot,1,Tween.TRANS_CUBIC,Tween.EASE_OUT)
	t.interpolate_property(sprite2,"rotation_degrees",null,rot,1,Tween.TRANS_CUBIC,Tween.EASE_OUT)
	t.interpolate_property(sprite3,"rotation_degrees",null,rot,1,Tween.TRANS_CUBIC,Tween.EASE_OUT)
	t.start()

	
func set_return_circling(tweenTime:float=1.0,delay:float=0.0):
	
	#Funny hack to make the drones stay in one place.
	#if delay>0:
	#	t.interpolate_property(sprite1,"global_position",null,sprite1.global_position,delay)
	#	t.interpolate_property(sprite2,"global_position",null,sprite2.global_position,delay)
	#	t.interpolate_property(sprite3,"global_position",null,sprite3.global_position,delay)
	
	#NOT GLOBAL!!!
	t.interpolate_property(sprite1,"position",null,radius,  tweenTime,Tween.TRANS_CUBIC,Tween.EASE_OUT,delay)
	t.interpolate_property(sprite2,"position",null,radius2, tweenTime,Tween.TRANS_CUBIC,Tween.EASE_OUT,delay)
	t.interpolate_property(sprite3,"position",null,radius3, tweenTime,Tween.TRANS_CUBIC,Tween.EASE_OUT,delay)
	
	t.interpolate_property(sprite1,"rotation_degrees",null,0.0,tweenTime,Tween.TRANS_CUBIC,Tween.EASE_OUT,delay)
	t.interpolate_property(sprite2,"rotation_degrees",null,0.0,tweenTime,Tween.TRANS_CUBIC,Tween.EASE_OUT,delay)
	t.interpolate_property(sprite3,"rotation_degrees",null,0.0,tweenTime,Tween.TRANS_CUBIC,Tween.EASE_OUT,delay)
	if delay>0:
		t.interpolate_property(self,"curState",null,STATES.spinning,0.0,Tween.TRANS_LINEAR,Tween.EASE_OUT,delay)
	else:
		curState=STATES.spinning
	t.start()
	timer=tweenTime+delay
	#

func getSprite(i:int)->Sprite:
	#print(i)
	if i==2:
		return sprite3
	elif i==1:
		return sprite2
	else: #If 0, or 3, or whatever...
		return sprite1


var explode = preload("res://Stages/EnemyExplodeSmall.tscn")
func _on_BossScarecrow_boss_killed():
	for sp in [sprite1,sprite2,sprite3]:
		var e = explode.instance()
		sp.visible=false
		e.position = sp.position
		e.get_node("s1").volume_db=-999
		get_parent().add_child(e)
		
