extends "res://Stages/EnemyBaseScript.gd"

enum STATES {
	TWEEN_VISIBLE,
	SHOOTING
	TWEEN_INVISIBLE
}
var curState = 0

var player
var sleepTime: float = 0
var numShots: int = 0

onready var tween = $Tween

export(bool) var no_movement = false

var bullet = preload("res://Stages_Reina/Enemies/bulletDinergate.tscn")

func _ready():
	#player = get_node_or_null("/root/Node2D/Player")
	#if !is_instance_valid(player):
	#	print("DINERGATE: No player, assuming test mode")
	#.global_position.x > global_position.x:
	$AnimatedSprite.modulate.a=0.0
	pass

var timer:float = 0.0
func _physics_process(delta):
	timer-=delta
	if curState == STATES.TWEEN_VISIBLE:
		if timer <= 0:
			tween.interpolate_property($AnimatedSprite, 'modulate:a',
				null, 1, .25, Tween.TRANS_LINEAR, Tween.EASE_OUT);
			tween.start();
			curState+=1
			timer=.3
	elif curState == STATES.SHOOTING:
		if timer<= 0:
			$Area2D.monitoring = true
			var bi = bullet.instance()
			var pos = position + Vector2(15*facing, -16)
			
			bi.position = pos
			get_parent().add_child(bi)
			bi.init(Vector2(5*facing,0))
			
			self.add_collision_exception_with(bi)# Make bullet and this not collide
			#sleepTime=1
			#print("Fired bullet.")
			timer=.3
			curState+=1
	elif curState == STATES.TWEEN_INVISIBLE:
		if timer<=0:
			$Area2D.monitoring = false
			tween.interpolate_property($AnimatedSprite, 'modulate:a',
				null, 0, .25, Tween.TRANS_LINEAR, Tween.EASE_OUT);
			tween.start();
			curState=0
			timer=3
			
