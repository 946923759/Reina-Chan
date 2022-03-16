class_name smSprite
extends TextureRect

func Center():
	print("smSprite.Center() has been removed")
	return
	#position=Globals.SCREEN_CENTER

func Cover():
	#if expand:
	#	print("Do not call Cover() more than once!!!")
	#	return
	rect_size=Globals.gameResolution
	#size_flags_horizontal=1
	stretch_mode=STRETCH_KEEP_ASPECT_COVERED
	expand=true
	
func set_rect_size():
	#print("r")
	rect_size=get_viewport().get_visible_rect().size

func loadFromExternal(path:String):
	var file = File.new()
	var image = Image.new()
	file.open(path, File.READ)
	var buffer = file.get_buffer(file.get_len())

	match path.get_extension():
		"png":
			image.load_png_from_buffer(buffer)
		"jpg":
			image.load_jpg_from_buffer(buffer)
		"webp":
			image.load_webp_from_buffer(buffer)

	file.close()
	image.lock()
	var newTexture = ImageTexture.new()
	newTexture.create_from_image(image)
	texture=newTexture
	
func loadVNBG(sprName:String):
	#loadFromExternal(OS.get_executable_path().get_base_dir()+"/GameData/Cutscene/Backgrounds/"+sprName)
	var f = File.new()
	if OS.has_feature("standalone") and !f.file_exists("res://Cutscene/Backgrounds/"+sprName+".png.import"):
		
		#var found = false
		for ext in [".png",".jpg"]:
			var path = OS.get_executable_path().get_base_dir()+"/GameData/Cutscene/Backgrounds/"+sprName+ext
			#print("Checking path "+path)
			if f.file_exists(path):
				print("Found external image file at "+path)
				var image = Image.new()
				f.open(path, File.READ)
				var buffer = f.get_buffer(f.get_len())
				match path.get_extension():
					"png":
						image.load_png_from_buffer(buffer)
					"jpg":
						image.load_jpg_from_buffer(buffer)

				f.close()
				image.lock()
				var newTexture = ImageTexture.new()
				newTexture.create_from_image(image)
				texture=newTexture
				return true
			#else:
		printerr("background not embedded in pck and no external file found!!")
		return false
	else:
		texture=load("res://Cutscene/Backgrounds/"+sprName+".png")
		return true
	
func loadVNPortrait(sprName:String):
	var f = File.new()
	if OS.has_feature("standalone") and !f.file_exists("res://Cutscene/Portraits/"+sprName+".png.import"):
		var path = OS.get_executable_path().get_base_dir()+"/GameData/Cutscene/Portraits/"+sprName+".png"
		#print("Checking path "+path)
		if f.file_exists(path):
			print("Found external image file at "+path)
			var image = Image.new()
			f.open(path, File.READ)
			var buffer = f.get_buffer(f.get_len())
			match path.get_extension():
				"png":
					image.load_png_from_buffer(buffer)
				"jpg":
					image.load_jpg_from_buffer(buffer)

			f.close()
			image.lock()
			var newTexture = ImageTexture.new()
			newTexture.create_from_image(image)
			texture=newTexture
		else:
			printerr("Portrait not embedded in pck and no external file!!")
	else:
		texture=load("res://Cutscene/Portraits/"+sprName+".png")

func hideActor(s:float):
	var seq := TweenSequence.new(get_tree())
	seq._tween.pause_mode = Node.PAUSE_MODE_PROCESS
# warning-ignore:return_value_discarded
	seq.append(self,'modulate:a',0,s)

func showActor(s:float):
	var seq := TweenSequence.new(get_tree())
	seq._tween.pause_mode = Node.PAUSE_MODE_PROCESS
# warning-ignore:return_value_discarded
	seq.append(self,'modulate:a',1,s)
