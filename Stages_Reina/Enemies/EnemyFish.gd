extends "res://Stages/EnemyBaseScript.gd"

enum STATE {
	WAIT,
	CHASE,
}
var curState = STATE.WAIT
var player

var idleTime:float = 0.0
var goTowards:Vector2

func _physics_process(delta):
	if !is_instance_valid(player):
		var tmp = get_node_or_null("/root/Node2D/")
		if tmp!=null:
			player=tmp.get_player()
	
	match curState:
		STATE.WAIT:
			if idleTime>0:
				idleTime-=delta
				return
			if (
				abs(player.global_position.x - global_position.x) < 700 and 
				abs(player.global_position.y - global_position.y) < 700
			):
				goTowards = player.global_position-global_position + Vector2(30,40)
				goTowards = goTowards.normalized()
				curState=STATE.CHASE
		STATE.CHASE:
			idleTime+=delta
			var velocity = 1-sin(idleTime*PI/4)
			move_and_slide(goTowards*velocity*300)
			if idleTime>1.5:
				idleTime=1.0
				curState=STATE.WAIT
