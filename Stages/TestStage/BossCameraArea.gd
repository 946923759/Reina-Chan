extends Area2D

onready var pos = (self.position - Vector2(640,360)) * -1
func _ready():
	connect("body_entered", self, "setCamera");
	print(String(pos))
	set_process(false)
	pass

func setCamera(blah):
	print(blah.name)
	set_process(true)
	
func _process(delta):
	var curCamPos = get_viewport().get_canvas_transform()[2]
	var movX
	var movY
	if round(curCamPos.x) > round(pos.x):
		movX = -1;
	else:
		movX = 1;
		
	if round(curCamPos.y) > round(pos.y):
		movY = -1;
	else:
		movY = 1;
	#get_viewport().set_canvas_transform(Transform2D(Vector2(1,0),Vector2(0,1),
	#pos
	#));
	get_viewport().set_canvas_transform(get_canvas_transform().translated(Vector2(movX,movY)))
	if round(curCamPos.x) == round(pos.x) and round(curCamPos.y) == round(pos.y):
		set_process(false)
