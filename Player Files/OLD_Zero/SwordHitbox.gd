extends Area2D

func _ready():
	$Timer.connect("timeout",self,"queue_free")
	self.connect("body_entered",self,"enemy_touched");
# If bullet touched an enemy, the enemy hitbox will call this function.
# Why does the enemy need a hitbox? Because collision won't happen unless
# it's on the exact frame...
func enemy_touched(obj):
	print("Touched!")
	#If whatever called this function can get damaged by a bullet, damage it.
	#TODO: This doesn't account for damage types or effectiveness or whatever...
	if obj.get("is_reflecting") == true:
		#print(String(OS.get_ticks_msec())+" Bullet reflected!")
		#reflectSound.play()
		print("Sword Reflected.")
		# TODO: Need to drain reflection health like bullets...?
		pass
	else:
		if obj.has_method("damage"):
			obj.call("damage",1)
		queue_free()
