extends "res://Stages/EnemyBaseScript.gd"

enum STATES {
	RUNNING = 0,
	SHOOTING,
	RUNNING_AGAIN
}
var curState = 0
var cooldown:float = 0.0

#var last_player =

onready var area := $areaCheckPlayer
onready var vines = [
	$VinesThing,
	$VinesThing2,
	$VinesThing3
]

func _physics_process(delta):
	if cooldown > 0:
		cooldown -= delta
		return

	var bodies = area.get_overlapping_bodies()
	if bodies.size() > 0:
		var tw = create_tween()
		$AudioStreamPlayer2D.position.x = abs($AudioStreamPlayer2D.position.x)*facing
		for i in range(len(vines)):
			vines[i].position.x = abs(vines[i].position.x)*facing
			tw.tween_callback(vines[i],"set_process",[true]).set_delay(.1*i)
		tw.tween_callback($AudioStreamPlayer2D,"play").set_delay(15.0/60.0)
		#tw.tween_callback($VinesThing2,"set_process",[true]).set_delay(.1)
		#tw.tween_callback($VinesThing3,"set_process",[true]).set_delay(.1)
		#$VinesThing.set_process(true)
		#$VinesThing2.set_process(true)
		#$VinesThing3.set_process(true)
		cooldown = 2.4
		sprite.play("default_green")
	else:
		sprite.play("moving_green")
		move_and_slide(Vector2(200*facing,200), Vector2(0, -1))
		if is_on_wall():
			facing = facing*-1
			sprite.flip_h = (facing == DIRECTION.RIGHT)
			area.position.x = abs(area.position.x)*facing
			
		#if global_position.x > player.get_node("Camera2D").limit_right+50:
		#	print("Dinergate walked offscreen, despawning.")
		#	queue_free()
		
	#sprite.play("default_green")
	

func _on_Area2D2_body_entered(body):
	if cooldown > 0:
		return
	#pass # Replace with function body.
#	var tw = create_tween()
#	tw.tween_callback($VinesThing,"set_process",[true])
#	tw.tween_callback($VinesThing2,"set_process",[true]).set_delay(.1)
#	tw.tween_callback($VinesThing3,"set_process",[true]).set_delay(.1)
#	#$VinesThing.set_process(true)
#	#$VinesThing2.set_process(true)
#	#$VinesThing3.set_process(true)
#	cooldown = .5
#	sprite.play("default_green")
