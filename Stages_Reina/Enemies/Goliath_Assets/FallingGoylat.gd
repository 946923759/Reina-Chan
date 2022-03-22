extends Area2D

var expl = preload("res://Stages/EnemyExplosion.tscn")

func _ready():
	self.connect("body_entered",self,"objTouched")

func _process(delta):
	position.y+=235*delta
	

func objTouched(obj):
	if obj.has_method("player_touched"): #If enemy touched player
		#lastTouched = obj
		obj.call("player_touched",self,2)
	killSelf()

func killSelf():
	set_physics_process(false)
	$Sprite.visible=false
	set_collision_layer_bit(0,false)
	set_collision_mask_bit(0,false)
	
	var e = expl.instance()
	
	e.position = position
	get_parent().add_child(e)
	queue_free()


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
