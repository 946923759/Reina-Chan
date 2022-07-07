extends KinematicBody2D


var gf_cutscene = preload("res://Cutscene/CutsceneMain.tscn")

export(int,"AppearFromBoss","Normal") var spawnType = 1
export(int,"Towards Player","Left","Right") var facing=0
export(String) var message_id = "Scarecrow1"

var velocity:Vector2
var gravity = 2000
var disabled:bool=false

onready var sprite:AnimatedSprite = $AnimatedSprite

func _ready():
	if spawnType==0:
		velocity.y=-1000
		#add_central_force(Vector2(0,-200))
	sprite.flip_h=facing==1

func _physics_process(delta):
	velocity=move_and_slide(velocity,Vector2(0,-1),true)
	velocity.y += gravity * delta
	if spawnType==0 and disabled==false and is_on_floor():
		play_cutscene()
	
	if facing==0:
		var p = get_node("/root/Node2D").get_player()
		sprite.flip_h=p.global_position.x < global_position.x
	
func play_cutscene():
	var parent = get_parent()
	get_tree().paused=true
	var newCutscene = gf_cutscene.instance()
	parent.add_child(newCutscene) #Needs to be done first for the _ready()
	#newCutscene.connect("cutscene_finished",self,"part2")
	newCutscene.init_(
		Globals.get_stage_cutscene(message_id),
		parent,
		true,
		null,
		"\t"
	)
	disabled=true
	$AudioStreamPlayer.play()
