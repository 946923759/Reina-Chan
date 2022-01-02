extends Area2D

func _init():
	self.connect("body_exited",self,"setInWater")

func setInWater(obj):
	if obj.get("inWater") != null:
		obj.inWater = false
	#else:
	#	print("Error!")
