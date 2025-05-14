extends "res://Various Objects/EventTiles/EventTile.gd"

export(Vector2) var zoom_level = Vector2.ONE
export(float,0.0, 5.0, .25) var delay = 1.0

func run_event(player:KinematicBody2D):
	var cc = player.get_node("Camera2D")
	var t:SceneTreeTween = create_tween()
	t.tween_property(cc,"zoom",zoom_level,.5).set_trans(Tween.TRANS_QUAD).set_delay(delay)
	#cc.zoom = Vector2(1.5, 1.5)
