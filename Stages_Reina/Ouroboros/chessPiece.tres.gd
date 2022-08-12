tool
extends StaticBody2D

"""
For everyone else that doesn't remember how chess works:
	- Kings can only move one step at a time in any direction
	- Queen can move any steps at a time in any direction
	- Bishop can move any steps, but only diagonally.
	- Knight can move in an L shape in any direction, and can additionally jump over other pieces.
	- Pawns can only move up one square, or two at the start. These are not used in this minigame, so that can be ignored.
"""

export(int,"king","queen","bishop","knight","rook",'pawn') var piece_type = 1 setget set_piece_type
export(int,"White","Black") var piece_color = 0 setget set_piece_color
export(PoolStringArray) var alternate_win_conditions

var starting_grid_position:Vector2
var grid_position:Vector2

var tex = load("res://Stages_Reina/Ouroboros/chess.png")

func _ready():
	starting_grid_position=(position-Vector2(32,32))/64

func _draw():
	draw_texture_rect_region(tex,
		Rect2(-33,-33,66,66),
		Rect2(22*piece_type,piece_color*22,22,22)
	)

func set_piece_type(t:int):
	piece_type=t
	update()
	
func set_piece_color(c:int):
	piece_color=c
	update()

func move_down():
	set_process(true)

func _process(delta):
	if position.y < grid_position.y*64+32:
		position.y+=1000*delta
	elif position.x < grid_position.x*64+32:
		position.x+=1000*delta
	else:
		#get_parent().is_empty_space_at(Vector2(grid_position)):
		
		set_process(false)
