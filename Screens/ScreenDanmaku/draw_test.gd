extends Node2D

var base_position = Vector2(1280,720)/2
var radius = 15.0

export(float,0,90,1) var dot_index = 0

func _draw():
	
	for i in range(90):
		#var p:Vector2 = base_position + Vector2(i*radius*cos(i), i*radius*sin(i) )
		#var p = base_position
		#draw_rect(Rect2(p,Vector2(10,10)),Color.white)
		draw_line(base_position+calc_r(radius,i), base_position+calc_r(radius,i+1),Color.white)
	draw_rect(Rect2(base_position+calc_r(radius,dot_index),Vector2(10,10)),Color.red)

func _process(delta):
	update()
	
func _input(event):
	if Input.is_key_pressed(KEY_3):
		var t = create_tween()
		t.tween_property(self,"dot_index", 15.0, 2.5).from(0.0)

func calc_r(radius, i) -> Vector2:
	return Vector2(i*radius*cos(i), i*radius*sin(i) )
