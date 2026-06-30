extends Control

onready var music_player = ReinaAudioPlayer.new(self)

func _ready():
	#get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_2D,SceneTree.STRETCH_ASPECT_EXPAND,Vector2(1280,720))
	#music_player.load_song("Credits","sonic3k.nsf",35,6)
	
	var emblems = Globals.bitArrayToInt32(Globals.playerData.ReinaChanEmblems)
	# 0x1F = first 5 bits. If all 5 bits in "emblems" are set then
	# the returned value after the operation will be the same.
	if (emblems & 0x1F) == 0x1F:
		Globals.systemData['unlocked_M16A1'] = true
		Globals.save_system_data()
		$DialoguePlayerInGame.init_by_msg_id("Ending")
	else:
		$DialoguePlayerInGame.init_by_msg_id("Ending_Bad")


func _on_DialoguePlayerInGame_cutscene_finished():
	Globals.change_screen(get_tree(),"ScreenOpening")
