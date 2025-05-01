extends Node2D
signal all_enemies_killed()
var enemies = []

func _ready():
	var idx = 0
	for c in get_children():
		enemies.push_back(c)
		c.connect("tree_exited",self,"freed",[idx])
		idx+=1
	
func freed(i):
	enemies[i] = null
	for e in enemies:
		if is_instance_valid(e):
			#print(enemies)
			return
	#print("all enemies killed!")
	#If we got here, all enemies were freed
	emit_signal("all_enemies_killed")
