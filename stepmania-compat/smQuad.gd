class_name smQuad
extends ColorRect

func setSize(size:Vector2):
	rect_size=size

func Center():
	rect_position=Globals.SCREEN_CENTER

func hideActor(s:float):
	var seq := get_tree().create_tween()
	seq.set_pause_mode(SceneTreeTween.TWEEN_PAUSE_PROCESS)
# warning-ignore:return_value_discarded
	seq.tween_property(self,'modulate:a',0,s)

func showActor(s:float):
	var seq := get_tree().create_tween()
	seq.set_pause_mode(SceneTreeTween.TWEEN_PAUSE_PROCESS)
# warning-ignore:return_value_discarded
	seq.tween_property(self,'modulate:a',0,s)
