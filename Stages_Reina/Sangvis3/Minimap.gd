extends Node2D

const WIDTH = 8
const HEIGHT = 7
const NUM_ROWS = 3
const NUM_COLUMNS = 5

var rooms:Dictionary = {}

var player_current_room:Vector2 = Vector2(0,0)
var player

func _ready():
	for n in get_children():
		#TODO: Doesn't work because of inherited types
		if n is Node:
			print(n.name)

func _process(delta):
	if not player:
		player = get_node("/root/Node2D").get_player()
		return
	else:
		var tmp_pos:Vector2 = player.pos2cell(player.position)
		
		player_current_room = Vector2( floor(tmp_pos.x/20), floor(tmp_pos.y/12) )
		
		$BitmapSprite.text = String(player_current_room.x)+", "+String(player_current_room.y)
		#$Label.text = String(player_current_room)

#I'm sure the performance of this is garbage
func _draw():
	draw_rect(Rect2(0,0,NUM_COLUMNS*WIDTH,NUM_ROWS*HEIGHT),Color.darkblue)
	for y in range(NUM_ROWS):
		for x in range(NUM_COLUMNS):
			draw_rect(Rect2(x*WIDTH,y*HEIGHT,WIDTH,HEIGHT),Color.darkslategray,false)
	draw_rect(Rect2(NUM_COLUMNS/2*WIDTH,NUM_ROWS/2*HEIGHT,WIDTH,HEIGHT),Color(1,1,1,.5),true)
