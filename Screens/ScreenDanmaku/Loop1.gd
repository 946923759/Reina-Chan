extends Node2D

const NUM_STARS = 10
var draws = []
var draws2 = []
var tex = preload("res://Screens/ScreenDanmaku/150299.png")

func _ready():
	draws.resize(NUM_STARS)
	draws2.resize(NUM_STARS)
	for i in range(NUM_STARS):
		draws[i] = Vector2(randi()%8, randi()%11)
		draws2[i] = Vector2(randi()%8, randi()%11)
	set_process(visible)

func _draw():
	for i in range(NUM_STARS):
		draw_texture_rect_region(
			tex,
			Rect2(draws[i]*16, Vector2(16,16)),
			Rect2(16,0,16,16)
		)
		draw_texture_rect_region(
			tex,
			Rect2(draws2[i]*16, Vector2(1,1)),
			Rect2(39,6,1,1),
			Color.white
		)
		#draw_

func _process(delta):
	for i in range(NUM_STARS):
		draws[i].y += delta*3
		draws2[i].y += delta*5
		if draws[i].y > 12:
			draws[i] = Vector2(randi()%8, -1)
			#draws[i].y = -1
		if draws2[i].y > 12:
			draws2[i] = Vector2(randi()%8, -1)
	update()
