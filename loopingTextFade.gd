extends Label

#func _ready():
#	$Tween.interpolate_property(self, "modulate:a",
#		0, 1, .3, Tween.TRANS_LINEAR, Tween.EASE_IN);
#	$Tween.start();


onready var tween_values = [0, 1]

func _enter_tree():
	#var tween = Tween.new()
	#add_child(tween)
	pass

func _ready():
	var k = "Press_Any_Key"
	if OS.has_feature("mobile"):
		k="Tap_Screen"
	elif OS.has_feature("console"):
		k="Press_Button"
	self.text=INITrans.GetString("Startup",k)
	_start_tween()
# warning-ignore:return_value_discarded
	$Tween.connect("tween_completed", self, "_on_tween_completed")

func _start_tween():
	$Tween.interpolate_property(self, "modulate:a", tween_values[0], tween_values[1], 2,
		Tween.TRANS_LINEAR, Tween.EASE_IN);
	$Tween.start()

# warning-ignore:unused_argument
# warning-ignore:unused_argument
func _on_tween_completed(object, key):
	tween_values.invert()
	_start_tween()
