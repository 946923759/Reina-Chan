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
#ALL OF MY PAIN
var sandFallSpr = preload("res://Stages_Reina/Scarecrow/sandFall.png")
var drawSize:Vector2

onready var sandNoise = $AudioStreamPlayer2D
var sandFallProgress:float=0.0
var sandFallProgress2:float=0.0

func _ready():
	if get_child_count()>1:
		#No idea how this works but for some reason
		#AudioStreamPlayer2D isn't always child 0 and
		#the shape isn't always child 1?
		#I know there's room for optimization here but
		#this is good enough for now
		for c in get_children():
			if c is CollisionShape2D and c.shape is RectangleShape2D:
				drawSize=c.shape.extents
		
func _draw():
	
	#draw_texture_rect(bottom[j],Rect2(0,16,region_rect.size.x,height*16),false)
	#tex, dest rect, source rect
	draw_texture_rect_region(bottom[j],
		#x,y,width,height
		Rect2(-drawSize.x,-drawSize.y+sandFallProgress2*2,drawSize.x*2,sandFallProgress*2-sandFallProgress2*2),
		Rect2(16+8,0,drawSize.x/2,sandFallProgress/2-sandFallProgress2/2) #I have no idea how this works
	)
	
	draw_texture_rect_region(sandFallSpr,
		Rect2(-drawSize.x,-drawSize.y-8+sandFallProgress2*2,drawSize.x*2,8),
		Rect2(0,4*j,drawSize.x/2,2)
	)
	draw_set_transform(Vector2(0,0),PI,Vector2(1,1))
	draw_texture_rect_region(sandFallSpr,
		Rect2(-drawSize.x,-sandFallProgress*2+drawSize.y-8,drawSize.x*2,8),
		Rect2(0,4*(3-j),drawSize.x/2,2)
	)

var t:float = 0
#This timer controls if the sand will push you down or not.
#0-1 sand goes from invisible to visible
#1-2 sand is visible and will push you down
#2-3 sand goes from visible to invisible
#3+ do nothing
var timer:float = 0.0

var oneSixtyth:float=0.0
var j:int=0
func _process(delta):
	
	t+=delta
	#timer+=delta
	#oneSixtyth+=delta
	if Engine.editor_hint:
		_ready()
		sandFallProgress=drawSize.y
		if t > .1:
			t=0
			j+=1
			if j==3:
				j=0
		update()
		return
	
	
	
	if sandFallProgress < drawSize.y:
		if sandFallProgress==0.0:
			sandNoise.play()
		sandFallProgress+=delta*200
	else:
		timer+=delta
		if sandFallProgress2 > drawSize.y:
			if is_instance_valid(lastTouchedPlayer):
				lastTouchedPlayer.clearLockedMovement()
				lastTouchedPlayer=null
			timer=0
			sandFallProgress=0
			sandFallProgress2=0
			stage=0
		else:
			sandFallProgress2+=delta*200
			
	if stage==1:
		#print("a")
		if lastTouchedPlayer.global_position.y>=global_position.y+drawSize.y - 64:
			#print("Done!")
			stage=0
			lastTouchedPlayer.clearLockedMovement()
		else:
			lastTouchedPlayer.global_position.y+=400*delta
			oneSixtyth=0.0
	if t > .1:
		t=0
		j+=1
		if j==3:
			j=0
	#Can be optimized, probably
	update()


var stage=0
var lastTouchedPlayer:KinematicBody2D
func run_event(player:KinematicBody2D):
	if (    player.global_position.y+40<= global_position.y-drawSize.y/2+sandFallProgress #bottom
		and player.global_position.y+40>= global_position.y-drawSize.y/2+sandFallProgress2+32 #top
		):
		if stage==0:
			player.set_collision_mask_bit(0,false)
			player.set_collision_layer_bit(0,false)
			player.lockMovementQueue([
				[0,Vector2(0,0),"",false],
				[999,Vector2(0,0),"Hurt",true]
			])
			stage=1
			lastTouchedPlayer=player
			#print("Locked movement")
			#events aren't processed during locked movement,
			#so _process() will handle it.
			
	#if oneSixtyth>1/60: #Lock to the frame rate
	#	oneSixtyth=0.0
		#player.velocity.y+=100
