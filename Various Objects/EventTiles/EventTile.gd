extends StaticBody2D
signal event_executed_passPlayer(player)
signal event_executed() #Need for compatibility reasons and for functions that don't take an argument

export(Globals.EVENT_TILES) var event_ID = 0;
export(int,-1,999) var event_modifier = -1;
export(bool) var trigger_if_player_is_inactive=false

#Some events like checkpoints or messages can become disabled after use.
var disabled:bool = false
#export(RectangleShape2D) var shapeOverride
#export(Globals.EVENT_TILES) var event_ID
#var event_ID = 555

func signal_event(player:KinematicBody2D):
	emit_signal("event_executed")
	emit_signal("event_executed_passPlayer",player)
