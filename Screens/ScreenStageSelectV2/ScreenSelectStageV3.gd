extends Control

var is_network_game:bool = false
var selection:int = 4
export(int,"4 panel","8 panel") var selection_type = 0

onready var portrait_actor_frame = $PortraitsActorFrame
onready var selSound = $select

var reinaAudioPlayer
func _ready():
	CheckpointPlayerStats.clearEverything()
	
	if Globals.previous_screen.begins_with("Stage"):
		print("[ScreenSelectStage] prev screen was "+Globals.previous_screen+", no anim!")
		$Transition.queue_free()
	else:
		$Transition.visible = true
		$Transition.OffCommand()
	get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_2D,SceneTree.STRETCH_ASPECT_EXPAND,Vector2(1280,720))
	
	reinaAudioPlayer=ReinaAudioPlayer.new(self)
	reinaAudioPlayer.load_song("StageSelect","Mega Man 10 (recreated).nsf",8)

	var bossesDefeated = Globals.bitArrayToInt32(Globals.playerData.availableWeapons)
	if bossesDefeated > 1: #1 is buster so check above 1
		$HubButton.visible=true
	else:
		$HubButton.visible=false
		
	#for i in range(Globals.Weapons.LENGTH_WEAPONS):
	#	var stage_name = Globals.stagesToString[i]
	for i in range(portrait_actor_frame.get_child_count()):
		var p = portrait_actor_frame.get_child(i)
		if "destination_stage" in p:
			var stage_name = p.text
			if stage_name:
				#Case sensitive!!
				var stage_internal_index = Globals.stagesToString.find(stage_name)
				if Globals.playerData.availableWeapons[stage_internal_index]:
					p.show_texture = false
			p.connect("gui_input",self,"mouse_input",[i])
	
	# Show SF sprite if 4 stages beaten
	if Globals.bitArrayToInt32(Globals.playerData.availableWeapons) >= 31:
		portrait_actor_frame.get_child(4).show_texture = true
		selection_type = 1

	#if Globals.playerData.currentCharacter
	$Sprite.use_parent_material = Globals.playerData.currentCharacter == Globals.Characters.UMP9

	setter(selection,false)
	
	set_process(OS.has_feature("pc") or OS.has_feature("web"))
	if is_network_game:
		set_process_input(get_tree().is_network_server())

func _process(_delta):
	var SCREEN_SIZE = self.rect_size
	$Sprite.region_rect.size.x=SCREEN_SIZE.x
	$Sprite.position=SCREEN_SIZE/2


func mouse_input(event,new_sel):
	if (event is InputEventMouseButton and event.pressed) or (event is InputEventScreenTouch and event.pressed):
		if selection==new_sel:
			input_accept()
		else:
			setter(new_sel)
	pass

func fade_to_next_screen(scr_name:String = "ScreenStageIntro", raw_name:bool = false):
	#if raw_name:
	#	scr_name = 
	set_process_input(false)
	var t = get_tree().create_tween()
	t.tween_property($FadeOut,"visible",true, 0.0)
	t.tween_property($FadeOut,"modulate:a",1.0, .25)
	t.tween_callback(reinaAudioPlayer,"stop_music")
	
	Globals.previous_screen = self.name
	if raw_name:
		t.tween_callback(get_tree(),"change_scene",[scr_name])
	else:
		t.tween_callback(Globals,"change_screen",[get_tree(),scr_name])


func _input(event):
	if event is InputEventJoypadMotion:
		return
	elif event is InputEventMouseMotion:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.is_action_pressed("ui_pause") or Input.is_action_pressed("ui_select"):
		input_accept()
	elif Input.is_action_pressed("ui_options") and Globals.bitArrayToInt32(Globals.playerData.availableWeapons)>1:
		input_hub_stage()
	elif Input.is_action_just_pressed("ui_cancel") or (event is InputEventScreenTouch and event.index==1) or (event is InputEventMouseButton and event.button_index == BUTTON_RIGHT):
		fade_to_next_screen("ScreenTitleMenu")
	
	if selection_type == 0:
		if Input.is_action_just_pressed("ui_up"):
			setter(1)
		elif Input.is_action_just_pressed("ui_left"):
			setter(3)
		elif Input.is_action_just_pressed("ui_right"):
			setter(5)
		elif Input.is_action_just_pressed("ui_down"):
			setter(7)
	else:
		if Input.is_action_just_pressed("ui_up"):
			try_set(selection-3)
		elif Input.is_action_just_pressed("ui_left"):
			try_set(selection-1)
		elif Input.is_action_just_pressed("ui_right"):
			try_set(selection+1)
		elif Input.is_action_just_pressed("ui_down"):
			try_set(selection+3)

#Only master can call this func
puppetsync func input_accept():
	var stg = portrait_actor_frame.get_child(selection).destination_stage
	if selection==4: #SANGVIS_FERRI
		#This is checking if 5 bits are set, bit 1 is buster so it's always set
		if Globals.bitArrayToInt32(Globals.playerData.availableWeapons) >= 31:
			fade_to_next_screen("ScreenSangvisIntro")
			#Globals.nextStage=whatever[selection][2]
			#fade_to_next_screen(Globals.nextStage,true)
			#get_tree().change_scene()
		return
	elif stg != "":
		Globals.nextStage = stg
		
		#I don't like this, I wish it was played across screens
		$Confirm.play()
		fade_to_next_screen()
	else:
		$No.play()

func input_hub_stage():
	if is_network_game and get_tree().is_network_server():
		rpc("enter_hub_stage")
	else:
		enter_hub_stage()

puppetsync func enter_hub_stage():
	fade_to_next_screen("res://Stages_Reina/StageTalkHub.tscn",true)
	#get_tree().change_scene("res://Stages_Reina/StageTalkHub.tscn")

func try_set(new_selection:int):
	if new_selection < 0 or new_selection > portrait_actor_frame.get_child_count()-1:
		return
	if !("portrait_texture" in portrait_actor_frame.get_child(new_selection)):
		return
	setter(new_selection)

puppetsync func setter(newSelection, playSound=true):
	portrait_actor_frame.get_child(selection).LoseFocus()
	portrait_actor_frame.get_child(newSelection).GainFocus()
	selection=newSelection
	if playSound:
		selSound.play()
	pass


func _on_HubButton_gui_input(event):
	if (event is InputEventMouseButton == false and event is InputEventScreenTouch == false):
		return
	if !event.pressed:
		return
	input_hub_stage()
