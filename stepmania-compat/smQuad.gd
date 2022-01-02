class_name smQuad
extends Polygon2D

func setSize(size:Vector2):
	polygon=PoolVector2Array([
		Vector2(-size.x/2,-size.y/2),
		Vector2(size.x/2,-size.y/2),
		Vector2(size.x/2,size.y/2),
		Vector2(-size.x/2,size.y/2)
	])

func Center():
	position=Globals.SCREEN_CENTER

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
