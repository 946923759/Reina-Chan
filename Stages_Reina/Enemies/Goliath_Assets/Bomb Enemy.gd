tool
extends "res://Stages/EnemyBaseScript.gd"

export (int,"black","red") var type=0;

var fallingGoylat = preload("res://Stages_Reina/Enemies/Goliath_Assets/FallingGoylat.tscn")
onready var carrying = $Carrying
var dropped:bool=false


#Stop obnoxious log spam because "onready sprite" hasn't been assigned yet
func _init():
	set_process(false)
	set_physics_process(false)

func _ready():
	updateVisuals()
	if type==1:
		$AnimatedSprite2.playing=true
		sprite.frame=0
		#$Carry.frame=0
	elif type==0 and !Engine.editor_hint:
		$Carrying.queue_free()
		
	#set_process(Engine.editor_hint)
	set_physics_process(!Engine.editor_hint)
	
func updateVisuals():
	sprite.offset.x=-2*facing
	$AnimatedSprite2.offset.x=-2*facing
	sprite.flip_h = (facing == DIRECTION.RIGHT)
	if type==1:
		sprite.set_animation("red")
		if !Engine.editor_hint:
			carrying.updateDraw(facing)
	else:
		sprite.set_animation("default")
	$AnimatedSprite2.visible=(type==1)
	carrying.visible=(type==1)
	
	

func _process(_delta):
	if Engine.editor_hint:
		updateVisuals()

func _physics_process(_delta):
# warning-ignore:return_value_discarded
	move_and_slide(Vector2(300*facing,0), Vector2(0, -1))
	#var lastCollision = get_slide_collision(0)
	#if lastCollision and lastCollision

	if is_on_wall():
		facing = facing*-1
		sprite.flip_h = (facing == DIRECTION.RIGHT)
		
	if type==1 and !dropped:
		var player = get_node("/root/Node2D/").get_player()
		if player:
			if player.global_position.x > global_position.x-5 and player.global_position.x < global_position.x+5:
				
				#If player runs into it it explodes and it's invalid
				if is_instance_valid(carrying):
					var e = fallingGoylat.instance()
					e.position = position+carrying.position
					carrying.queue_free()
					get_parent().add_child(e)
					e.init(facing)
				dropped=true

func objectTouched(obj):
	print("AAA")
	if obj.has_method("player_touched"): #If enemy touched player
		obj.call("player_touched",self,player_damage)
		#Special case for the bomb enemy, we want the enemy to kill itself when it touches the player
		killSelf()
	elif obj.has_method("enemy_touched"): #If enemy touched bullet
		obj.call("enemy_touched",self)
