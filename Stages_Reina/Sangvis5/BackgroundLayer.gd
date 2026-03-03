extends Node2D

var smallRockTexture:Texture = preload("res://Various Objects/boulderSmall.png")
var rockTexture:Texture = preload("res://Various Objects/boulder.png")

var rocks = []
var rockSpeed = []

#var rocksSmall = []

const NUM_ROCKS = 16

func _ready():
	rocks.resize(NUM_ROCKS)
	rockSpeed.resize(NUM_ROCKS)
	for i in range(NUM_ROCKS):
		rocks[i] = Vector2(rand_range(20,1240), rand_range(20,700))
		
		rockSpeed[i] = rand_range(300,500)
		if i>=10:
			rockSpeed[i] *= 1.5

func _process(delta):
	#var rock = $Sprite
	#rock.position.y -= delta*400
	#if rock.position.y < -100:
	#	rock.position.y = 750
	for i in range(NUM_ROCKS):
		rocks[i] = rocks[i] - Vector2(0,delta*rockSpeed[i])
		if rocks[i].y < -100:
			rocks[i] = Vector2(rand_range(20,1240), 750)
			rockSpeed[i] = rand_range(300,500)
			if i>=10:
				rockSpeed[i] *= 1.5
	update()

func _draw():
	for i in range(10):
		#draw_texture(rockTexture, rocks[i])
		#draw_texture_rect(rockTexture,)
		draw_texture_rect_region(rockTexture, Rect2(rocks[i], rockTexture.get_size()*4), Rect2(0,0,16,16), Color.darkgray)
	for i in range(10,NUM_ROCKS):
		draw_texture_rect_region(smallRockTexture, Rect2(rocks[i], smallRockTexture.get_size()*4), Rect2(0,0,7,7), Color.darkgray)
