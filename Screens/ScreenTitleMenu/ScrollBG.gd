extends Node2D

onready var obj1 = get_child(0)
onready var obj2 = get_child(1)

export(float,1,40,.5) var obj1_scroll_speed = 10.0
export(float,1,40,.5) var obj2_scroll_speed = 40.0

func _process(delta):
	if Input.is_key_pressed(KEY_TAB):
		delta*=4
	obj1.region_rect.position.x+=delta*obj1_scroll_speed
	obj2.region_rect.position.x+=delta*obj2_scroll_speed
	
	
	var s = get_viewport().get_visible_rect().size
	#print(s)
	#I can't tell what the fuck is going on here so I give up
	obj2.position.y = s.y/2+16

	for o in [obj1, obj2]:
		if o.region_rect.position.x > o.region_rect.size.x:
			o.region_rect.position.x -= o.region_rect.size.x
	#
