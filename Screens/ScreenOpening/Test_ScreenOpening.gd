extends "res://Screens/ScreenWithMenuElements.gd"

export(Color) var text_bg_color
export(String) var bossToLoad

onready var seq = [
	[03.723, $ZTextWalk],
	[11.130, $Ouroboros],
	[14.800, $Scarecrow],
	[INF]
]
var step = 0

var total:float = 0.0

func _ready():
	for o in seq:
		if len(o)>1:
			o[1].visible=false

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
