tool
extends Node2D

export(float,0,360,7.5) var rotate_degrees = 0.0

func _draw():
	
	for i in range(9):
		var p = Vector2.ONE.rotated(deg2rad(i*45))*200
		draw_circle(p,5.0,Color.white)
	for i in range(9):
		var p = Vector2.ONE.rotated(deg2rad(i*45+rotate_degrees))*200
		draw_circle(p,5.0,Color.blueviolet)
	

func _process(delta):
	update()
