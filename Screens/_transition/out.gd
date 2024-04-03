extends Control

onready var fade = $ColorRect
onready var U = $Node2D/U
onready var M = $Node2D/M
onready var P = $Node2D/P

export (int,"Out","In") var transition_type
#export (int,"UMP9","M16") var character

export(Texture) var m16_tex

func OnCommand(character:int = 0):
	if character == 1:
		U.texture = m16_tex
		M.texture = m16_tex
		P.texture = m16_tex
	
	# U.cmd(y,-270;linear,.1;rect_position_y,2400;decelerate,1;rect_position_y,0);
	var spin = 240.0*5.0
	
	var t = get_tree().create_tween()
	t.set_parallel()
	t.tween_property(self,"visible",true,0.0)
	t.tween_property($Node2D/BorderLeft,"visible",true,0.0)
	t.tween_property($Node2D/BorderRight,"visible",true,0.0)
	#t.tween_property($Node2D,"modulate:a",1.0,0.0)
	
	t.tween_property($Node2D/BorderLeft,"modulate:a",1.0,.25)
	t.tween_property($Node2D/BorderRight,"modulate:a",1.0,.25)
	
	t.tween_property(U,"position:y",0,.15)
	t.tween_property(U,"region_rect:position:y",0,1).from(spin).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	t.tween_property(M,"position:y",0,.2).set_delay(.15)
	t.tween_property(M,"region_rect:position:y",spin,1).from(0.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	t.tween_property(P,"position:y",0,.15).set_delay(.30)
	t.tween_property(P,"region_rect:position:y",0,1).from(spin).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	#U.region_rect.position
	
	t.tween_callback($AudioStreamPlayer,"play").set_delay(1)
	for n in [U,M,P]:
		t.tween_property(n,"region_rect:position:y",-4,.07).from_current().set_delay(1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		t.tween_property(n,"region_rect:position:y",4,.07).from_current().set_delay(1.07).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		t.tween_property(n,"region_rect:position:y",0,.07).from_current().set_delay(1.14)

	t.tween_property(fade,"modulate:a",1.0,.2).set_delay(1.21)
	t.set_parallel(false)
	return t

func OffCommand():
	var t = get_tree().create_tween()
	#t.tween_property(self,"visible",true,0.0)
	t.tween_property(fade,"modulate:a", 0.0, .25) #.25/2
	t.tween_property($Node2D,"modulate:a",0.0,.25/2).set_delay(.25/2)
	t.tween_property(self,"visible",false,0.0)
	#t.tween
	return t

func _ready():
	if transition_type == 0:
		U.position.y = -720
		M.position.y = 720
		P.position.y = -720
	else:
		if Globals.playerData.currentCharacter == 1:
			U.texture = m16_tex
			M.texture = m16_tex
			P.texture = m16_tex
		fade.modulate.a = 1.0
		visible=true
		$Node2D/BorderLeft.visible = true
		$Node2D/BorderRight.visible = true
		$Node2D/BorderLeft.modulate.a = 1.0
		$Node2D/BorderRight.modulate.a = 1.0
	#OnCommand()
	pass
	
#func _input(event):
#	if event is InputEventKey and event.pressed:
#		if event.scancode == KEY_0:
#			OnCommand()
#		elif event.scancode == KEY_1:
#			OffCommand()
