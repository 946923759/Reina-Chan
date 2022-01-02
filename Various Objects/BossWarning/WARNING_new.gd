extends Node2D
#extends "res://Various Objects/EventTile_Message.tres.gd"

onready var sprite = $CanvasLayer/Sprite
var gf_cutscene = preload("res://Cutscene/CutsceneMain.tscn")

var event_ID = Globals.EVENT_TILES.CUSTOM_EVENT
export(PoolStringArray) var message
var disabled = false

var parent
var child

func _ready():
	child=get_child(get_child_count()-1)
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
	parent=sender
	parent.lockMovement(999,Vector2())
	parent.sprite.set_animation("Idle")
	if Globals.playCutscenes==false or CheckpointPlayerStats.watchedBossIntro:
		child.playIntro(false)
		showWarning(false)
	else:
		part1()
	
func showWarning(playLonger=true):
	#parent.lockMovement(3,Vector2(0,0))
	var CONST_IMG_WIDTH = sprite.CONST_IMG_WIDTH
	var seq := TweenSequence.new(get_tree())
	seq.append(sprite,"toDraw",CONST_IMG_WIDTH,2.0 if playLonger else .5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
# warning-ignore:return_value_discarded
	seq.append_callback(self,"playSound")
# warning-ignore:return_value_discarded
	seq.append(sprite,"modulate:r", .8, .25)
# warning-ignore:return_value_discarded
	seq.append(sprite,"modulate:r", 1,  .25)
# warning-ignore:return_value_discarded
	seq.append(sprite,"modulate:r", .8, .25)
# warning-ignore:return_value_discarded
	seq.append(sprite,"modulate:r", 1,  .25)
# warning-ignore:return_value_discarded
	#seq.append_callback(self,"part2")
	seq.append_callback(self,"hideWarning")
	

func playSound():
	$AudioStreamPlayer.play()

func hideWarning():
	get_node("/root/Node2D").playBossMusic()
	sprite.cropright=true
	var seq := TweenSequence.new(get_tree())
	seq.append(sprite,"toDraw",0,.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
# warning-ignore:return_value_discarded
	#seq.connect("finished",parent,"clearLockedMovement")
	seq.append_callback(self,"part5")
	#seq.connect("finished",self,"part5")
	#$AudioStreamPlayer.connect("finished",self,"part3")
	
func part5():
	CheckpointPlayerStats.watchedBossIntro=true
	child.enabled=true
	parent.clearLockedMovement()

func part1():
	#if !msgEv.finished:
	#parent.lockMovement(.1,Vector2())
	get_tree().paused=true
	var newCutscene = gf_cutscene.instance()
	parent.add_child(newCutscene) #Needs to be done first for the _ready()
	newCutscene.connect("cutscene_finished",self,"part2")
	newCutscene.init_(
		message,
		parent,
		true
	)

func part2():
	var callback = child.playIntro();
	callback.connect("finished",self,"showWarning")
	#var t = Timer.new()
	#t.set_wait_time(.3)
	#t.set_one_shot(true)
	#add_child(t)
	#t.connect("timeout",self,"showWarning")
	#t.start()
	#yield(t,"timeout")
	#showWarning()

var time:float = 0.0
