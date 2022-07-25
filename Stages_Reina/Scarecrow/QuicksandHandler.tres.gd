extends StaticBody2D
export(int) var quicksand_height_in_half_blocks=4
export(int) var quicksand_draw_height=4
export(float,10,30) var quicksand_speed=10
export(float,0,30) var rising_speed=0

var original_global_pos_y:float
var original_pos_y:float
var player

onready var sprite = $Sprite

func _ready():
	original_pos_y=position.y
	original_global_pos_y=global_position.y
	#var node = get_node_or_null("Area2D")
	#if node:
	$Area2D.connect("body_entered",self,"set_player")
	if rising_speed==0:
		$Area2D.connect("body_exited",self,"disable")

func set_player(obj):
	if obj.has_method("player_touched"):
		#print("Player entered quicksand..")
		player=obj
		#player.inSand=true
		set_physics_process(true)
		
func disable(obj):
	if obj.has_method("player_touched"):
		position.y=original_pos_y
		player.inSand=false
		if rising_speed==0:
			set_physics_process(false)
		
var rising=false
func _physics_process(delta):
	if rising:
		original_global_pos_y-=rising_speed*delta*4
		original_pos_y-=rising_speed*delta*4
		sprite.height+=rising_speed*delta
	
	if player==null:
		#if rising:
		#	position.y=min(position.y+quicksand_speed*delta,original_pos_y+quicksand_height_in_half_blocks*32)
		#	$Sprite.position.y = original_pos_y-position.y-64
		return
	if player.is_on_floor():
		position.y=min(position.y+quicksand_speed*delta,original_pos_y+quicksand_height_in_half_blocks*32)
		if player.global_position.y+64 >= original_global_pos_y+quicksand_height_in_half_blocks*32-1:
			player.die()
	else:
		#Have to account for player hitbox size here since their position starts from the top left
		global_position.y=max(original_global_pos_y,min(player.global_position.y+64,original_global_pos_y+quicksand_height_in_half_blocks*32))
	player.inSand = (player.global_position.y+64 > original_global_pos_y+10)

	$Sprite.position.y = original_pos_y-position.y-64


func _enable_rising(camera, newBounds):
	print("Rising.,..")
	rising=true
	set_physics_process(true)
	
func _enable_rising_alt(obj:KinematicBody2D):
	if obj.has_method("player_touched"):
		#print("Player entered quicksand..")
		player=obj
		#player.inSand=true
		
		print("Rising.,..")
		rising=true
		set_physics_process(true)
	
func _disable_rising(camera, newBounds):
	rising=false
	set_physics_process(false)
