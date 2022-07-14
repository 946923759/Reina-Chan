extends StaticBody2D
signal event_executed_passPlayer(player)
signal event_executed() #Need for compatibility reasons
#const Events = preload("res://Various Objects/event_tile_names.gd")

export(Globals.EVENT_TILES) var event_ID = 0;
export(int,-1,999) var event_modifier = -1;

#Some events like checkpoints or messages can become disabled after use.
var disabled:bool = false
#export(RectangleShape2D) var shapeOverride
#export(Globals.EVENT_TILES) var event_ID
#var event_ID = 555

#func _ready():
	#if shapeOverride != null:
	#	var shape = shapeOverride
	#	var shapeOwnerID = self.create_shape_owner(self)
	#	self.shape_owner_add_shape(shapeOwnerID, shape)
	#	if OS.is_debug_build():
	#		self.get_node("CollisionShape2D").set_shape(shape)
	#		#https://docs.godotengine.org/en/stable/search.html?q=shape&check_keywords=yes&area=default
func signal_event(player:KinematicBody2D):
	emit_signal("event_executed")
	emit_signal("event_executed_passPlayer",player)
