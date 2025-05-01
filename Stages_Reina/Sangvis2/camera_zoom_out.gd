extends "res://Various Objects/EventTiles/EventTile.gd"

func run_event(player:KinematicBody2D):
	var cc = player.get_node("Camera2D")
	var t:SceneTreeTween = create_tween()
	t.tween_property(cc,"zoom",Vector2(1.5, 1.5),.5).set_trans(Tween.TRANS_QUAD).set_delay(1.0)
	#cc.zoom = Vector2(1.5, 1.5)
