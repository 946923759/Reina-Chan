tool
extends Node2D
#export(Vector2) var room_bound_offset = Vector2(0,0) setget set_local_offset

const CAMERA_SCALE = 64;
const ROOM_WIDTH = 20
const ROOM_HEIGHT = 12

func _draw():
	if OS.is_debug_build():
		var boundaryEnd:Vector2 = Vector2(ROOM_WIDTH,ROOM_HEIGHT)*CAMERA_SCALE
		#rightBoundaryStart.x -= 4
		# draw_line(
		#	from: Vector2, 
		#	to: Vector2, 
		#	color: Color, 
		#	width: float = 1.0, 
		#	antialiased: bool = false
		# )
		
		#Left line
		draw_line(
			Vector2(0,0),
			Vector2(0,boundaryEnd.y),
			Color.red,
			8,
			false
		)
		
		#Top line
		draw_line(
			Vector2(0,0),
			Vector2(boundaryEnd.x,0),
			Color.red,
			8,
			false
		)
		#Right line
		draw_line(
			boundaryEnd,
			Vector2(boundaryEnd.x,0),
			Color.red,
			8,
			false
		)
		#Bottom line
		draw_line(
			boundaryEnd,
			Vector2(0,boundaryEnd.y),
			Color.red,
			8,
			false
		)
