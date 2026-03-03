extends Node2D
signal finished()

var enabled = false

export(NodePath) var hp_bar_path
onready var sprite = $AnimatedSprite
onready var HPBar = get_node(hp_bar_path)
onready var introSound:AudioStreamPlayer=$IntroSound

const deathAnimationReversed = preload("res://Animations/deathAnimationReversed.tscn")

func resurrection():
	$ReviveSound.play()
	var sp = deathAnimationReversed.instance()
	sp.position = position
	get_parent().add_child(sp)
	#emit_signal("finished")
	#return
	
	var tw = create_tween()
	tw.tween_property(self,"visible",true,0.0).set_delay(2.5)
	#sprite.visible = true
	sprite.play("idle")
	tw.tween_callback(self,"emit_signal",["finished"])

func playIntro(playSound=true, showHPbar=true)->AudioStreamPlayer:
	#sprite.play("intro")
	if showHPbar:
		var seq := create_tween()
		#HPBar.set_process(true)
		seq.tween_property(HPBar,"position:x",1232,.1)
# warning-ignore:return_value_discarded
		seq.tween_property(HPBar,"health",1,1.5)
# warning-ignore:return_value_discarded
		seq.tween_callback(HPBar,"set_process",[false])
	if playSound:
		introSound.play()
	return introSound
