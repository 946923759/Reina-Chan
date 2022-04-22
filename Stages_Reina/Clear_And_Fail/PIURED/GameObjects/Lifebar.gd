extends Node2D
# Custom draws are used for this since changing the
# rect takes more effort and a custom draw
# is probably faster anyways because there are no nodes
# accessed

#Also this doesn't use much PIURED code because I find having
#8 separate files for a lifebar to be completely obnoxious


var back:Texture
var bar:Texture
var front:Texture
var tip:Texture
var pulse
var barLife:int

var backPos:Rect2
var barPos:Rect2
var barMaxWidth:int
var tipPos:Rect2
#The width and height of this one will never change but we might as well use the same type
var frontPos:Rect2

#To position this object at the center like normal sprites
var centerPos:Vector2

func _ready():
	constructor(null)

func constructor(beatManager,isDoubles:bool=false):
	var s = "D" if isDoubles else "S"
	back  = load("res://Stages_Reina/Clear_And_Fail/PIURED/Resources/LifeMeterBar_"+s+"_Back 1x2.PNG")
	bar   = load("res://Stages_Reina/Clear_And_Fail/PIURED/Resources/LifeMeterBar_"+s+"_Bar 1x2.png")
	front = load("res://Stages_Reina/Clear_And_Fail/PIURED/Resources/LifeMeterBar_"+s+"_Front.png")
	tip   = load("res://Stages_Reina/Clear_And_Fail/PIURED/Resources/SG-TIP 1x2.png")
	
	backPos=Rect2(0,0,back.get_width(),back.get_height()/2)
	barPos=Rect2(0,0,bar.get_width(),bar.get_height()/2)
	tipPos=Rect2(0,0,tip.get_width(),tip.get_height()/2)
	frontPos=Rect2(0,0,front.get_width(),front.get_height())
	centerPos=frontPos.size/-2
	
	barMaxWidth=bar.get_width()
	
	setLife(.5)
	
#var back_y_pos = 0
func setLife(life:float): #Float from 0.0 to 1.0
	if life < .3:
		backPos.position.y=34
		tipPos.position.y=50
	else:
		backPos.position.y=0 #Black back
		tipPos.position.y=0
	barPos.size.x=barMaxWidth*life
	#tipPos.position.x=barPos.size.x
	barLife=life

#Return the size of the largest sprite so PlayerStage will center it
#where it needs
func getSize()->Vector2: 
	return frontPos.size

func _draw():
	#draw_texture_rect_region(back,Rect2())
	#draw_texture_rect(back,Rect2(0,0,100,100),false)
	draw_texture_rect_region(back,Rect2(0,0,backPos.size.x,backPos.size.y),backPos)
	
	#TODO: Color modulate for bar and tip
	draw_texture_rect_region(bar,Rect2(0,33/2-20/2,barPos.size.x,barPos.size.y),barPos)
	draw_texture_rect_region(tip,Rect2(barPos.size.x-15,33/2-50/2,tipPos.size.x,tipPos.size.y),tipPos)
	
	draw_texture_rect_region(front,Rect2(0,0,frontPos.size.x,frontPos.size.y),frontPos)
