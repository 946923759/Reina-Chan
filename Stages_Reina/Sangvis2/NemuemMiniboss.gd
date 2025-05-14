extends "res://Stages_Reina/Sangvis2/CircleAndSpinningPlatforms.tres.gd"
signal all_enemies_killed()

var idx = 0
var enemies = []
var emit_all_killed:bool=true

func _ready():
	#return
	var i = 0
	for c in get_children():
		var e = c.get_node("NemeumStationary")
		e.connect("tree_exited",self,"check_enemies",[i])
		enemies.push_back(e)
		#e.set_physics_process(false)
		e.timer=.25*i
		i+=1
	#set_process(false)
	set_physics_process(false)

#TODO: This fires if the entire scene is getting reloaded, there should be some way to not do that
func check_enemies(i):
	enemies[i]=null
	for e in enemies:
		if is_instance_valid(e):
			return
	
	print("All killed!")
	emit_signal("all_enemies_killed")
		

var timer = 3.0
func _physics_process(delta):
	return

	timer += delta
	if timer>3:
		timer-=3
		
		var any_valid_enemies:bool = false
		for i in range(get_child_count()):
			if is_instance_valid(enemies[i]):
				any_valid_enemies=true
				enemies[i].reset()
		
		if !any_valid_enemies:
			if emit_all_killed:
				print("All killed!")
				emit_signal("all_enemies_killed")
				emit_all_killed = false
			return
		
		var next = idx+1
		while true:
			if next >= len(enemies):
				next = 0
			elif is_instance_valid(enemies[next]):
				idx = next
				break
			else:
				next+=1
			
		enemies[idx].set_physics_process(true)
		#print(idx)
	pass
