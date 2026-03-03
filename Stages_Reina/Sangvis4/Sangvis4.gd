extends "res://Stages_Reina/8bitBaseStage.tres.gd"

func playBossMusic(isM16:bool=false):
	if OS.is_debug_build() and mute_boss_music_in_debug:
		return
	print("playing boss music")
	#reinaAudioPlayer.load_song("FinalBoss","Rockman 4MI.nsf",69)
	reinaAudioPlayer.load_song("FinalBoss1","MMBN5 vs Nebula Grey.nsf",0)

func easytiles(show:bool = true):
	var easyTiles:TileMap = $EasyTiles
	if show:
		for i in range(8):
			easyTiles.set_collision_mask_bit(i,false)
			easyTiles.set_collision_layer_bit(i,false)
		easyTiles.visible=false
	else:
		easyTiles.set_collision_layer_bit(4,true)
		easyTiles.set_collision_layer_bit(5,true)
		easyTiles.set_collision_mask_bit(0,true)
		easyTiles.visible=true
