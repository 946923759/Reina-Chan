extends Node2D

func _draw():
	var LIM = 6
	var RANGE = 600
	var SPACING = RANGE/LIM
	#0,1,2,3,4,5
	
	for i in range(LIM):
		var y_pos = -RANGE/2 + i*SPACING
		#lol wtf?
		var color = Color(i*.20,float(i & 1),i*.16)
		draw_rect(Rect2(0,y_pos,100,SPACING),color)
	
	for i in range(LIM):
		#When i==3 y_pos should be 0
		
		var y_pos = ((i)-LIM/2.0)*SPACING+SPACING/2
		draw_line(
			Vector2(20, y_pos), 
			Vector2(0, y_pos),
			Color.aqua,
			4.0
		)
	draw_line(Vector2(0,-RANGE/2), Vector2(0,RANGE/2), Color.cornflower, 2.0)

func _process(delta):
	update()
