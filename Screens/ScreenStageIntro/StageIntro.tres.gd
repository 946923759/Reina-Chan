extends Control

var loader
var wait_frames:int
var time_max:float = 1 # msec
var current_scene
onready var audio = $AudioStreamPlayer
var stageToLoad:String

var isStandAlone:bool=true

func _ready():
	Globals.previous_screen = "Stage"
	
	VisualServer.canvas_item_set_z_index($FadeIn.get_canvas_item(),9)
	VisualServer.canvas_item_set_z_index($TransitionOut.get_canvas_item(),10)
	
	#$Sprite.modulate.a = 0.0
	$FadeIn.visible = true
	#$BossBG.rect_scale.y = 0.0
	#$BossSpriteLoader.visible = false
	
	var t = create_tween()
	#t.tween_property($FadeIn,"visible",true,0.0)
	t.tween_property($FadeIn,"modulate:a",0.0,.5).set_delay(.1)
	#t.parallel().tween_property($Sprite,"modulate:a",1.0,.25).set_delay(.1)
	#t.tween_property($BossBG,"rect_scale:y",1.0,.25)
	t.tween_property($BossSpriteLoader,"visible",true,0.0)
	t.tween_callback($BossSpriteLoader,"OnCommand")
	
	var music = Globals.get_custom_music("StageIntro")
	if music != null:
		print("Attempting to load "+music)
		if music.ends_with(".import"):
			audio.stream = load(music.replace('.import', ''))
		else:
			audio.stream = ExternalAudio.loadfile(music,false)
	audio.play()
	audio.connect("finished", self, "done")
	
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
	#$ColorRect.rect_size=Globals.gameResolution
	#$ColorRect2.rect_size.x=Globals.gameResolution.x
	#VisualServer.canvas_item_set_z_index($ColorRect.get_canvas_item(),-999)
	#VisualServer.canvas_item_set_z_index($ColorRect2.get_canvas_item(),-1)
	
	set_process(true)

func done():
	var t:SceneTreeTween = $TransitionOut.OnCommand()
	t.tween_callback(get_tree(),"change_scene",[stageToLoad])
	#get_tree().change_scene(stageToLoad)

func _input(event):
	if (
		event.is_action_pressed("ui_pause") or
		(event is InputEventMouseButton and event.pressed) or 
		(event is InputEventScreenTouch and event.pressed)
	):
		set_process_input(false)
		audio.disconnect("finished",self,"done")
		done()
		#$AudioStreamPlayer.stop()
		#Will automatically call done() since it's connected

func _process(delta):
	if Input.is_key_pressed(KEY_QUOTELEFT):
		Engine.time_scale = .25
	else:
		Engine.time_scale = 1.0
