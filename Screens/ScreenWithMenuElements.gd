extends Control

export (String) var PrevScreen
export (String) var NextScreen
export (bool) var HandlePhysicalBButton=true
export (bool) var HandlePhysicalAButton=false
export (bool) var ThisScreenIsAnOverlay=false
#export (bool) var ShowBackButton=true

onready var fadeOut = $smScreenInOut
#onready var backButton = $BackButton
#onready var debugOverlay = $CanvasLayer/smQuad/VBoxContainer

func _ready():
#	$CanvasLayer/smQuad.visible=false
#	if !backButton.visible:
#		backButton.mouse_filter=Control.MOUSE_FILTER_IGNORE
#	debugOverlay.get_node("LabelReload").text = "KEY 2: Reload - "+self.name
#
#	var labelNext = debugOverlay.get_node("LabelNext")
#	labelNext.text = "KEY 5: Send NextScreen - "+self.NextScreen
#	if NextScreen=="":
#		labelNext.modulate=Color.dimgray
#
#	var labelPrev = debugOverlay.get_node("LabelPrev")
#	labelPrev.text = "KEY 4: Send PrevScreen - "+self.PrevScreen
#	if PrevScreen=="":
#		labelPrev.modulate=Color.dimgray
	pass


func _input(_event):
	if Input.is_action_just_pressed("ui_cancel") and HandlePhysicalBButton:
		OffCommandPrevScreen()
	elif (Input.is_action_just_pressed("ui_select") or Input.is_action_just_pressed("ui_pause")) and HandlePhysicalAButton:
		OffCommandNextScreen()
		
#	var f3_is_held = Input.is_action_pressed("DebugButton3") #and $smScreenInOut.t.is_active()==false
#	$CanvasLayer/smQuad.visible=f3_is_held
#	if f3_is_held and _event is InputEventKey and _event.pressed:
#		#if :
#		#	return
#		match _event.scancode:
#			KEY_2:
#				get_tree().reload_current_scene()
#			KEY_4:
#				OffCommandPrevScreen()
#			KEY_5:
#				OffCommandNextScreen()
		
	

func OffCommandNextScreen(ns:String=NextScreen)->bool:
	if ns != "":
		fadeOut.OffCommand(ns)
		return true
	elif ThisScreenIsAnOverlay:
		OffCommandOverlay()
	else:
		printerr("NextScreen for "+self.name+" is not defined.")
	return false

func OffCommandPrevScreen()->bool:
	if PrevScreen != "":
		fadeOut.OffCommand(PrevScreen)
		return true
	elif ThisScreenIsAnOverlay:
		OffCommandOverlay()
	else:
		printerr("PrevScreen for "+self.name+" is not defined.")
	return false

func OffCommandOverlay():
	fadeOut.t.interpolate_property(self,"modulate:a",null,0,.5)
	fadeOut.t.start()
	yield(fadeOut.t,"tween_completed")
	queue_free()

#If Android back button pressed
func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
		OffCommandPrevScreen()

func _on_BackButton_gui_input(event):
	if (event is InputEventMouseButton and event.pressed and event.button_index == 1):
		OffCommandPrevScreen()
