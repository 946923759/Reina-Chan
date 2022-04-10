extends Sprite

const SPRITE_SIZE=160

var _touch_index : int = -1

func getInputOffset(event)->Vector2:
	if event.position.x > position.x and event.position.x < position.x+SPRITE_SIZE*scale.x:
		if event.position.y > position.y and event.position.y < position.y+SPRITE_SIZE*scale.y:
			return Vector2(event.position.x-position.x-SPRITE_SIZE/2.0*scale.x,event.position.y-position.y-SPRITE_SIZE/2.0*scale.y)
	return Vector2()

func _ready():
	visible=OS.has_touchscreen_ui_hint()

func _input(event: InputEvent) ->void:
	var offset = Vector2()
	if event is InputEventScreenTouch:
		if event.pressed:
			if _touch_index == -1:
				offset = getInputOffset(event)
				if offset != Vector2(): #Hilariously bad code
					_touch_index=event.index
			#else:
			#	print("Already have a touch index, ignoring this touch")
			#	print(event.index)
		elif event.index == _touch_index: #If button released
			resetInput()
			
	elif event is InputEventScreenDrag:
		if event.index == _touch_index:
			offset = getInputOffset(event)
	if offset != Vector2():
		#print(offset)
		if offset.x > 40 and abs(offset.y)<40:
			Input.action_press("ui_right")
			Input.action_release("ui_up")
			Input.action_release("ui_left")
			Input.action_release("ui_down")
		elif offset.x < -40 and abs(offset.y)<40:
			Input.action_press("ui_left")
			Input.action_release("ui_up")
			Input.action_release("ui_right")
			Input.action_release("ui_down")
		elif offset.y < -40 and abs(offset.x)<40:
			Input.action_press("ui_up")
			Input.action_release("ui_right")
			Input.action_release("ui_left")
			Input.action_release("ui_down")
		elif offset.y > 40 and abs(offset.x)<40:
			Input.action_press("ui_down")
			Input.action_release("ui_up")
			Input.action_release("ui_right")
			Input.action_release("ui_left")

func resetInput():
	Input.action_release("ui_up")
	Input.action_release("ui_right")
	Input.action_release("ui_left")
	Input.action_release("ui_down")
	_touch_index=-1
