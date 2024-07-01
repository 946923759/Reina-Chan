extends KinematicBody2D
signal cutscene_finished


var gf_cutscene = preload("res://Screens/ScreenCutscene/CutsceneMain.tscn")
var emblem_drop = preload("res://Various Objects/pickupReinaEmblem.tscn")

export(int,"AppearFromBoss","Normal") var spawnType = 1
export (String) var animToPlayIfNormal = "default"
export(int,"Towards Player","Left","Right") var facing=0
export(String) var message_id = "Scarecrow1"

export(int,"None","U","M","P","9","C","H","A","N") var unlocksEmblem = 0
export(int,"None",
	"Architect",
	"Alchemist",
	"Ouroboros",
	"Scarecrow",
	"???", "???", "???", "???",
	"Clear And Fail",
	"U (9A-91)", "M", "P", "9", "C", "H", "A", "N") var requiresUnlock = 0
#export(int,"Unlocks","Requires") var unlocksOrRequires = 1

var velocity:Vector2
var gravity = 2000
var disabled:bool=false
var just_touched_ground:bool=false

onready var animPlayer:AnimationPlayer = $DustCloud/AnimationPlayer
onready var sprite:AnimatedSprite = $AnimatedSprite

func _ready():
	if requiresUnlock > 0:
		if requiresUnlock < 10:
			self.visible = Globals.playerData.availableWeapons[requiresUnlock]
		else:
			self.visible = Globals.playerData.ReinaChanEmblems[requiresUnlock-10]
		set_physics_process(self.visible)
	
	
	$DustCloud/LeftC.modulate.a=0
	$DustCloud/RightC.modulate.a=0
	
	if spawnType==0:
		velocity.y=-1000
		sprite.play("falling")
	else:
		sprite.play(animToPlayIfNormal)
		#add_central_force(Vector2(0,-200))
	sprite.flip_h=facing==1
	
	$TalkHelp.visible=false

var timer:float=0
func _physics_process(delta):
	velocity=move_and_slide(velocity,Vector2(0,-1),true)
	velocity.y += gravity * delta
	
	#Is there a smarter way to do this without having to branch?
	if velocity.x > 0:
		velocity.x = max(0,velocity.x-gravity*delta)
	elif velocity.x < 0:
		velocity.x = min(0,velocity.x+gravity*delta)
	
	#if visible==false:
	#	return
	
	if spawnType==0 and disabled==false and is_on_floor():
		if timer>.5:
			play_cutscene()
		else:
			timer+=delta
		if just_touched_ground==false:
			animPlayer.play("default")
			sprite.play("default")
			just_touched_ground=true
	elif spawnType==1:
		var p = get_node("/root/Node2D").get_player()
		if abs(p.global_position.x - global_position.x) < 100 and \
		abs(p.global_position.y - global_position.y) < 100:
				timer+=delta
				if timer>1:
					timer=0
				$TalkHelp.visible=timer<.5
				if Input.is_action_just_pressed("ui_up"):
					play_optional_cutscene()
		else:
			$TalkHelp.visible=false
			
	
	if facing==0:
		var p = get_node("/root/Node2D").get_player()
		sprite.flip_h=p.global_position.x < global_position.x
	


func play_cutscene():
	if Globals.playCutscenes:
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
	emit_signal("cutscene_finished")
	$AudioStreamPlayer.play()

func play_optional_cutscene():
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
	#disabled=true
	emit_signal("cutscene_finished")
	if unlocksEmblem > 0:
		var inst:RigidBody2D = emblem_drop.instance()
		inst.emblem = unlocksEmblem-1
		get_parent().add_child(inst)
		inst.global_position = global_position
		inst.apply_central_impulse(Vector2(0,-100))
