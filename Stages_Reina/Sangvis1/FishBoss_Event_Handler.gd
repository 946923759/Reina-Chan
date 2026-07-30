extends "res://Various Objects/EventTiles/EventTile.gd"

#Disable so the player doesn't die right after they kill the boss and fall anyways
func _on_FishBoss_before_enemy_destroyed():
	collision_layer = 0
	collision_mask = 0
