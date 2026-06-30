extends RigidBody2D

func reflect():
	collision_layer = 0
	collision_mask = 0
	linear_velocity = Vector2(linear_velocity.x*-1, -400)
	$ReflectSound.play()
