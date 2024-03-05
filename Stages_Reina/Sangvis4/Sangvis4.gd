extends "res://Stages_Reina/8bitBaseStage.tres.gd"

func playBossMusic(isM16:bool=false):
	if OS.is_debug_build() and mute_boss_music_in_debug:
		return
	print("playing boss music")
	reinaAudioPlayer.load_song("FinalBoss","Rockman 4MI.nsf",69)
