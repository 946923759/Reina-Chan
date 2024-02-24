extends Polygon2D


func fadeOut(time:float=.5) -> SceneTreeTween:
	var t = get_tree().create_tween()
	t.tween_property(self,"visible",true,0.0)
	t.tween_property(self,"modulate",Color.black, time)
	return t
	#visible = true
	#$Fadeout_Tween.interpolate_property(self, "modulate", null, Color(0,0,0,1), time, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	#$Fadeout_Tween.start()
	
func fadeIn(time:float=.5):
	#visible = true
	$Fadeout_Tween.interpolate_property(self, "modulate", null, Color(0,0,0,0), time, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Fadeout_Tween.start()
