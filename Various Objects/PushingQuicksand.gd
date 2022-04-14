tool
extends StaticBody2D

var event_ID = Globals.EVENT_TILES.CUSTOM_EVENT

# I know this is really stupid but doing it using one tilemap
# would have been too hard.
#
# Or god forbid I have to use another shader to change the pixel colors.
var bottom = [
	preload("res://Stages_Reina/Scarecrow/quicksand_bottom.png"),
	preload("res://Stages_Reina/Scarecrow/quicksand_bottom_2.png"),
	preload("res://Stages_Reina/Scarecrow/quicksand_bottom_3.png")
]
var drawSize:Vector2

func _ready():
	if get_child_count()>0 and (get_child(0) as CollisionShape2D).shape is RectangleShape2D:
		drawSize=get_child(0).shape.extents
		
func _draw():
	
	#draw_texture_rect(bottom[j],Rect2(0,16,region_rect.size.x,height*16),false)
	#tex, dest rect, source rect?
	draw_texture_rect_region(bottom[j],
		Rect2(-drawSize.x,-drawSize.y,drawSize.x*2,drawSize.y*2),
		Rect2(16+8,0,drawSize.x/2,drawSize.y/2)
	)

var t:float = 0
var oneSixtyth:float=0.0
var j:int=0
func _process(delta):
	t+=delta
	oneSixtyth+=delta
	if t > .2:
		t=0
		j+=1
		if j==3:
			j=0
		update()
	if Engine.editor_hint:
		_ready()

func run_event(player:KinematicBody2D):
	if oneSixtyth>1/60: #Lock to the frame rate
		oneSixtyth=0.0
		player.velocity.y+=100
