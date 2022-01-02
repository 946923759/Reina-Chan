extends Object

var stageRoot:Node2D
var bullets = [null,null,null]

func _init(_stageRoot):
	stageRoot=_stageRoot

func push_bullet(ref) -> bool:
	#print("==========")
	#print(get_array_as_int())
	var pushed = false
	for i in range(3):
		#print(is_instance_valid(bullets[i]))
		#print(is_bullet_onscreen(i))
		if is_instance_valid(bullets[i]) and is_bullet_onscreen(i):
			ref.add_collision_exception_with(bullets[i])
			
		elif pushed==false:
			#print("Added to "+str(i))
			bullets[i]=ref
			pushed=true
			
	#if !pushed:
	#	printerr("Failed to store bullet reference, there are already 3 bullets in the array.")
	#return false
	return pushed
	
func get_num_bullets()->int:
	var n = 0
	for i in range(3):
		if is_instance_valid(bullets[i]) and is_bullet_onscreen(i):
			n+=1
		else:
			bullets[i]=null #Need to clear stale pointers due to a godot quirk
	return n
	
func get_raw_bullet_pos(i:int)->Vector2:
	if is_instance_valid(bullets[i]):
		return bullets[i].position
	return Vector2()

func is_bullet_onscreen(i:int)->bool:
	if !is_instance_valid(bullets[i]):
		#bullets[i]=null 
		return false
	#print("Bullet "+String(i)+" still valid.");
	return get_onscreen_bullet_pos(i).x > -10 and get_onscreen_bullet_pos(i).x < Globals.gameResolution.x+10

func get_onscreen_bullet_pos(i:int)->Vector2:
	if is_instance_valid(bullets[i]):
		return stageRoot.position + stageRoot.get_canvas_transform().origin + bullets[i].position
	bullets[i]=null
	return Vector2()

func get_array_as_int():
	var t = [0,0,0]
	for i in range(3):
		if is_instance_valid(bullets[i]):
			t[i]=1
	return t
