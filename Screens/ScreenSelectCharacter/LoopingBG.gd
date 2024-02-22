extends Sprite

export(float,0,100,1) var looping_speed = 0.0

var region_size = region_rect.size
func _ready():
	#if looping_speed > 0:
	set_process(looping_speed>0 or Engine.editor_hint)

func _process(delta):
	region_rect.position.x+=delta*looping_speed
	#if region_rect.position.x > region_size.x:
	#	region_rect.position.x-=region_size.x
