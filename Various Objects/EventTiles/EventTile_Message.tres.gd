extends StaticBody2D

enum MessageEnums {MESSAGE_BOX=Globals.EVENT_TILES.MESSAGE_BOX,MESSAGE_OPTIONAL,POPUP,NO_POPUP}
export(MessageEnums) var event_ID = Globals.EVENT_TILES.MESSAGE_BOX;
export(bool) var trigger_if_player_is_inactive=false
var disabled:bool = false
export(PoolStringArray) var message
