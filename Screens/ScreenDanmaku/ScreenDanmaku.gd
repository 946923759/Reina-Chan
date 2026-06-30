extends Node2D

export (String) var custom_music_name
export (String) var nsf_music_file
export (int) var nsf_track_num = 0
export (float,-8.0,8.0,.1) var nsf_volume_adjustment = 0.0
export (bool) var mute_music_in_debug=false
export (bool) var mute_boss_music_in_debug=false

var reinaAudioPlayer

func _ready():
	reinaAudioPlayer = ReinaAudioPlayer.new(self)
	playMusic()
#	update()
	
#This is the same thing as the first function but it pulls values from the exported vars instead of taking any arguments
func playMusic():
	if OS.is_debug_build() and mute_music_in_debug:
		return
	reinaAudioPlayer.load_song("FinalBoss","Rockman 4MI.nsf",69)

func get_player():
	return $GameplayLayer/Player
