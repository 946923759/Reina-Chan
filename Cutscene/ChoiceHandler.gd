extends Control

#TODO: Add animations at some point

const Def = preload("res://stepmania-compat/StepManiaActors.gd")
const choiceShader = preload("res://Cutscene/ChoiceShaderFadeSides.tres")
var font = load("res://Cutscene/TextFont.tres")

const numChoices:int = 5
const spacing:int = 60

var currentChoiceSize:int=numChoices
var selection:int=0

#Since _init() runs first I don't have to worry about 
#number of existing nodes
func _init():
	for i in range(numChoices):
		var t:Control = Control.new()
		#t.name="c"+String(i)
		t.add_child(Def.Quad({
			color=Color(0,0,0,1),
			size=Vector2(1280,30),
			rect_position=Vector2(-1280/2,-15),
			name="Quad"
		}))
		t.get_child(0).material=choiceShader
		t.add_child(Def.LoadFont(font,{
			text="Choice "+String(i+1),
			align=1,
			valign=1,
			rect_size=Vector2(1280,50),
			rect_position=Vector2(-1280/2,-25),
			name="Font"
		}))
		t.rect_position=Vector2(1280/2,720/2+i*spacing-(numChoices-1)*spacing/2)
		add_child(t)
	#self.visible=false
func _ready():
	setChoices(["Hello","World",'Choice 3'])
	#rect_position=Globals.SCREEN_CENTER
	pass
	
func update_selections():
	for i in range(currentChoiceSize):
		get_child(i).modulate.a=1.0 if i==selection else .7
	pass

func setChoices(choices:PoolStringArray,default_selection:int=0):
	currentChoiceSize=choices.size()
	var maxWidth=400
	for i in range(numChoices):
		var c = get_child(i)
		if i < currentChoiceSize:
			c.get_child(1).text=choices[i]
			maxWidth = max(maxWidth,font.get_string_size(choices[i]).x)
			c.visible=true
		else:
			c.visible=false
		c.rect_position=Vector2(1280/2,720/2+i*spacing-(currentChoiceSize-1)*spacing/2)
	for i in range(numChoices):
		get_child(i).get_child(0).get_material().set_shader_param("fadeLeftAt",1280/2-maxWidth/2-20)
		get_child(i).get_child(0).get_material().set_shader_param("fadeRightAt",1280/2+maxWidth/2+20)
	selection=default_selection
	update_selections()

func input_up():
	if selection > 0:
		selection-=1
		update_selections()
func input_down():
	if selection < currentChoiceSize-1:
		selection+=1
		update_selections()

#func input_select()->int:
#	return selection

func _input(event):
	if Input.is_action_just_pressed("ui_up"):
		input_up()
	elif Input.is_action_just_pressed("ui_down"):
		input_down()
