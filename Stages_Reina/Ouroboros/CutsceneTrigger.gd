extends Node
signal cutscene_finished

var gf_cutscene = preload("res://Screens/ScreenCutscene/CutsceneMain.tscn")
var disabled:bool=false
export(String) var message_id

func play_cutscene():
	if Globals.playCutscenes:
		var parent = get_parent()
		get_tree().paused=true
		var newCutscene = gf_cutscene.instance()
		parent.add_child(newCutscene) #Needs to be done first for the _ready()
		#newCutscene.connect("cutscene_finished",self,"part2")
		newCutscene.init_(
			Globals.get_stage_cutscene(message_id),
			parent,
			true,
			null,
			"\t"
		)
	disabled=true
	emit_signal("cutscene_finished")
	$AudioStreamPlayer.play()
	
	Globals.playerData.specialAbilities[Globals.SpecialAbilities.Grenade]=true
