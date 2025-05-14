extends "res://Various Objects/EventTiles/EventTile.gd"

var explode = preload("res://Stages/EnemyExplodeSmall.tscn")

func _on_MinibossPlatforms_all_enemies_killed():
	var tiles = $Spikes.region_rect.size.x/16
	$Spikes.visible = false
	collision_layer = 0
	collision_mask = 0
	disabled = true
	for i in range(tiles):
		var inst = explode.instance()
		inst.position.x = (i-tiles/2)*16 #self obj is centered so we need to not center
		inst.scale = Vector2.ONE
		inst.get_node("s1").volume_db = -80
		add_child(inst)
	$s2.play()
