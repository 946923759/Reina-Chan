extends Control

onready var player = $CutscenePlayer
onready var vbox = $PanelContainer/GridContainer/ItemList

var scenes

func _ready():
	Globals.load_stage_cutscenes("stage_cutscenes")
	scenes = Globals.stage_cutscene_data.keys()
	for k in scenes:
		vbox.add_item(k)
	
	#init_(message_:PoolStringArray, parent,delim="|",msgColumn_:int=1):
	$CutscenePlayer.init_(Globals.stage_cutscene_data['default'], "\t")


func _on_RunDialogScript_pressed():
	$PanelContainer/GridContainer/RunDialogScript.release_focus()
	var items = $PanelContainer/GridContainer/ItemList.get_selected_items()
	var selectionIndex = items[0]
	var selectionName = scenes[selectionIndex]
	#print(items)
	$CutscenePlayer.init_(Globals.stage_cutscene_data[selectionName], "\t")
	pass # Replace with function body.
