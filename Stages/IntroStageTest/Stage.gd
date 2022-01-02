extends Node

var LADDER_TILE_ID = -999
var LADDER_TOP_TILE_ID = -999

#for zoom control
var leftSide = 2160 #54*16*2.5
var rightSide = 2920 #73*16*2.5
onready var player = $Player

func _ready():
	set_process(true)
	var c = $Player/Camera2D
	c.limit_left = 52*16*2.5
	c.limit_top = 26*16*2.5
	c.limit_right = 80*16*2.5
	c.limit_bottom = 55*16*2.5

func _process(delta):
	if player.position.x > leftSide and player.position.x < rightSide:
		var progress = (player.position.x - leftSide)/(rightSide-leftSide)
		var zoom = .75+sin((progress)*(PI/2))/4
		#print(zoom)
		player.get_node("Camera2D").zoom = Vector2(zoom,zoom)
