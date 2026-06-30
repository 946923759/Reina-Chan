extends Node

const PLAYER_1 = 0
const PLAYER_2 = 1
const PLAYER_3 = 2
const PLAYER_4 = 3

#Matches the positions at the int32
enum BUTTON {
	LEFT,
	RIGHT,
	UP,
	DOWN,
	JUMP,
	SHOOT,
	GRENADE,
	UNUSED, #Unused
	L1,
	R1
}

const LEFT = [
	"ui_left",
	"p2_left"
]
const RIGHT = [
	"ui_right",
	"p2_right"
]
const UP = [
	"ui_up",
	"p2_up"
]
const DOWN = [
	"ui_down",
	"p2_down"
]
const JUMP = [
	"gameplay_jump",
	"p2_accept"
]
const SHOOT = [
	"gameplay_shoot",
	"p2_btn3"
]
const GRENADE = [
	"gameplay_grenade",
	"p2_cancel"
]
# Nobody is gonna remember this so just name it THIRD FOURTH
#const TERTIARY = [
#
#]
#const QUARTARY = [
#
#]
const FOURTH = [
	"p1_btn4",
	"p2_btn4"
]
const R1 = [
	"R1",
	"p2_R1"
]
const L1 = [
	"L1",
	"p2_L1"
]
const START = [
	"",
	""
]
const SELECT = [
	"",
	""
]

func vibrate_device(
	device: int, 
	weak_magnitude: float, 
	strong_magnitude: float, 
	duration_seconds: float = 0
):
	if Globals.OPTIONS['Vibration']['value']:
		#var c = Input.get_connected_joypads()
		if Input.get_connected_joypads().size() > 0:
			Input.start_joy_vibration(
				device,
				weak_magnitude,
				strong_magnitude,
				duration_seconds
			)
		elif OS.has_feature("mobile"):
			#Why is this in ms and the controller one in seconds?
# warning-ignore:narrowing_conversion
			Input.vibrate_handheld(duration_seconds * 1000)

func get_as_struct(controller_index:int = 0) -> Dictionary:
	return {
		left = Input.is_action_pressed(LEFT[controller_index]), 
		right = Input.is_action_pressed(RIGHT[controller_index]),
		up = Input.is_action_pressed(UP[controller_index]), 
		down = Input.is_action_pressed(DOWN[controller_index]), 
		jump = Input.is_action_just_pressed(JUMP[controller_index]), 
		shoot = Input.is_action_just_pressed(SHOOT[controller_index])
	}

func get_as_int32(controller_index:int = 0) -> int:
	# return Globals.bitArrayToInt32([
	# 	Input.is_action_pressed(LEFT[controller_index]), 
	# 	Input.is_action_pressed(RIGHT[controller_index]),
	# 	Input.is_action_pressed(UP[controller_index]), 
	# 	Input.is_action_pressed(DOWN[controller_index]), 
	# 	Input.is_action_just_pressed(JUMP[controller_index]), 
	# 	Input.is_action_just_pressed(SHOOT[controller_index])
	# ])

	# This is the same thing as above but optimized to not create an array. It does all the math on the CPU.
	return (
		int(Input.is_action_pressed(LEFT[controller_index])) |
		(int(Input.is_action_pressed(RIGHT[controller_index])) << 1) |
		(int(Input.is_action_pressed(UP[controller_index])) << 2) |
		(int(Input.is_action_pressed(DOWN[controller_index])) << 3) |
		(int(Input.is_action_just_pressed(JUMP[controller_index])) << 4) |
		(int(Input.is_action_just_pressed(SHOOT[controller_index])) << 5)
	) & 0xFF
