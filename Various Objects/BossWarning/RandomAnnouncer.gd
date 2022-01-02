extends AudioStreamPlayer

func list_files_in_directory(path):
	var files = []
	var dir = Directory.new()
	if dir.open(path) != OK:
		printerr("Failed to get files in directory "+path)
		return files
	dir.list_dir_begin()

	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif !file.begins_with(".") and !file.ends_with(".import"):
			files.append(file)
	return files

func _ready():
	if Globals.OPTIONS['SFA3Announcer']['value']==true:
		#Doesn't work when exported for some really stupid reason
		#var files = ["res://Sounds/Announcer/Mission Start/"]
		#var files = list_files_in_directory("res://Sounds/Announcer/Mission Start/")
		var files = ["Face it Striaght.wav", 
			"Go For Broke.wav", 
			"GoForItMan.wav", 
			"ItAllDependsOnYourSkill.wav", 
			"ItsShowtime.wav", 
			"LetsParty.wav"]
		if files.size()==0:
			printerr("res://Sounds/Announcer/Mission Start/ is empty!!!! FIX YOUR GAME!!!!")
			return
		#print(files)
		randomize() #inits randi()
		var sound = randi()%files.size()
		print(files[sound])
		var audio = load("res://Sounds/Announcer/Mission Start/"+files[sound])
		stream = audio;
