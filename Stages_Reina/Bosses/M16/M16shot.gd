extends Node2D

const SPEED=600 #Default is 600

onready var sprite = $AnimatedSprite
onready var vis = $VisibilityNotifier2D
onready var audio = $AudioStreamPlayer2D
func _ready():
	sprite.playing=true
	# warning-ignore:return_value_discarded
	$Area2D.connect("body_entered",self,"objectTouched")

func _physics_process(delta):
	if !vis.is_on_screen():
		queue_free()
		return
	self.position += Vector2(1,0).rotated(self.rotation) * SPEED * delta
	
func objectTouched(obj):
	#print("intersecting!")
	if obj.has_method("player_touched"): #If enemy touched player
		#lastTouched = obj
		if Globals.playerData.gameDifficulty > Globals.Difficulty.EASY:
			obj.call("player_touched",self,3)
		else:
			obj.call("player_touched",self,2)
		#print("hurt player")
	#elif obj.has_method("enemy_touched"): #If enemy touched bullet
	#	obj.call("enemy_touched",self)
