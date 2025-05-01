tool
extends Node2D

export(float) var player_platform_radius = 256.0

func draw_circle_arc(center:Vector2, radius:float, angle_from:float, angle_to:float, color:Color):
	var nb_points = 32
	var points_arc = PoolVector2Array()

	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)

	for index_point in range(nb_points):
		draw_line(points_arc[index_point], points_arc[index_point + 1], color, 2.0)

func _draw():
	draw_circle_arc(Vector2(0,0), player_platform_radius, 0, 360, Color.red)

func _ready():
	if !Engine.editor_hint:
		#get_child(0).position=Vector2(player_platform_radius,0)
		for i in range(get_child_count()):
			var c = get_child(i)
			var nPos = Vector2(player_platform_radius,0).rotated(i/float(get_child_count())*2*PI)
			c.position = nPos
	set_process(!Engine.editor_hint)
	set_physics_process(!Engine.editor_hint)

func _physics_process(delta):
	for c in get_children():
		# 1 full circle (i.e. 2 * PI) every second, clockwise
		var rotateBy:float = delta
		
		var nPos:Vector2 = c.position.rotated(rotateBy)
		c.position_wrapper=Vector2(0,0).direction_to(nPos)*player_platform_radius
