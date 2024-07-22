extends Node2D

export(Color) var text_bg_color
export(PackedScene) var bossToLoad
export(Texture) var large_portrait
export(String) var text = "reina-chan"
enum DIRECTION {LEFT = -1, RIGHT = 1}
export(DIRECTION) var facing = DIRECTION.LEFT
export(bool) var auto_OnCommand=false

func _ready():
	$Polygon2D4.color = text_bg_color
	$Polygon2D5.color = text_bg_color
	for i in range(5):
		text += " "+text
	$Polygon2D4/FakeZText.text = text
	$Polygon2D5/FakeZText.text = text
	$Polygon2D/HDPortrait.texture = large_portrait
	print("CharActor init")
	$BossSpriteLoader.bossToLoad=bossToLoad
	$BossSpriteLoader.InitCommand()
	
	if facing == DIRECTION.RIGHT:
		$BossSpriteLoader.position.x = 1280-$BossSpriteLoader.position.x
		#This one is left aligned so it's dumb
		$Polygon2D.position.x = 1280-$Polygon2D.position.x-400
	if auto_OnCommand:
		OnCommand()

func OnCommand():
	$BossSpriteLoader.OnCommand()
	
	var SCREEN_SIZE = get_viewport().get_visible_rect().size
	var t:SceneTreeTween = get_tree().create_tween()
	t.set_parallel(true)
	t.tween_property(self,"visible",true,0.0)
	#t.tween_property($CenterBG,"position",Vector2(0,SCREEN_SIZE.y/2-240/2),0.0)
	t.tween_property($Polygon2D/HDPortrait,"position:y",-200.0,5)
	t.tween_property($CenterBG,"position:y", SCREEN_SIZE.y/2-240/2, .5).from(SCREEN_SIZE.y/2-240/2*1.5)
	t.tween_property($CenterBG,"scale:y",1.0 ,.5).from(1.5)
	t.tween_property($Polygon2D4,"position",Vector2(0,SCREEN_SIZE.y/2-200),1.0).from(Vector2(0,0)).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t.tween_property($Polygon2D5,"position",Vector2(0,SCREEN_SIZE.y/2+200-30),1.0).from(Vector2(0,SCREEN_SIZE.y)).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
