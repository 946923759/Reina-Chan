extends Control

export(int, FLAGS,
	"Air Dash",
	"Grenade",
	"None",
	"None",
	"None",
	"None",
	"None",
	"None",
	"None") var unlocked_abilities=0

#const SCREEN_DEFAULT_WIDTH = 1280
var SCREEN_DEFAULT_SIZE = Vector2(1280,720)
var _centered_children_offsets = {}

func _ready():
	$Keyboard.visible=false
	$Keyboard.rect_position.y=0
	_capture_center_offsets($Controller)
	_capture_center_offsets($Keyboard)

	_apply_centered_children_layout()

func _capture_center_offsets(parent_node):
	for child in parent_node.get_children():
		if child is Node2D:
			_centered_children_offsets[child.get_path()] = child.position - SCREEN_DEFAULT_SIZE/2

func _apply_centered_children_layout():
	var center = get_viewport().get_visible_rect().size / 2.0
	for parent_node in [$Controller, $Keyboard]:
		for child in parent_node.get_children():
			var key = child.get_path()
			if not _centered_children_offsets.has(key):
				continue
			child.position = center + _centered_children_offsets[key]

#Passed by the pause screen.
func input(_event):
	if _event is InputEventMouseButton or _event is InputEventMouseMotion:
		return
	$Keyboard.visible=(_event is InputEventKey)
	$Controller.visible=(_event is InputEventJoypadButton or _event is InputEventJoypadMotion)
	


func _on_HowToPlay_item_rect_changed():
	var rect = get_viewport().get_visible_rect().size
	_apply_centered_children_layout()
	$LabelHowToPlay.position_based_on_center(rect.x/2.0)
	
	$Controller/InputHint.position.y = rect.y - 24;
	$Keyboard/InputHint.position.y = rect.y - 24;
