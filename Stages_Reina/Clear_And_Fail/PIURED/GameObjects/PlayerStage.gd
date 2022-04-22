extends Node2D
# A lifebar implementation needs two things:
# constructor(beatManager:BeatManager,isDoubles:bool)
# setLife(life:float)
# The rest is up to you.
# You are free to ignore the beatManager argument
# of course, but it's useful if you want the lifebar
# to pulse to the beat.

# A Judgment graphic implementation needs just one function:
# animate(grade:String, comboCount:int)


func _ready():
	$Judgment.position=Globals.SCREEN_CENTER
	$Lifebar.position=Vector2(Globals.SCREEN_CENTER_X,40)
