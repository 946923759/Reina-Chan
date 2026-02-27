extends Node2D
#extends "res://Various Objects/EventTile_Message.tres.gd"

onready var sprite = $CanvasLayer/Sprite
var gf_cutscene = preload("res://Screens/ScreenCutsceneMMZ/CutsceneInGame.tscn")
#var gf_cutscene = preload("res://Screens/ScreenCutscene/CutsceneMain.tscn")


var event_ID = Globals.EVENT_TILES.CUSTOM_EVENT
export(String) var message_id
export(PoolStringArray) var message
#export(bool) var play_M16_boss_music=false
var disabled = false

var playerObj
var child:KinematicBody2D

func _ready():
	sprite.set_process(false)
	if message_id.empty():
		message_id="default"
	elif message_id == "___NONE___":
		message_id = ""
	child=get_child(get_child_count()-1)
	assert(child is KinematicBody2D,"You didn't place the boss as the last child of the warning node, please rearrange it in the list.")
	#run_event(self)
	#.connect("finished",self,"end_cutscene")
	#seq.parallel().append(self,'modulate:a',0,.3)
	pass

func run_event(sender):
	if disabled:
		return
	if !sender.has_method("lockMovement"):
		return
	disabled=true
	playerObj=sender
	#Due to funny collision problems we have to push the player down or she'll be in the air for 1 frame after unlocking
	#playerObj.lockMovement(999,Vector2(0,5),"Talking",true) 
	playerObj.lockMovementQueue([
		[999,Vector2(0,5),"Talking",true]
	])
	#playerObj.sprite.set_animation("Talking")
	if Globals.playCutscenes==false or CheckpointPlayerStats.watchedBossIntro or message_id.empty():
		child.playIntro(false)
		showWarning(false)
	else:
		part1()
		#part2()
	
func showWarning(playLonger=true):
	sprite.set_process(true)
	#playerObj.lockMovement(3,Vector2(0,0))
	var CONST_IMG_WIDTH = sprite.CONST_IMG_WIDTH
	var seq := get_tree().create_tween()
	seq.tween_property(sprite,"toDraw",CONST_IMG_WIDTH,2.0 if playLonger else .5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
# warning-ignore:return_value_discarded
	seq.tween_callback(self,"playSound")
# warning-ignore:return_value_discarded
	seq.tween_property(sprite,"modulate:r", .8, .25)
# warning-ignore:return_value_discarded
	seq.tween_property(sprite,"modulate:r", 1,  .25)
# warning-ignore:return_value_discarded
	seq.tween_property(sprite,"modulate:r", .8, .25)
# warning-ignore:return_value_discarded
	seq.tween_property(sprite,"modulate:r", 1,  .25)
# warning-ignore:return_value_discarded
	#seq.tween_callback(self,"part2")
	seq.tween_callback(self,"hideWarning")
	

func playSound():
	$AudioStreamPlayer.play()

func hideWarning():
	get_node("/root/Node2D").playBossMusic()
	sprite.cropright=true
	var seq := create_tween()
	seq.tween_property(sprite,"toDraw",0,.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
# warning-ignore:return_value_discarded
	#seq.connect("finished",playerObj,"clearLockedMovement")
	seq.tween_callback(self,"part5")
	#seq.connect("finished",self,"part5")
	#$AudioStreamPlayer.connect("finished",self,"part3")
	
func part5():
	CheckpointPlayerStats.watchedBossIntro=true
	child.enabled=true
	playerObj.set_physics_process(true)
	playerObj.clearLockedMovement()
	sprite.set_process(false)
	sprite.visible=false

func part1():
	#I'm pretty sure this only exists so people don't pause during the cutscene
	#get_tree().paused=true
	playerObj.set_physics_process(false)
	var newCutscene = gf_cutscene.instance()
	playerObj.add_child(newCutscene) #Needs to be done first for the _ready()
	newCutscene.connect("cutscene_finished",self,"part2")
	
	print("Playing boss cutscene!")
	#Old cutscene format
#	newCutscene.init_(
#		Globals.get_stage_cutscene(message_id),
#		playerObj,
#		true,
#		null, #Backgrounds
#		"\t",
#		Globals.stage_cutscene_data['msgColumn']
#	)

	#New cutscene format
	#func init_(message_:PoolStringArray,delim="|",msgColumn_:int=1):
	newCutscene.init_(
		Globals.get_stage_cutscene(message_id),
		"\t",
		Globals.stage_cutscene_data['msgColumn'],
		self
	)

func part2():
	var callback = child.playIntro();
	if callback.stream == null:
		printerr("[BossBase.IntroSound] There's no audio file assigned for this boss, idiot. Change IntroSound actor in the boss class.")
		showWarning()
		return
	callback.connect("finished",self,"showWarning")

var time:float = 0.0
