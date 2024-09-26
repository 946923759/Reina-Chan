extends Node2D

const WIDTH = 8
const HEIGHT = 7
const NUM_ROWS = 3
const NUM_COLUMNS = 5
#const NUM_ROOM_COLUMNS = 16
#const NUM_ROOM_ROWS = 13

var rooms:Dictionary = {}

export(Texture) var map_texture
var prev_room:Vector2 = Vector2(0,0)
var player_current_room:Vector2 = Vector2(0,0)
var player

onready var blacklistedRooms = [
	Vector2(6,6),
	Vector2(8,5),
	Vector2(6,8),
	Vector2(8,8)
]

func _ready():
#	for n in get_children():
#		#TODO: Doesn't work because of inherited types
#		if n is Node:
#			print(n.name)
	$BitmapFont.visible = $BitmapFont.visible and OS.is_debug_build()
	pass

func _process(delta):
	if not player:
		player = get_node("/root/Node2D").get_player()
		return
	else:
		var tmp_pos:Vector2 = player.pos2cell(player.position)
		
		player_current_room = Vector2(tmp_pos.x/20, tmp_pos.y/12).floor()
		if player_current_room != prev_room:
			if player_current_room in blacklistedRooms:
				return
			prev_room=player_current_room
			CheckpointPlayerStats.visited_rooms[prev_room] = true
			update()
		
		$BitmapFont.text = String(player_current_room.x)+","+String(player_current_room.y)
		#if (player_current_room.x > NUM_ROOM_COLUMNS or player_current_room.y > NUM_ROOM_ROWS):
		#	$BitmapFont.text = "Out of range"
		#else:
		#var room_idx:int = player_current_room.y*NUM_ROOM_COLUMNS+player_current_room.x
		#$BitmapFont.text = String(player_current_room.x)+","+String(player_current_room.y)+">"+String(room_idx)
		
		

#I'm sure the performance of this is garbage
func _draw():
	draw_rect(Rect2(0,0,NUM_COLUMNS*WIDTH,NUM_ROWS*HEIGHT),Color.darkblue)
	
	#void draw_texture_rect_region(
	#	texture: Texture, 
	#	dest_rect: Rect2, 
	#	src_rect: Rect2, 
	#	modulate: Color = Color( 1, 1, 1, 1 ), transpose: bool = false, normal_map: Texture = null, clip_uv: bool = true)
	
	for y in range(NUM_ROWS):
		for x in range(NUM_COLUMNS):
			var this_room:Vector2 = Vector2(
				x-2+player_current_room.x,
				y-1+player_current_room.y
			)
			var dest_xy_pos:Vector2 = Vector2(
				(player_current_room.x+x+1),
				(player_current_room.y+y)
			)
			if this_room in CheckpointPlayerStats.visited_rooms:
				#print("Drawing "+String(this_room)+" at ",x,"x",y)
				draw_texture_rect_region(
					map_texture,
					Rect2(
						#Draw starting at each block position (top left align)
						x*WIDTH, y*HEIGHT,
						#Draw WIDTHxHEIGHT region
						WIDTH, HEIGHT
					),
					Rect2(
						dest_xy_pos*Vector2(WIDTH,HEIGHT),
						Vector2(WIDTH, HEIGHT)
					)
				)
	
#	draw_texture_rect_region(
#		map_texture,
#		# Draw starting at the top left, draw rightwards and downwards for NUM_COLUMNS, NUM_ROWS
#		Rect2(0,0,WIDTH*NUM_COLUMNS, HEIGHT*NUM_ROWS),
#
#		Rect2(
#			Vector2((player_current_room.x+1)*WIDTH,player_current_room.y*HEIGHT),
#			Vector2(WIDTH*NUM_COLUMNS, HEIGHT*NUM_ROWS)
#		)
#	)
	
	#Draw lines
	for y in range(NUM_ROWS):
		for x in range(NUM_COLUMNS):
			draw_rect(Rect2(x*WIDTH,y*HEIGHT,WIDTH,HEIGHT),Color.darkslategray,false)
	#Make the center glow
	#draw_rect(Rect2(NUM_COLUMNS/2*WIDTH,NUM_ROWS/2*HEIGHT,WIDTH,HEIGHT),Color(1,1,1,.5),true)
