extends VisibilityNotifier2D

export var spawn_cooldown = 1
var time: float = 0.0
var source_scene
var exported_vars: Array = []

func _ready():
	#set_process(false)
	var n = get_child(0)
	#print(n.filename)
	source_scene = load(n.filename)
	var l = n.get_property_list()
	for v in l:
		if v['usage']==8199: #If this is an export var. I have no idea where this came from.
			print("[Spawner] "+String(v))
			exported_vars.push_back([ v['name'], n.get(v['name']) ])

func _process(delta):
	time+=delta
	if time > spawn_cooldown:
		spawn_entity()
		time=0

func spawn_entity():
	var newEntity = source_scene.instance()
	for v in exported_vars:
		newEntity.set(v[0],v[1])
	newEntity.position=Vector2(0,0)
	self.add_child(newEntity)
	print("Spawned duplicate entity at "+String(newEntity.position))
	#pass
