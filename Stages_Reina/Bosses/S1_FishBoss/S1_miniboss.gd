extends "res://Stages/MinibossBase.gd"

#After 50% health, top cannon flips and then it starts shooting the bottom?
enum STATES {
	WAIT = 0,
	CHARGING,
	FIRE,
	COOLDOWN
}

var starting_position:Vector2
var offset_position
var player:KinematicBody2D

onready var sprite_laser = $Laser

const b1 = preload("res://Stages_Reina/Bosses/Agent/bulletAgent.tscn")
const b2 = preload("res://Stages_Reina/Enemies/bulletDanmaku.tscn")

func _ready():
	starting_position = position
	
	$LaserCharging.connect("finished",self,"fireLaser")
	#set_physics_process(false)

var waitTime:float = 0.0
var waitTime2:float = 0.0
var numShots:int = 0
var direction = -1

func _physics_process(delta):
	
	if player==null: #TODO: This should probably be in the base class
		player=get_node("/root/Node2D/").get_player()
	
	offset_position = position - starting_position
	if offset_position.y < -100:
		direction = 1
	elif offset_position.y > 100:
		direction = -1
	
	self.position.y += delta*direction*100

	waitTime2-=delta
	if waitTime2 <= 0.0:
		waitTime2 = 1.0
		var v:Vector2 = player.global_position-global_position + Vector2(30,40)
		v=v.normalized()*8
		#var v:Vector2 = Vector2(-8, 2)
		var root = get_parent().get_parent()
		fire_bullet(root, root.to_local($Position2D.global_position), v)
	
	if current_state==STATES.WAIT:
		waitTime -= delta
		if waitTime <= 0:
			waitTime = 1.0
			current_state=STATES.CHARGING
			#sprite.animation="charging"
			sprite.play("charging")
			$LaserCharging.play()
	if current_state==STATES.COOLDOWN:
		sprite.play("default")
		waitTime -= delta
		if waitTime <= 0:
			waitTime = .8
			recharge()

func fire_bullet(root:Node2D, position:Vector2, velocity:Vector2):
	var bi = b2.instance()
	bi.position = position
	root.add_child(bi)
	bi.init(velocity, true)

func fireLaser():
	current_state=STATES.FIRE
	$laserArea2D.monitoring=true
	$LaserFire.play()
	#$Tween.
	var seq := get_tree().create_tween()
	sprite_laser.scale.y=1
	seq.tween_property(sprite_laser,'toDraw',256,.1).set_trans(Tween.TRANS_QUAD)
	#sprite.animation="fire"
	current_state=STATES.COOLDOWN
	
func recharge():
	$laserArea2D.monitoring=false
	sprite_laser.toDraw=0
	#sprite.animation="wait"
	#var seq := get_tree().create_tween()
	#seq.tween_property($Sprite,'scale:y',0,.1).set_trans(Tween.TRANS_QUAD)
	current_state=STATES.WAIT
