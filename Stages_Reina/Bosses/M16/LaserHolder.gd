extends Node2D

const ANIMATION_LENGTH = 2
func _ready():
	
	set_process(false)
	var s = get_child_count()
	for i in range(s):
		var c = get_child(i)
		c.set_process(false)
		c.x=i/float(s)*(PI*2)
	visible=false

var time:float=0.0
func _process(delta):
	if time < ANIMATION_LENGTH-.5:
		for c in get_children():
			c.frame_=max(0,3-time*3)
	else:
		for c in get_children():
			c.frame_ = (time- 1.5)*2 #float 0 to .5
		
	time+=delta
	if time>ANIMATION_LENGTH:
		set_process(false)
		visible=false
		#for c in get_children():
		#	c.visible=false
		
		
func anim():
	#print("aaa")
	time=0
	set_process(true)
	for c in get_children():
		c.set_process(true)
		#c.visible=true
	visible=true
