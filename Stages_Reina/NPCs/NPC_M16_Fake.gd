extends "res://Stages_Reina/NPCs/NPC_Base.gd"
signal finished()

onready var rayCast:RayCast2D = $RayCast2D
onready var a1 = get_node("AnimatedSprite/AfterImage1")
onready var a2 = get_node("AnimatedSprite/AfterImage2")
onready var a3 = get_node("AnimatedSprite/AfterImage3")
var oldPositions:PoolVector2Array = PoolVector2Array()

func _ready():
	oldPositions.resize(6)
	a1.visible=false
	a2.visible=false
	a3.visible=false
	
	#sprite.flip_h = (facing==DIRECTION.LEFT)
	set_process(false)
	$Heaven.connect("finished",self,"raging_demon_fin")

#This is only for raging demon intro!
func _process(delta):
	position.x -= 550*delta
	update_after_image()
	if rayCast.is_colliding():
		var obj:Node2D = rayCast.get_collider().get_parent()
		if obj.has_method('player_touched'):
			return
		print(obj)
		#obj.sprite.play("Hurt")
		sprite.animation="Grenade"
		sprite.frame=2
		$Heaven.raging_demon(obj)
		set_process(false)
		#yield($Heaven,"finished")
		
		#cooldown=INF

func update_after_image():
	var t = sprite.frames.get_frame(sprite.get_animation(), sprite.frame)
	var f = sprite.flip_h
	#var p = 1 if f else -1
	#var i = 0
	oldPositions[5] = position
	for i in range(5):
		oldPositions[i] = oldPositions[i+1]
		#i+=1
	a1.texture = t
	a2.texture = t
	a3.texture = t

	a1.flip_h = f
	a2.flip_h = f
	a3.flip_h = f

	a1.position=oldPositions[4]-position
	a2.position=oldPositions[3]-position
	a3.position=oldPositions[2]-position

#This enables the afterimages
func raging_demon_start():
	print("Raging demon started!")
	tweening_state = TWEEN_STATUS.TWEEN_RUNNING
	a1.visible = true
	a2.visible = true
	a3.visible = true
	sprite.animation = "Falling"
	sprite.playing=false
	set_process(true)
	
func raging_demon_play(): #This plays the animation
	pass

#This disables the afterimages when the raging demon attack connects
func raging_demon_fin():
	a1.visible = false
	a2.visible = false
	a3.visible = false
	sprite.play("default")
	tweening_state = TWEEN_STATUS.TWEEN_FINISHED
	emit_signal("finished")
