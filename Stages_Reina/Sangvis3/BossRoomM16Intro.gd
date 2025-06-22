extends "res://Stages/BossRoomNode2D.tres.gd"

#onready var agent = $"WARNING intro/NPC_Agent"
#onready var m16 = $"WARNING intro/BossM16"

func _ready():
	if CheckpointPlayerStats.watchedBossIntro:
		pass
