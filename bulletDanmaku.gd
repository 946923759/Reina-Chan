extends "res://Stages_Reina/Enemies/bulletDinergate.gd"
#BulletDanmaku - It's like a bullet but COOLER

export(int,"normal","reverse_x_pos") var special_type=0
export(float,0.1,2,.1) var time_to_reverse = 1
export(float,0.0,0.5,.01) var reverse_time_increase=0.0
#export(float,0.0,0.5,.01) var slowdown_speed=0.0
#export()
export(Vector2) var CubicSpread = Vector2(0,0)

func init(t_movement):
	movement = t_movement
	# warning-ignore:return_value_discarded
	$Area2D.connect("body_entered",self,"objectTouched")
	if timer < 0.0:
		set_process(true)
		self.visible=false
	else:
		set_physics_process(true)

var timer:float = 0.0
const FLOAT_MAX = 1.79769e308
func _physics_process(delta):
	timer+=delta
	
	#This can also be used to make bullets rebound,
	#but that's probably not what you want.
	#movement+=CubicSpread
	#CubicSpread+=CubicSpread
	movement+=CubicSpread*delta
	
	if special_type==1:
		if timer>=time_to_reverse:
			movement.x*=-1
			time_to_reverse+=reverse_time_increase
			timer=0
	#._physics_process(delta)

func _process(delta):
	timer+=delta
	if timer >=0:
		self.visible=true
		set_process(false)
		set_physics_process(true)
