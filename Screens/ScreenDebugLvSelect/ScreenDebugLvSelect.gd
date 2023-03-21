extends Control

var pos:int=0
var stages:Array = []
var stgLen:int=0

var charSel:int = 0
onready var lvSel:Control=$Control

var reinaAudioPlayer

func set_character(n):
	#$Characters/UMP9.visible=n==0
	#$Characters/M16A1.visible=n==1
	#$Characters/Shin_M16A1.visible=n==2
	var curChar:String = Globals.characterToString(charSel)
	for c in $Characters.get_children():
		if c.name==curChar:
			c.visible=true
			c.playing=true
		else:
			c.visible=false
			c.playing=false
	Globals.playerData.currentCharacter=charSel
	charSel=n

func _ready():
	
	reinaAudioPlayer=ReinaAudioPlayer.new(self)
	reinaAudioPlayer.load_song("StageSelect","Mega Man 10 (recreated).nsf",8)
	
	var font = load("res://FallbackPixelFont.tres")
	stages = Globals.STAGES_REINA.keys()
	stgLen = len(stages)
	for i in range(stgLen):
		var labelpos = Vector2(0,i*50)
# warning-ignore:integer_division
		if i >= (stgLen/2):
			labelpos = Vector2(500,(i-stgLen/2)*50.0)
		var f = Def.LoadFont(font,{
			text=stages[i],
			uppercase=true,
			rect_position=labelpos
		})
		lvSel.add_child(f)
	GainFocusCommand(pos)

	set_character(charSel)

func GainFocusCommand(p:int):
	for i in range(stgLen):
		var actor = lvSel.get_child(i)
		if i==p:
			actor.set("custom_colors/font_color",Color.yellow)
		else:
			actor.set("custom_colors/font_color",Color.white)
	

# warning-ignore:unused_argument
func _input(event):
# warning-ignore:integer_division
	var jump:int=stgLen/2
	if Input.is_action_just_pressed("ui_select"):
		print("lol")
		var newScreen = Globals.STAGES_REINA[stages[pos]]
		if newScreen != "":
			$Confirm.play()
			get_tree().change_scene(Globals.STAGES_REINA[stages[pos]])
		else:
			$NoWay.play()
		#Globals.change_screen(get_tree(),Globals.STAGES_REINA[stages[pos]])
		return
	elif Input.is_action_just_pressed("ui_cancel"):
		Globals.change_screen(get_tree(),"ScreenTitleMenu")
		return
	
	if Input.is_action_just_pressed("ui_down") and pos<stgLen-1:
		pos+=1
		$Select.play()
	elif Input.is_action_just_pressed("ui_up") and pos>0:
		pos-=1
		$Select.play()
	elif Input.is_action_just_pressed("ui_right") and pos+jump<stgLen:
		pos+=jump
		$Select.play()
	elif Input.is_action_just_pressed("ui_left") and pos>=jump:
		pos-=jump
		$Select.play()
		
	if Input.is_action_just_pressed("R1"):
		if charSel<Globals.Characters.LENGTH_CHARACTERS-1:
			set_character(charSel+1)
		else:
			set_character(0)
	elif Input.is_action_just_pressed("L1"):
		if charSel>0:
			set_character(charSel-1)
	GainFocusCommand(pos)

