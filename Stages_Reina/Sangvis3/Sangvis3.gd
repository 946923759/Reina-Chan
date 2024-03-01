extends "res://Stages_Reina/8bitBaseStage.tres.gd"

func playBossMusic(isM16:bool=false):
	if OS.is_debug_build() and mute_boss_music_in_debug:
		return
	print("playing boss music")
	
	if $PlayerHolder.currentCharacter==Globals.Characters.UMP9:
		reinaAudioPlayer.load_song("Elisa3 - UMP9 vs M16","Mega Man Unlimited - Division by Zero.nsf",0)
		#if 
		#$AudioStreamPlayer2.play()
#		if OS.has_feature("standalone"):
#			
#		else:
#			reinaAudioPlayer.load_song("Elisa3 - UMP9 vs M16","X vs Zero.nsf",0)
	else:
		reinaAudioPlayer.load_song("Elisa3 - M16 vs M16","Cannonball.nsf",0)

func stopMusic():
	reinaAudioPlayer.stop_music()
	#$AudioStreamPlayer2.stop()
