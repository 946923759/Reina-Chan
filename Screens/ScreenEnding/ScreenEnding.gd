extends Node2D

onready var fade = $CanvasLayer/FadeIn

func _ready():
	Globals.previous_screen = "ScreenEnding"
	$ParallaxBackground/ParallaxLayer2/Clouds.modulate = Color.black
	$lol.visible = true
	$Reina.play("Falling")
	$BitmapFont.displayed_characters = 0
	$BitmapFont.set_process(true)
	fade.visible = true
	var tween = create_tween()
	tween.tween_property(fade,"modulate:a",0.0,0.5)
	tween.tween_property($lol,"modulate:a",0.0,0.5).set_delay(1.0)
	tween.tween_property($ParallaxBackground/ParallaxLayer2/Clouds,"modulate",Color.white,0.5).set_delay(1.0)
	
	#768 -> 0 in 1.0 seconds
	tween.tween_property($Stage,"position:y",0.0,.75);
	#Need to figure out the same length of time for 368 -> 640
	#so 768-0=1.0 -> 640-368 = 272? 272/768=.35
	tween.tween_property($Reina,"position:y",636,.25) #.from(368)
	tween.tween_callback($Reina,"play",["Idle"])
	
	#$BitmapFont.displayed_characters = 22
	tween.tween_property($BitmapFont,"displayed_characters",22,1.0)


func _on_AudioStreamPlayer_finished():
	fade.color = Color.black
	var tw = create_tween()
	tw.tween_property(fade,"modulate:a",1.0,0.5).from(0.0)
	tw.tween_callback(Globals,"change_screen",[get_tree(),"ScreenCredits"])
	#Globals.change_screen(get_tree(),"ScreenCredits")
	pass # Replace with function body.
