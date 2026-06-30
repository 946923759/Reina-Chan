extends Node2D

onready var t1 = $Sprite1
onready var t2 = $Sprite2
onready var t3 = $Sprite3

var speed = 600.0

func _process(delta):
	t1.position.y -= delta*speed
	t2.position.y -= delta*speed
	t3.position.y -= delta*speed

	if t2.position.y <= 0:
		t1.position.y = t2.position.y
		t2.position.y += 704
		t3.position.y = t2.position.y*2
