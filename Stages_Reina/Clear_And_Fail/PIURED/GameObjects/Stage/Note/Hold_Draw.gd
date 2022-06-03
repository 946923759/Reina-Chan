tool
extends Node2D

#var holdTex = preload
const TEXTURE_WIDTH = 576/6
const TEXTURE_HEIGHT = 288/2
const FRAMES_IN_TEXTURE = 6

var curFrame:int=0

const holdTex = preload("res://Stages_Reina/Clear_And_Fail/PIURED/Resources/NoteSkin/PRIME/DownLeft Hold 6x1.PNG")
func _draw():
	#draw_texture(holdTex,Vector2(0,0))
	#draw_texture_rect(holdTex,Rect2(0,0,576/6,288/2),false)
	draw_texture_rect_region(holdTex,
		Rect2(-48,0,TEXTURE_WIDTH,TEXTURE_HEIGHT),
		Rect2(curFrame*TEXTURE_WIDTH,0,TEXTURE_WIDTH,TEXTURE_HEIGHT)
	)


var timer:float=0.0
func _process(delta):
	timer+=delta
	if timer>0.066666667: #
		timer=0
		curFrame+=1
		if curFrame>=FRAMES_IN_TEXTURE:
			curFrame=0
		#print(String(curFrame))
		update()
	
func _ready():
	set_process(true)
	#if Engine.editor_hint:
	#	set_process(true)
