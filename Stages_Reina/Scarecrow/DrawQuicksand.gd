#tool
extends Sprite

# I know this is really stupid but doing it using one tilemap
# would have been too hard.
#
# Or god forbid I have to use another shader to change the pixel colors.
var bottom = [
	preload("res://Stages_Reina/Scarecrow/quicksand_bottom.png"),
	preload("res://Stages_Reina/Scarecrow/quicksand_bottom_2.png"),
	preload("res://Stages_Reina/Scarecrow/quicksand_bottom_3.png")
]
var height

func _ready():
	region_rect=Rect2(0,0,region_rect.size.x,32)
	print(region_rect.size.x)
	height = get_parent().quicksand_draw_height*16
	pass # Replace with function body.

func _draw():
	
	#draw_texture_rect(bottom[j],Rect2(0,16,region_rect.size.x,height*16),false)
	#tex, dest rect, source rect?
	draw_texture_rect_region(bottom[j],
		Rect2(0,16,region_rect.size.x,height),
		Rect2(0,0,region_rect.size.x,height)
	)

var t:float = 0
var j:int=0
func _process(delta):
	t+=delta
	if t > .2:
		t=0
		j+=1
		if j==3:
			j=0
		update()
		region_rect=Rect2(0,j*16,region_rect.size.x,32)
		
