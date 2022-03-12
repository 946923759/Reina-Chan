extends Node2D

var loader
var wait_frames:int
var time_max:float = 1 # msec
var current_scene
onready var audio = $AudioStreamPlayer
var stageToLoad:String

func _ready():
	
	var music = Globals.get_custom_music("StageIntro")
	if music != null:
		print("Attempting to load "+music)
		if music.ends_with(".import"):
			audio.stream = load(music.replace('.import', ''))
		else:
			audio.stream = ExternalAudio.loadfile(music,false)
	audio.play()
	audio.connect("finished",self, "done")
	
	#load
	if Globals.nextStage == null:
		stageToLoad="res://Stages_Reina/TestStage.tscn"
	else:
		stageToLoad=Globals.nextStage
	
	
	"""var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() -1)
	loader = ResourceLoader.load_interactive(stageToLoad)
	if loader == null: # Check for errors.
		show_error()
		return
	"""
	$ColorRect.rect_size=Globals.gameResolution
	$ColorRect2.rect_size.x=Globals.gameResolution.x
	set_process(false)

func done():
	get_tree().change_scene(stageToLoad)

#Async loader
func _process(time):
	if loader == null:
		# no need to process anymore
		set_process(false)
		return

	# Wait for frames to let the "loading" animation show up.
	#if wait_frames > 0:
	#	wait_frames -= 1
	#	return

	#var t = OS.get_ticks_msec()
	# Use "time_max" to control for how long we block this thread.
	#while OS.get_ticks_msec() < t + time_max:
		# Poll your loader.
	
	var err = loader.poll()

	if err == ERR_FILE_EOF: # Finished loading.
		if !audio.playing:
			var resource = loader.get_resource()
			loader = null
			#set_new_scene(resource)
			current_scene.queue_free()
			current_scene = resource.instance()
			get_tree().get_root().add_child(current_scene)
			#break
	elif err == OK:
		#update_progress()
		pass
	else: # Error during loading.
		#show_error()
		loader = null
		#break

func _input(event):
	if event.is_action_pressed("ui_pause"):
		$AudioStreamPlayer.stop()
		#Will automatically call done() since it's connected
