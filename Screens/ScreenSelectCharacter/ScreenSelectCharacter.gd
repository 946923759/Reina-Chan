extends Node2D

var selection:int = 0

var canPickM16 = Globals.systemData.unlocked_M16A1
var canPickShinM16 = Globals.systemData.unlocked_M16_Ultimate

onready var charDesc:Label = $charDesc

#func _input(event):

onready var t:Tween = $Tween
func update_disp(play_sound:bool=true):
	if play_sound:
		$select.play()
	var curChar:String = Globals.characterToString(selection)
	$charName.text=INITrans.GetString("ScreenSelectCharacter",curChar)
	$charDesc.text=INITrans.GetString("ScreenSelectCharacter",curChar+"_Desc")
	
	loop_description()
	
	for c in $Characters.get_children():
		if c.name==curChar:
			c.visible=true
			c.playing=true
		else:
			c.visible=false
			c.playing=false

var textWidth:float=100
#var numTextChars:int=100
func loop_description():
	textWidth=charDesc.get("custom_fonts/font").get_string_size(charDesc.text).x
	#print(textWidth)
	charDesc.rect_position.x=Globals.gameResolution.x+20

func _ready():
	#if INITrans.currentLanguage!="en":
	#	var child = $charDesc
	#	child.set("custom_fonts/font",INITrans.font)
		#child.text=INITrans.GetString("PauseMenu",child.text)
	update_disp(false)

#Have to use _input() func because doing it in process will cause it
#to think select/enter key is still pressed from previous screen
func _input(event):
	if event.is_pressed() and !event.is_echo():
		if event.is_action("ui_right"):
			if selection == 0 and canPickM16:
				selection=1
				update_disp()
			elif selection == 1 and canPickShinM16:
				selection=2
				update_disp()
		elif event.is_action("ui_left"):
			if selection > 0:
				selection-=1
				update_disp()
		elif event.is_action("ui_select") or event.is_action("ui_pause"):
			Globals.playerData.currentCharacter=selection
			Globals.change_screen(get_tree(),"ScreenSelectStage")
		elif event.is_action("ui_cancel"):
			Globals.change_screen(get_tree(),"ScreenTitleMenu")
		

func _process(delta):

	charDesc.rect_position.x-=delta*250
	if charDesc.rect_position.x < -textWidth:
		charDesc.rect_position.x=Globals.gameResolution.x+20
