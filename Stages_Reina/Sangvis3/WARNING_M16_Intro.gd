extends "res://Various Objects/BossWarning/WARNING_new.gd"

onready var agent:KinematicBody2D= $BossAgent
onready var m16:KinematicBody2D = $BossM16

func _ready():
	if CheckpointPlayerStats.watchedBossIntro:
		$BlockEnablerDisabler.execute()
		agent.collision_mask = 0
		m16.position.x = 736
		agent.queue_free()
		$FakeM16.queue_free()

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
