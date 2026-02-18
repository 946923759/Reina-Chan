extends Sprite

var timer:float = 0.0
var sprite:AnimatedSprite

func _ready():
	set_process(false)
	visible = false

func begin():
	sprite = get_parent()
	set_process(true)
	visible = true
	region_enabled = false
	#parent.connect("te")

const twoPI = 2*PI
func _process(delta):
	var t = sprite.frames.get_frame(sprite.get_animation(), sprite.frame)
	var f = sprite.flip_h
	self.texture = t
	self.flip_h = f
	
	timer += delta
	if timer > twoPI:
		timer -= twoPI
	var yValue = (sin(timer)+1)/2.0
	#self.scale = Vector2.ONE*Def.SCALE(timer, 0.0, 0.5, 1.0, 1.1)
	#self.self_modulate.a = Def.SCALE(yValue, 0.0, 2.0, 0.0, 128.0)
	#This is from 0.0 to 1.0 not 0 to 255!!!
	self.self_modulate.a = yValue
	#$Label.text = String(yValue)
