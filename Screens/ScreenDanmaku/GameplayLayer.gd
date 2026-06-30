extends Node2D

const SCREEN_TOP = 0
const SCREEN_LEFT = 0
const SCREEN_RIGHT = 1280
const SCREEN_BOTTOM = 720
const SCREEN_CENTER_Y = 720/2

#export(Vector2) var playfield_limit = Vector2(640,360)
#
#func _draw():
#	#draw_rect(Rect2(Vector2.ZERO, playfield_limit), Color.red, false)
#	draw_rect(Rect2(1280-300, 200, 160, SCREEN_BOTTOM-200-200), Color.red, false)
#
#func _ready():
#	update()

func _process(delta):
	var elisa = $Boss
	#health <= MAX_HP-32*(phase+1)
	$TimeRemain.text = String($Boss.phase) + " " +String(elisa.MAX_HP-32*(elisa.phase)) + " " + String(elisa.health)
	#update()
