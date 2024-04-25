extends Node2D

enum Direction {
	ANY = 0,
	UP,   
	DOWN, 
	LEFT, 
	RIGHT,
}

export(bool) var spawn_enemies_when_entering = true
export(bool) var despawn_enemies_when_exiting = false

#var myRoomPosition:Vector2

const CAMERA_SCALE = 64
const ROOM_WIDTH = 20
const ROOM_HEIGHT = 12

var enemyInstances = []
var enemies = []
var enemyDatas = []
#var enemyMetadatas = []
func _ready():
	#myRoomPosition = global_position
	#print("[RespawnControl]")
		#set_process(false)
	for n in get_children():
		if (n is KinematicBody2D) == false:
			continue
		#print(n.filename)
		enemyInstances.push_back(n)
		enemies.push_back(load(n.filename))
		#enemyDatas
		var d = {
			'position':n.position,
			'name':n.name
		}
		
		var l = n.get_property_list()
		for v in l:
			#If this is an export var. I have no idea where this came from.
			if v['usage']==8199:
				#print(v)
				d[v['name']] = n.get(v['name'])
		enemyDatas.push_back(d)

func respawn_enemies():
	for i in range(enemies.size()):
		var prev = enemyInstances[i]
		if is_instance_valid(prev):
			print("[Spawner] enemy already exists named "+enemyDatas[i]['name']+", no need to respawn")
			continue
		var newEntity = enemies[i].instance()
		
		var kv:Dictionary = enemyDatas[i]
		#Need to set these values before adding child or _ready() will run first!
		for k in kv:
			#print("[Spawner] Set "+k+"="+String(kv[k]))
			newEntity.set(k,kv[k])
		self.add_child(newEntity)
		
		print("[Spawner] Spawned entity at "+String(enemyDatas[i].position))
		enemyInstances[i] = newEntity
		#print("Spawned duplicate entity at "+String(newEntity.position))
		#pass


func kill_enemies():
	for c in enemyInstances:
		if is_instance_valid(c):
			c.queue_free()

#direction = what direction to listen for
#spawn = if false, despawn, if true, spawn
func _on_LadderCameraAdjuster_camera_adjusted(_camera:Camera2D, newBounds:Array, spawn:bool=true):
	#var d = Direction.ANY
	var entering_room:bool = false
	if newBounds[1] >= global_position.y and newBounds[1] < global_position.y+720:
		#Moved into this room
		print("[Spawner] Player entered this room (camera y-axis == room top bound)")
		entering_room = true
	#elif newBounds[0] == global_position.x:
	#	print("[Spawner] Player entered this room (camera x-axis == room left bound)")
	#	entering_room = true
	#elif newBounds[1] < global_position.y:
	#	entering_room = false
	if entering_room and spawn_enemies_when_entering:
		respawn_enemies()
	elif entering_room == false and despawn_enemies_when_exiting:
		kill_enemies()
