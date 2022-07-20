extends Area2D

#get_overlapping_bodies() doesn't work until the physics thread
#calls it at least one time. So we wait .3 seconds, if no enemy
#appears in that time then give up.

var timer:float=0.0

var scarecrowSpin:Node2D
var bulletSmall

func _ready():
	set_process(false)
	monitoring=false

var root:Node2D
func start_thread(bs,ss:Node2D,limit:float=0.1):
	bulletSmall=bs
	scarecrowSpin=ss
	timer= -limit
	monitoring=true
	set_process(true)
	root=get_node("/root/Node2D")
	#print("Threading!")

#This probably shouldn't be here in the first place
func fireBulletSmall(initPosGlobal:Vector2,destPosGlobal:Vector2):
	var bi = bulletSmall.instance()
	
	root.add_child(bi)
	bi.global_position=initPosGlobal
	var v:Vector2 = (destPosGlobal-initPosGlobal).normalized()*10
	print(v)
	bi.init(v)

#I'd prefer to name this "scarecrow thread"
func _process(delta):
	if timer>=0.0:
		set_process(false)
		var sPos1 = scarecrowSpin.getSprite(0).global_position
		var sPos2 = scarecrowSpin.getSprite(1).global_position
		var sPos3 = scarecrowSpin.getSprite(2).global_position
		var p:KinematicBody2D = get_parent()
		#if p.flip_h
		var destPos:Vector2 = get_parent().global_position
		if p.sprite.flip_h:
			destPos.x-=600
		else:
			destPos.x+=600
		fireBulletSmall(sPos1,destPos)
		fireBulletSmall(sPos2,destPos)
		fireBulletSmall(sPos3,destPos)
		
		return
	var b = get_overlapping_bodies()
	if len(b) > 0:
		var sPos1 = scarecrowSpin.getSprite(0).global_position
		var sPos2 = scarecrowSpin.getSprite(1).global_position
		var sPos3 = scarecrowSpin.getSprite(2).global_position
		if len(b) >= 3:
			fireBulletSmall(sPos1,b[0].global_position)
			fireBulletSmall(sPos2,b[1].global_position)
			fireBulletSmall(sPos3,b[2].global_position)
		#elif len(b) == 2:
		#	fireBulletSmall(sPos1,b[0].global_position)
		#	fireBulletSmall(sPos2,b[0].global_position)
		#	fireBulletSmall(sPos3,b[0].global_position)
		else:
			fireBulletSmall(sPos1,b[0].global_position)
			fireBulletSmall(sPos2,b[0].global_position)
			fireBulletSmall(sPos3,b[0].global_position)
			
		set_process(false)
		return
	#for c in get_overlapping_bodies():
		
		#print(c.global_position)
	
	
	timer+=delta
