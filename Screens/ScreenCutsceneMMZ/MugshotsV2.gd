extends Sprite

var PORTRAITS = [
	"default",
	"UMP9",
	"Architect",
	"Alchemist",
	"Ouroboros",
	"Scarecrow",
	"Agent",
	"M16_Nice",
	"M16A1",
	"Dandelion",
	"9A91",
	"Skorpion",
	"T5000",
	"Elisa"
]
var t:SceneTreeTween

#export(int,"lol","lol2") var portrait = 0

func set_portrait(name: String, radioMask: bool = false):
	var idx = max(PORTRAITS.find(name),0)
	frame = idx
	$MaskOverlay.visible = radioMask

func delay_set_portrait(name:String, radioMask:bool=false, delay:float=0.3):
	if delay<=0.0:
		#printerr("NO DELAY????")
		set_portrait(name,radioMask)
	else:
		if is_instance_valid(t) and t.is_running():
			t.kill()
		t = create_tween()
		t.tween_callback(self,"set_portrait",[name,radioMask]).set_delay(delay)
