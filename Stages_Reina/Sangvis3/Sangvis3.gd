extends "res://Stages_Reina/8bitBaseStage.tres.gd"

func _ready():
	#print("fired ready() from override")
	get_player().connect("toggled_debug_disp",self,"toggle_debug_block_disp")
	pass

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

#func stopMusic():
#	reinaAudioPlayer.stop_music()
#	#$AudioStreamPlayer2.stop()

func toggle_debug_block_disp(m:int=0):
	for c in get_tree().get_nodes_in_group("debugWarpDisp"):
		c.visible=(m>0)
