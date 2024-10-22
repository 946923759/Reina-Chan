extends "res://Stages_Reina/8bitBaseStage.tres.gd"

func _ready():
	#print("fired ready() from override")
	get_player().connect("toggled_debug_disp",self,"toggle_debug_block_disp")
	get_player().get_node("OptionsScreen").connect("paused",$Minimap,"show")
	get_player().get_node("OptionsScreen").connect("unpaused",$Minimap,"hide")
	
	for c in get_tree().get_nodes_in_group("ladderWarp"):
		c.connect("player_teleported",self,"cull_stage_drawing")
		
	#lol lmao
	for c in $ParallaxBackground.get_children():
		c.visible=true
	pass

func playBossMusic(isM16:bool=false):
	if OS.is_debug_build() and mute_boss_music_in_debug:
		return
	print("playing boss music")
	if isM16:
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
	else:
		.playBossMusic(isM16)

#func stopMusic():
#	reinaAudioPlayer.stop_music()
#	#$AudioStreamPlayer2.stop()

func toggle_debug_block_disp(debug_display_visible:int=0):
	#print(debug_display_visible)
	for c in get_tree().get_nodes_in_group("debugWarpDisp"):
		c.visible=(debug_display_visible>0)

onready var sections = [$Architect, $Alchemist, $Ouroboros, $Scarecrow]
var room_sizes = PoolVector2Array([Vector2(7,8),Vector2(8,6),Vector2(7,6),Vector2(9,6)])
func cull_stage_drawing(player_position:Vector2):
	print("player warped to ",player_position)
	
	
	var visibleSection = -1
	for i in sections.size():
		var section = sections[i]
		var room_size = room_sizes[i]*Vector2(1280,720)
		assert(section)
		#print(section.name)
		#assert(section.position)
		if (
				player_position.x < section.position.x+room_size.x 
			) and (
				player_position.y < section.position.y+room_size.y 
			):
			print("assumed player is inside ",section.name)
			visibleSection=i
			break
			
	if visibleSection>=0:
		var visibleName = sections[visibleSection].name
		
		
		#The other layers need to be turned off after the player finishes tweening
		var t = get_tree().create_tween()
		t.set_parallel()
		
		# Disable culling
		# This code doesn't really work properly.
		# it should check for all ladders and not just warp ladders.
		if false:
			for i in sections.size():
				if i == visibleSection:
					sections[i].visible=true
				else:
					t.tween_property(sections[i],"visible",false,0.0).set_delay(1.0)
					pass
		
		for c in $ParallaxBackground.get_children():
			if c.name.begins_with(visibleName):
				c.visible=true
			else:
				t.tween_property(c,"visible",false,0.0).set_delay(1.0)
				pass
	pass
