class_name smQuad
extends ColorRect

func setSize(size:Vector2):
	rect_size=size

func Center():
	rect_position=Globals.SCREEN_CENTER

func hideActor(s:float):
	var seq := TweenSequence.new(get_tree())
	seq._tween.pause_mode = Node.PAUSE_MODE_PROCESS
# warning-ignore:return_value_discarded
	seq.append(self,'modulate:a',0,s)

func showActor(s:float):
	var seq := TweenSequence.new(get_tree())
	seq._tween.pause_mode = Node.PAUSE_MODE_PROCESS
# warning-ignore:return_value_discarded
	seq.append(self,'modulate:a',0,s)
