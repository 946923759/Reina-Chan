extends CanvasLayer

onready var s = $Sprite

func _ready():
	set_process(false)
	s.visible=false

func _on_Node2D_ready():
	for roomNode in get_parent().get_children():
		for n in roomNode.get_children():
			if n.has_signal("all_enemies_killed"):
				n.connect("all_enemies_killed",self,"show_sign")
			elif n.has_signal("player_entered_door"):
				n.connect("player_entered_door",self,"hide_sign")
			elif n.has_signal("camera_adjusted"):
				n.connect("camera_adjusted",self,"hide_sign_2")

func show_sign():
	time=0
	s.visible=true
	set_process(true)
	
func hide_sign():
	s.visible=false
	set_process(false)
	
func hide_sign_2(_discard, _discard2):
	s.visible=false
	set_process(false)
	


var time:float=0
func _process(delta):
	time+=delta
	if time>2:
		time-=2
	s.visible=time>1
