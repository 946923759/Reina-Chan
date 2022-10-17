extends Node2D

var tex = preload("res://Stages_Reina/Ouroboros/Sparkles.png")

var t:float = 0
var j:int=0

func _draw():
	
	#draw_texture_rect(bottom[j],Rect2(0,16,region_rect.size.x,height*16),false)
	
	for i in range(-50,50):
		for ij in range(-25,25):
			#tex, dest rect, source rect?
			draw_texture_rect_region(tex,
				Rect2(i*128,ij*128,9*4,8*4),
				Rect2((j+i+ij)%3*9,0,9,8)
			)

func _process(delta):
	if visible==false:
		return
	t+=delta
	if t > .2:
		t=0
		j+=1
		if j==3:
			j=0
		update()
