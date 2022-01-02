extends "res://Stages/EnemyBaseScript.gd"

func _physics_process(_delta):
	move_and_slide(Vector2(300*facing,0), Vector2(0, -1))
	#var lastCollision = get_slide_collision(0)
	#if lastCollision and lastCollision

	if is_on_wall():
		facing = facing*-1
		sprite.flip_h = (facing == DIRECTION.RIGHT)

func objectTouched(obj):
	print("AAA")
	if obj.has_method("player_touched"): #If enemy touched player
		obj.call("player_touched",self,player_damage)
		#Special case for the bomb enemy, we want the enemy to kill itself when it touches the player
		killSelf()
	elif obj.has_method("enemy_touched"): #If enemy touched bullet
		obj.call("enemy_touched",self)
