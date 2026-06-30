extends Node2D

#var translateY:float = 0.0

func _ready():
	set_process(false)

func _process(delta):
	self.position.y-=delta*2
	#self.position.y =
