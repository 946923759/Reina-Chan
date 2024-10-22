#tool
extends Sprite

const PI_MULT_2 = PI*2.0
const WIDTH = 55.0
export(float,0,6.28,.1) var x = 0.0;
export(int,0,2) var frame_ = 0;

#func update_p():
#	self.position.x = cos(x)*WIDTH
#	self.z_index = floor(sin(x))
	
#var timing:float = 0.0
func _process(delta):
	#timing+=delta
	x+=delta*5
	
	if x >= PI_MULT_2:
		x -= PI_MULT_2
	self.position.x = cos(x)*WIDTH
# warning-ignore:narrowing_conversion
	self.z_index = sin(x)-1
	#update_p()

	#if timing>3:
	#	timing-=3
	#var ret = int((-pow(timing-3,2)+9)/3.0)
	#var ret = int(timing*28)%2
	self.region_rect.position=Vector2(24*frame_,26)
