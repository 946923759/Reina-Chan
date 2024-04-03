extends Sprite

var cur_texture:Texture
var lastLoaded: String

func set_texture_wrapper(sprName):
	lastLoaded=sprName
	#set_texture(load("res://Cutscene/Portraits/"+sprName+".png"))
	var f = File.new()
	if OS.has_feature("standalone") and !f.file_exists("res://Screens/ScreenCutsceneMMZ/Mugshots/"+sprName+".png.import"):
		var path = OS.get_executable_path().get_base_dir()+"/GameData/Cutscene/Mugshots/"+sprName+".png"
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

			var texture_ = ImageTexture.new()
			texture_.create_from_image(image);
			cur_texture = texture_
		else:
			printerr("Mugshot not embedded in pck and no external file!!")
			return
	else:
		cur_texture=load("res://Screens/ScreenCutsceneMMZ/Mugshots/"+sprName+".png")
	set_texture(cur_texture)
