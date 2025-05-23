extends Control

#var canPickM16 = Globals.systemData.unlocked_M16A1
var canPickShinM16 = Globals.systemData.unlocked_M16_Ultimate

onready var charDesc:Label = $charDesc
onready var arrows = $arrows

#func _input(event):

onready var t:Tween = $Tween
func update_disp(selection:int):
	
	var curChar:String = Globals.characterToString(selection)
	$charDesc.text=INITrans.GetString("ScreenSelectCharacter",curChar+"_Desc")
	
	loop_description()
	

var textWidth:float=100
#var numTextChars:int=100
func loop_description():
	textWidth=charDesc.get("custom_fonts/font").get_string_size(charDesc.text).x
	#print(textWidth)
	charDesc.rect_position.x=Globals.gameResolution.x+20

func _ready():
	Globals.previous_screen = self.name
	if canPickShinM16:
		arrows.limit = 2
	
	#If web, use native audio since it doesn't crash
	if OS.has_feature("web"):
		var reinaAudioPlayer=ReinaAudioPlayer.new(self)
		reinaAudioPlayer.load_song("CharSelect","Rockman 4MI.nsf",67)
	else:
		$AudioStreamPlayer.play()
	#if INITrans.currentLanguage!="en":
	#	var child = $charDesc
	#	child.set("custom_fonts/font",INITrans.font)
		#child.text=INITrans.GetString("PauseMenu",child.text)
	update_disp(false)
	#$playerSelect.connect("resized",self,"set_rect_size")
	
	$OkButton.visible=OS.has_touchscreen_ui_hint()

#Have to use _input() func because doing it in process will cause it
#to think select/enter key is still pressed from previous screen
func _input(event):
	if event.is_pressed() and !event.is_echo():
		if event.is_action("ui_right"):
			arrows.change_selection(1)
		elif event.is_action("ui_left"):
			arrows.change_selection(-1)
		elif event.is_action("ui_accept") or event.is_action("ui_pause"):
			action_accept()
		elif event.is_action("ui_cancel"):
			Globals.change_screen(get_tree(),"ScreenTitleMenu")

func action_accept():
	set_process_input(false)
	var selection = arrows.selection
	Globals.playerData.currentCharacter=selection
	var t2:SceneTreeTween = $ScreenTransition.OnCommand(selection)
	yield(t2,"finished")
	Globals.change_screen(get_tree(),"ScreenSelectStage")

func _process(delta):

	charDesc.rect_position.x-=delta*250
	if charDesc.rect_position.x < -textWidth:
		charDesc.rect_position.x=Globals.gameResolution.x+20

func set_rect_size():
	#$playerSelect.
	pass


func _on_OkButtonTexture_gui_input(event):
	if (event is InputEventMouseButton and event.pressed) or (event is InputEventScreenTouch and event.pressed):
		action_accept()
