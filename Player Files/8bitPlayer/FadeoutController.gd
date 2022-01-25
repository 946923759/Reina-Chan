extends Polygon2D


func fadeOut(time:float=.5):
	visible = true
	$Fadeout_Tween.interpolate_property(self, "modulate", null, Color(0,0,0,1), time, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Fadeout_Tween.start()
	
func fadeIn(time:float=.5):
	#visible = true
	$Fadeout_Tween.interpolate_property(self, "modulate", null, Color(0,0,0,0), time, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Fadeout_Tween.start()
