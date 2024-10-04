extends Control

export(Color) var text_bg_color
export(PackedScene) var bossToLoad
export(Texture) var large_portrait
export(String) var text = "reina-chan"
enum DIRECTION {LEFT = -1, RIGHT = 1}
export(DIRECTION) var facing = DIRECTION.LEFT
export(bool) var auto_OnCommand=false
export(bool) var flip_h=false

func _ready():
	$Polygon2D4.color = text_bg_color
	$Polygon2D5.color = text_bg_color
	
	# .repeat() is significantly faster than str+str over and over since it only needs to allocate once. At least in Godot 3.6.
	text += (" "+text).repeat(20)
	$Polygon2D4/FakeZText.text = text
	$Polygon2D5/FakeZText.text = text
	
	$HDPortrait.texture = large_portrait
	$HDPortrait/HDPortrait_BG.texture = large_portrait
	$HDPortrait.flip_h = flip_h
	$HDPortrait/HDPortrait_BG.flip_h = flip_h
	
	print("CharActor init")
	$BossSpriteLoader.bossToLoad=bossToLoad
	$BossSpriteLoader.InitCommand()
	
	if facing == DIRECTION.RIGHT:
		$BossSpriteLoader.position.x = 1280-$BossSpriteLoader.position.x
		#This one is left aligned so it's dumb
		$HDPortrait.position.x = 1280-$HDPortrait.position.x
		$HDPortrait/HDPortrait_BG.position.x = -1 * $HDPortrait/HDPortrait_BG.position.x
	if auto_OnCommand:
		OnCommand()

func OnCommand():
	$BossSpriteLoader.OnCommand()
	
	var SCREEN_SIZE = get_viewport().get_visible_rect().size
	# TODO: Position the HDPortrait properly. We can't use TextureRect
	# because it doesn't have proper z-ordering.
	
	var t:SceneTreeTween = get_tree().create_tween()
	t.set_parallel(true)
	t.tween_property(self,"visible",true,0.0)
	#t.tween_property($CenterBG,"position",Vector2(0,SCREEN_SIZE.y/2-240/2),0.0)
	t.tween_property($HDPortrait,"position:y",400,5)
	t.tween_property($CenterBG,"rect_position:y", SCREEN_SIZE.y/2-240/2, .5).from(SCREEN_SIZE.y/2-240/2*1.5)
	#t.tween_property($CenterBG,"scale:y",1.0 ,.5).from(1.5)
	t.tween_property($Polygon2D4/FakeZText,"position:x",-1280*2,10)
	t.tween_property($Polygon2D5/FakeZText,"position:x",20.0,10).from(-1280.0*2.0)
	t.tween_property($Polygon2D4,"rect_position",Vector2(0,SCREEN_SIZE.y/2-200),1.0).from(Vector2(0,0)).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t.tween_property($Polygon2D5,"rect_position",Vector2(0,SCREEN_SIZE.y/2+200-60),1.0).from(Vector2(0,SCREEN_SIZE.y)).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
