extends StaticBody2D

onready var spr = $Sprite
export (float,.1,10) var speed = 1
export (bool) var reverse = false
var drawSize:Vector2
var spr2 = preload("res://Stages_Reina/Sangvis1/waterfall1.png")
var frame:int = 0

func _ready():
	if get_child_count()>0:
		#No idea how this works but for some reason
		#AudioStreamPlayer2D isn't always child 0 and
		#the shape isn't always child 1?
		#I know there's room for optimization here but
		#this is good enough for now
		for c in get_children():
			if c is CollisionShape2D and c.shape is RectangleShape2D:
				drawSize=c.shape.extents*2
				#print(drawSize)

var elapsed = 0.0
var elapsed2 = 0.0
func _process(delta):
	elapsed+=delta
	if elapsed > .05:
		elapsed = 0
		spr.offset = Vector2(randf()-1, randf()-1)
		update()
	elapsed2+=delta
	if elapsed2 > .1:
		elapsed2=0
		frame-=1
		if frame<0:
			frame=2

func _draw():
	draw_set_transform(Vector2(0,0),PI,Vector2(1,1))
	var realTopLeft:Vector2 = drawSize/-2
	#var realDrawSize:Vector2 = drawSize*2
	#draw_texture_rect(bottom[j],Rect2(0,16,region_rect.size.x,height*16),false)
	#tex, dest rect, source rect
	for x in range(0,drawSize.x,16):
		draw_texture_rect_region(spr2,
			#x,y,width,height
			Rect2(realTopLeft.x+x-spr.offset.x,realTopLeft.y-8-spr.offset.y,16,16),
			Rect2(frame*16,0,16,16)
		)
