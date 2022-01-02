extends Sprite

func _ready():
	#self.scale = Vector2(.9,.9)
	var s = get_parent().get_rect().size;
	self.offset = Vector2(s.x/2 - self.texture.get_width()/2,0)
