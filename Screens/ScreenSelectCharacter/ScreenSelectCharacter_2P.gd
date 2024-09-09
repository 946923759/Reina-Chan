extends Control

var canPickM16 = Globals.systemData.unlocked_M16A1
var canPickShinM16 = Globals.systemData.unlocked_M16_Ultimate

#onready var charDesc:Label = $charDesc
onready var arrows = $arrowsAndPlayer
onready var arrows2 = $arrowsAndPlayer2
onready var all_select = [arrows, arrows2]
#func _input(event):

onready var t:Tween = $Tween
func update_disp(play_sound:bool=true):
	pass


func _ready():
	Globals.previous_screen = self.name
	update_disp(false)
	

#Have to use _input() func because doing it in process will cause it
#to think select/enter key is still pressed from previous screen
func _input(event):
	if event.is_pressed() and !event.is_echo():
		for i in range(2):
			if event.is_action("left_p%d" % (i+1)):
				all_select[i].change_selection(1)
			elif event.is_action("right_p%d" % (i+1)):
				all_select[i].change_selection(-1)
		if event.is_action("ui_accept") or event.is_action("ui_pause"):
			action_accept()
		elif event.is_action("ui_cancel"):
			Globals.change_screen(get_tree(),"ScreenTitleMenu")

		
func action_accept():
	set_process_input(false)
	var selection = arrows.selection
	Globals.playerData.currentCharacter=selection
	Globals.playerData.isMultiplayer = true
	var t2:SceneTreeTween = $ScreenTransition.OnCommand(selection)
	yield(t2,"finished")
	Globals.change_screen(get_tree(),"ScreenSelectStage")

func _process(delta):
	pass


func _on_OkButtonTexture_gui_input(event):
	if (event is InputEventMouseButton and event.pressed) or (event is InputEventScreenTouch and event.pressed):
		action_accept()
