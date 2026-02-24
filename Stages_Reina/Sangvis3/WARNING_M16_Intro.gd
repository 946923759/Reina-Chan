extends "res://Various Objects/BossWarning/WARNING_new.gd"

onready var agent:KinematicBody2D= $BossAgent
onready var m16:KinematicBody2D = $BossM16

func _ready():
	if Globals.playCutscenes==false or CheckpointPlayerStats.temporaryStageStats & 1<<7:
		remove_agent_placeholder_if_necessary()
		
func remove_agent_placeholder_if_necessary():
	if is_instance_valid(agent):
		$BlockEnablerDisabler.execute()
		agent.collision_mask = 0
		m16.position.x = 736
		agent.queue_free()
		$FakeM16.queue_free()

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
	if Globals.playCutscenes==false or CheckpointPlayerStats.temporaryStageStats & 1<<7:
		remove_agent_placeholder_if_necessary()
		child.playIntro(false)
		showWarning(false)
	else:
		part1()

func part2():
	$BlockEnablerDisabler.execute()
	if $FakeM16.position.x < 860:
		m16.position = $FakeM16.position
	else:
		m16.position.x = 736
		if is_instance_valid(agent):
			agent.queue_free()
	$FakeM16.queue_free()
	.part2()

func hideWarning():
	get_node("/root/Node2D").playM16BossMusic()
	sprite.cropright=true
	var seq := create_tween()
	seq.tween_property(sprite,"toDraw",0,.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	seq.tween_callback(self,"part5")

func part5():
	#Set bit 7 to true because other bosses already set watchedBossIntro true
	CheckpointPlayerStats.temporaryStageStats |= (1<<7)
	.part5()
