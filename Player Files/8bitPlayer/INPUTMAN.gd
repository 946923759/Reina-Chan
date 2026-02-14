extends Node

const PLAYER_1 = 0
const PLAYER_2 = 1
const PLAYER_3 = 2
const PLAYER_4 = 3

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
			Input.vibrate_handheld(duration_seconds * 1000)
