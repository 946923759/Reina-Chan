extends TabContainer
signal selected_new_object(type, obj)

export (Array, Resource) var pickups

func _ready():
	var pickupActorFrame = $Pickups
	for pickup in pickups:
		var vBox = VBoxContainer.new()
		var tex:TextureRect = TextureRect.new()
		tex.rect_min_size=Vector2(32,32)
		tex.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		var btn = Button.new()
		btn.toggle_mode=true
		
		var inst = pickup.instance()
		var sprite = inst.get_node_or_null("Sprite")
		if sprite:
			tex.texture = sprite.texture
		else:
			sprite = inst.get_node_or_null("AnimatedSprite")
			if sprite:
				tex.texture = sprite.frames.get_frame(sprite.get_animation(), sprite.frame)
		#print(pickup._bundled)
		btn.text = inst.name
		vBox.add_child(tex)
		vBox.add_child(btn)
		pickupActorFrame.add_child(vBox)
		vBox.connect("gui_input",self,"handle_gui_input",[vBox])

