extends Node2D

onready var sprite = $Sprite
onready var area = $Area2D
var progress = -1
var cooldown = 0.0

func _ready():
	sprite.region_rect = Rect2(0,0,0,0)
	area.monitoring = false
	set_process(false)
	
	# warning-ignore:return_value_discarded
	area.connect("body_entered",self,"objectTouched")

func objectTouched(obj):
	#print("intersecting!")
	if obj.has_method("player_touched"): #If enemy touched player
		#lastTouched = obj
		obj.call("player_touched",self,1)

#func OnCommand():
#	set_process(true)

func _process(delta):
	if cooldown > 0.0:
		cooldown -= delta
		return
	
	progress+=1
	if progress > 8:
		progress = -1
		set_process(false)
		area.monitoring = false
		return

	area.monitoring = progress > 0
	if progress > 0:
		if progress <= 4:
			
			sprite.region_rect = Rect2(0,0,8,8*progress)
			self.position.y = -32*progress
		else:
			sprite.region_rect = Rect2(0,0,8,8*(8-progress))
			self.position.y = -32*(8-progress)
		cooldown = 8.0/60.0
	else:
		var tw = create_tween()
		tw.tween_property($Sprite2,"visible",true, 0.0)
		tw.tween_property($Sprite3,"visible",true, 0.0)
		tw.tween_method(self,"upside_down_parabola",0.0,4.0,10.0/60.0)
		tw.tween_property($Sprite2,"visible",false, 0.0)
		tw.tween_property($Sprite3,"visible",false, 0.0)
	
		cooldown = 40.0/60.0

func upside_down_parabola(xVal:float):
	$Sprite2.position = Vector2(
		xVal,
		pow(2-xVal,2)/2+2
	)*4.0
	
	$Sprite3.position = $Sprite2.position * Vector2(-1,1)
