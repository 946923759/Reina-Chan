extends Area2D
signal event_executed()
signal event_executed_passPlayer(player)

#Normally I'd just use an event tile but there's no way to
#check if the player exited the event tile and I want that
#button animation

onready var sprite = $Sprite
onready var sound = $AudioStreamPlayer2D
var lastTouched:KinematicBody2D

func _ready():
	# warning-ignore:return_value_discarded
	self.connect("body_entered",self,"_on_body_entered")
# warning-ignore:return_value_discarded
	self.connect("body_exited",self,"_on_body_exited")
	
func _on_body_entered(obj):
	if obj.has_method("player_touched"): #If enemy touched player
		sprite.frame=1
		sound.play()
		lastTouched = obj
		emit_signal("event_executed")
		emit_signal("event_executed_passPlayer",obj)

func _on_body_exited(body):
	lastTouched=null
	sprite.frame=0
