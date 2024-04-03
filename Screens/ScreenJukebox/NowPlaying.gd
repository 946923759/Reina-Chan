extends Node2D

onready var title = $Title
onready var album = $Album
onready var artist = $Artist

onready var textObjects = [title, album, artist]


export(float,.1,1,.1) var inverse_timer_speed = 0.5
var counter = 0
var infos = ["Title","Album","Artist"]
var counters:PoolIntArray = PoolIntArray([0,0,0])

func _ready():
	#set_info("This is a title","This is an album","This is a very long artist title")
	clear()
#	set_process(true)

var timer:float = 0.0
func _process(delta):
	timer+=delta
	#print("???")
	if timer > inverse_timer_speed:
		timer -= inverse_timer_speed
		
		for i in range(3):
			if len(infos[i]) > 23 and counters[i] < len(infos[i]):
				counters[i] = counters[i]+1
			else:
				counters[i] = 0
			
			textObjects[i].text = infos[i].substr(counters[i],23)
		#artist.text = artistText.substr(counter,23)
		#print("Counter! "+String(counter))

func set_info(title:String, album:String="", artist:String=""):
	infos = [title, album, artist]
	counters = PoolIntArray([0, 0, 0])
	timer = 0.0
	
	for i in range(3):
		textObjects[i].text = infos[i].substr(0,23)
		textObjects[i].visible=true
	
	set_process(true)

func clear():
	for obj in textObjects:
		obj.visible=false
	set_process(false)
