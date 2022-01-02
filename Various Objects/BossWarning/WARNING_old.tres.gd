extends Sprite

var tex = preload("res://Various Objects/BossWarning/WARNING.png")

var toDraw = 0

func _draw():
	#draw_texture_rect_region(tex,Rect2(destPos[pos]*2-Vector2(32,32),destRect),Rect2(24*frame,0,24,24))
	draw_texture_rect_region(tex,Rect2(Globals.SCREEN_CENTER_X-821/2,Globals.SCREEN_CENTER_Y-216/2,toDraw,216),Rect2(0,0,toDraw,216))


var time:float = 0.0
func _process(delta):
	time+=delta
	toDraw=min(821,floor(time*300))
	update()
	if toDraw >=821:
		set_process(false)
