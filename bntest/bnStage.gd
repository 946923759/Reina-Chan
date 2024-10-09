extends Node2D

export(bool) var show_hitboxes_in_debug=false

var platformCenter:Vector2
var platformRectSize:Vector2 = Vector2(160,96)
onready var entities:Node2D = $Stage/AllEntities
#var entities:Node2D

#This is flipped and accessed like panels[y][x]
#onready var panels = [
#	[$Stage/AllPanels/Panel,  $Stage/AllPanels/Panel2, $Stage/AllPanels/Panel3, $Stage/AllPanels/Panel10, $Stage/AllPanels/Panel11, $Stage/AllPanels/Panel12],
#	[$Stage/AllPanels/Panel4, $Stage/AllPanels/Panel5, $Stage/AllPanels/Panel6, $Stage/AllPanels/Panel13, $Stage/AllPanels/Panel14, $Stage/AllPanels/Panel15],
#	[$Stage/AllPanels/Panel7, $Stage/AllPanels/Panel8, $Stage/AllPanels/Panel9, $Stage/AllPanels/Panel16, $Stage/AllPanels/Panel17, $Stage/AllPanels/Panel18],
#]

onready var panels = [
	[$Stage/AllPanels/Panel,   $Stage/AllPanels/Panel4,  $Stage/AllPanels/Panel7],
	[$Stage/AllPanels/Panel2,  $Stage/AllPanels/Panel5,  $Stage/AllPanels/Panel8],
	[$Stage/AllPanels/Panel3,  $Stage/AllPanels/Panel6,  $Stage/AllPanels/Panel9],
	[$Stage/AllPanels/Panel10, $Stage/AllPanels/Panel13, $Stage/AllPanels/Panel16],
	[$Stage/AllPanels/Panel11, $Stage/AllPanels/Panel14, $Stage/AllPanels/Panel17],
	[$Stage/AllPanels/Panel12, $Stage/AllPanels/Panel15, $Stage/AllPanels/Panel18]
]

onready var attackQueue = $Stage/AttackQueue

func _ready():
	
	for c in entities.get_children():
		c.init(self)
	
	for y in range(3):
		for x in range(6):
			panels[x][y].panelPos=Vector2(x,y)

func _physics_process(delta):
	for attack in attackQueue.get_children():
		attack.frame_process(delta)
		
	if Input.is_key_pressed(KEY_0):
		debug_test_shader()

func debug_test_shader():
	var t = get_tree().create_tween()
	t.set_parallel()
	#entities.get_child(0).sprite.get_material().set_shader_param("amount", 50)
	t.tween_property(entities.get_child(0).sprite.get_material(),"shader_param/amount",0.0,1.0).from(50.0).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	for c in entities.get_children():
			t.tween_property(c.sprite,"modulate:a",1.0,1.0).from(0.0)
		#c.sprite.get_material().set_shader_param("amount", 50)


func get_obj_at_pos(v2:Vector2, is_attack:bool=true):
	if is_attack and show_hitboxes_in_debug:
		bright_panel_at_pos(v2, 2)
		
	for c in entities.get_children():
		if v2==c.charaPos:
			return c
	
	return null

func add_obj_at_pos(obj:Node2D, v2:Vector2):
	entities.add_child(obj)
	obj.charaPos = v2
	obj.init(self)

#func get_panel_at_pos(pos:Vector2):
#	var x = int(pos.x)
#	var y = int(pos.y)
#	if x>0 and x<7:
#		if y>0 and y<4:
#			return panels[x-1][y-1]
#	return null

func bright_panel_at_pos(pos:Vector2, brightLevel:int=1):
	var x = int(pos.x)
	var y = int(pos.y)
	if x>=0 and x<6:
		if y >= 0 and y<3:
			panels[x][y].bright=brightLevel

#init(stageRef_:Node2D, playerRef_:Node2D, spawnPoint_:Vector2=Vector2(0,0)):
func push_attack(atk, playerOrCPU:Node2D, spawnPoint, facing:int=1):
	attackQueue.add_child(atk)
	#Make sprite center of platform then + platform index
	atk.position = platformRectSize/2+spawnPoint*platformRectSize
	atk.scale = Vector2(4,4)
	print("Spawn attack at ",spawnPoint, " from ",facing, " side")
	atk.init(self, playerOrCPU, spawnPoint, facing)
