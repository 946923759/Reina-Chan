extends Control

onready var container = $ScrollContainer/GridContainer
var font = preload("res://Cutscene/TextFont.tres")

func LoadSpeaker(s:String)->Label:
	var l = Label.new()
	l.set("custom_fonts/font",font)
	l.text=s
	#How the fuck is anyone supposed to figure this out?
	l.size_flags_vertical=1 
	var width = font.get_string_size(l.text).x
	if width > 280:
		l.rect_scale.x=280/width
	#else:
	#	tn.rect_scale.x=1.0
	#for property in d:
	#	l.set(property,d[property])
	#l.set("custom_fonts/font",font)
	#l.add_to_group("Translatable")
	return l
func LoadText(s:String)->RichTextLabel:
	var l = Label.new()
	l.set("custom_fonts/font",font)
	l.rect_min_size=Vector2(540,0)
	l.autowrap=true
	l.text=s
	return l

var last_history_number:int=0
func set_history(arr):
	if arr.size()>last_history_number:
		for i in range(last_history_number,arr.size()):
			container.add_child(LoadSpeaker(arr[i][0]))
			container.add_child(LoadText(arr[i][1]))
		last_history_number=arr.size()
