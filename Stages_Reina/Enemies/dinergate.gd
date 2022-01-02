extends "res://Stages/EnemyBaseScript.gd"

enum STATES {
	RUNNING = 0,
	SHOOTING,
	RUNNING_AGAIN
}
var curState = 0

var player
var sleepTime: float = 0
var numShots: int = 0

export(bool) var no_movement = false

var bullet = preload("res://Stages_Reina/Enemies/bulletDinergate.tscn")

func _ready():
	player = get_node_or_null("/root/Node2D/Player")
	if !is_instance_valid(player):
		print("DINERGATE: No player, assuming test mode")
	#.global_position.x > global_position.x:

func _physics_process(delta):
	#IF DEBUGGING
	if !is_instance_valid(player):
		#push_warning("DINERGATE: There's no player on this stage, are you an idiot?")
		#set_physics_process(false);
		if sleepTime >= 0:
			sleepTime-=delta
		else:
			var bi = bullet.instance()
			var pos = position + Vector2(15*facing, -16)
			
			bi.position = pos
			get_parent().add_child(bi)
			bi.init(Vector2(5*facing,0))
			
			self.add_collision_exception_with(bi)# Make bullet and this not collide
			sleepTime=1
			print("Fired bullet.")
		return
	
	#NORMAL PROCESS
	#print(player.global_position.x - global_position.x)
	if curState==0 and (abs(player.global_position.x - global_position.x) < 500 or sleepTime >= 0):
		if sleepTime >= 0:
			sleepTime-=delta
			move_and_slide(Vector2(0,420), Vector2(0, -1))
		else:
			if numShots < 3:
				var bi = bullet.instance()
				var pos = position + Vector2(15*facing, -16)
				
				bi.position = pos
				get_parent().add_child(bi)
				bi.init(Vector2(5*facing,0))
				
				add_collision_exception_with(bi) # Make bullet and this not collide
				sleepTime=.4
				numShots+=1;
			else:
				#sleepTime = 1
				numShots = 0
				curState=STATES.RUNNING_AGAIN
	else:
		if no_movement:
			move_and_slide(Vector2(0,420), Vector2(0, -1))
		else:
			move_and_slide(Vector2(200*facing,200), Vector2(0, -1))
			if abs(player.global_position.x - global_position.x) > 500:
				curState=0
		if is_on_wall():
			facing = facing*-1
			sprite.flip_h = (facing == DIRECTION.RIGHT)
			
		if global_position.x > player.get_node("Camera2D").limit_right+50:
			print("Dinergate walked offscreen, despawning.")
			queue_free()
