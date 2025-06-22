extends KinematicBody2D

const DAMAGE = 2
var fireball = preload("res://Stages_Reina/Enemies/Skorp/HurtFire.tscn")

func _physics_process(delta):
	var collision = move_and_collide(Vector2(0,10))
	if collision:
		var inst = fireball.instance()
		inst.position = position
		get_parent().add_child(inst)
		queue_free()

func _on_Area2D_area_entered(area):
	pass # Replace with function body.


func _on_Area2D_body_entered(obj):
	#print("intersecting!")
	if obj.has_method("player_touched"): #If enemy touched player
		#lastTouched = obj
		obj.call("player_touched",self,DAMAGE)
