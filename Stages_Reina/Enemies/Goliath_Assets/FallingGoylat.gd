extends Area2D
#"Goylat" is the chinese mispelling MICA uses for Goliath, if you were wondering

var expl = preload("res://Stages/EnemyExplosion.tscn")

func _ready():
	self.connect("body_entered",self,"objTouched")
	set_physics_process(false)
	
func init(facing:int=1):
	set_physics_process(true)
	var s = $Sprite
	updateDraw(facing)
	s.rotation_degrees=facing*36.5

#Also called from tool script, so can't be used in init()
func updateDraw(facing):
	var s = $Sprite
	s.flip_h=(facing==1)
	s.offset=Vector2(-2*facing,3*facing)

var velo:float=0
func _physics_process(delta):
	position.y+=390*delta+velo
	velo+=delta*4
	

func objTouched(obj):
	if obj.has_method("player_touched"): #If enemy touched player
		#lastTouched = obj
		obj.call("player_touched",self,2)
	die()

func die():
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
