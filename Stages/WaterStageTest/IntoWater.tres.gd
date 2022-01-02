extends Area2D

func _init():
	self.connect("body_exited",self,"setInWater")

func setInWater(obj):
	if obj.get("inWater") != null:
		print("in water!")
		if !obj.inWater:
			obj.get_node("SplashSound").play()
		obj.inWater = true
	else:
		print("error!")
