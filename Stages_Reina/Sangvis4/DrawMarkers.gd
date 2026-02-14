tool
extends Node2D

export(Texture) var markerTexture
export(PoolVector2Array) var markersToDraw setget update_draw
export(int,0,16) var draw_range= 16 setget set_draw_range
onready var texture_size:Vector2 = markerTexture.get_size()


func update_draw(v):
	markersToDraw = v
	update()
	
func set_draw_range(v):
	draw_range = v
	update()
	
func _draw():
	for i in range(min(markersToDraw.size(), draw_range)):
		var real_pos = (Vector2(markersToDraw[i])-texture_size/2*scale)/scale
		#real_pos-=
		draw_texture(markerTexture, real_pos)

#func _process(delta):
#	update()
