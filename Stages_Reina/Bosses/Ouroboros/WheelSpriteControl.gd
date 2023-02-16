extends Node2D
tool

const SPEED = 150
onready var w1 = $Wheel1
onready var w2 = $Wheel2

var frame setget set_frame,get_frame
var flip_h:bool setget set_flip,get_flip

var is_dead:bool=false

export(Vector2) var radius = Vector2(16,0)
var radius2:Vector2
export(float,0.1,5) var speed = 0.5

export(bool) var animate_in_editor=true setget set_dbg_anim,get_dbg_anim

func set_dbg_anim(s):
	set_process(s)
func get_dbg_anim():
	return is_processing()

func _ready():
	radius2=radius.rotated(2.0 * PI/2)
	
	set_process(Engine.editor_hint)
	if !Engine.editor_hint:
		self.visible=false

func playIntro():
	self.visible=true
	w1.play("intro")
	w2.play("intro")
	w1.connect("animation_finished",self,"set_process",[true])

func play(anim:String):
	w1.play(anim)
	w2.play(anim)
	
func set_frame(f):
	w1.frame=f
	w2.frame=f
func get_frame():
	return w1.frame

func set_flip(b):
	w1.flip_h=b
	w2.flip_h=b
func get_flip():
	return w1.flip_h

var rot:float = 0
func _process(delta):
	
	if is_dead:
		play("die")
		if get_frame()>=4:
			visible=false
		return
	
	var rotateBy:float = 2.0 * PI * delta*speed
		
	# TODO: I'm pretty sure there's some way to just subtract it from
	# rotateBy instead of having to create 3 variables
	radius = radius.rotated(rotateBy)
	radius2 = radius2.rotated(rotateBy)
	#I know this check looks stupid but the editor constantly bugs out in tool mode
	if is_instance_valid(w1) and is_instance_valid(w2):
		w1.position= radius+Vector2(64,0)
		w2.position= radius2+Vector2(-64,0)
		
	#rot-=delta*SPEED
	#if rot<0:
	#	rot=360-rot
	#w1.rotation_degrees=rot
	#w2.rotation_degrees=rot
	#w1.position.x -= delta*100
	#w2.position.x += delta*100
	
	#if w1.position.x<=-32:
	#	w1.position.x = 32
	#	w2.position.x = -32
