extends Node2D
var event_ID = Globals.EVENT_TILES.CHECKPOINT
var disabled = false
#Because "Spawn Fail and Clear" is too confusing
export(bool) var spawn_eddie = false
export(Vector2) var respawn_position = Vector2(0,0)
export(bool) var respawn_facing_left=false

#There is no reason to make this true ever
var trigger_if_player_is_inactive=false
