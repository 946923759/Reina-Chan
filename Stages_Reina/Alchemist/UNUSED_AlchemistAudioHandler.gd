extends Node

export (String) var custom_music_name
export (String) var nsf_music_file
export (int) var nsf_track_num = 0

export (String) var custom_music_name_pt2
export (String) var nsf_music_file_pt2
export (int) var nsf_track_num_pt2 = 0

export (bool) var mute_music_in_debug=false
export (bool) var mute_boss_music_in_debug=false

onready var parent = get_parent()
# func _ready():
# 	return
# 	if !mute_music_in_debug or !OS.is_debug_build():
# 		parent.reinaAudioPlayer = Globals.ReinaAudioPlayer.new(parent)
# 		if parent.get_node("Player").global_position.y < 84*64:
# 			parent.reinaAudioPlayer.load_song(custom_music_name,nsf_music_file,nsf_track_num)
# 		else:
# 			parent.reinaAudioPlayer.load_song(custom_music_name_pt2,nsf_music_file_pt2,nsf_track_num_pt2)
