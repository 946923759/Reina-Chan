extends "res://Various Objects/EventTiles/EventTile.gd"

func run_event(player:KinematicBody2D):
	if Globals.playerData.gameDifficulty <= Globals.Difficulty.EASY:
		player.position.y -= 1280
	else:
		player.die()
