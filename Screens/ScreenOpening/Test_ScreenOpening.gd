extends "res://Screens/ScreenWithMenuElements.gd"

export(Color) var text_bg_color
export(String) var bossToLoad

onready var seq = [
	[0.0, $ZTextWalk],
	[03.723, $ZText2],
	[07.432, $Ouroboros],
	[11.130, $Scarecrow],
	[14.800, $Alchemist],
	[18.450, $Architect],
	#[20.330, ],
	[23.100, $LogoFade],
	[INF]
]
var step = 0

var total:float = 0.0

func _ready():
	for o in seq:
		if len(o)>1:
			o[1].visible=false
			
	$AudioStreamPlayer.connect("finished",self,"OffCommandNextScreen")

#Maybe frame time is better
func _physics_process(delta):
	total+=delta
	if total>=seq[step][0]:
		assert(seq[step][1])
		#seq[step][1].OnCommand()
		seq[step][1].OnCommand()
		if step>0:
			seq[step-1][1].queue_free()
		step+=1
	#if total>=
#func _process(delta):
#	total+=delta
