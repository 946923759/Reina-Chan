extends Control

var pos:int=0
var stages:Array = []
var stgLen:int=0

var charSel:int = 0
onready var lvSel:Node2D=$lvSelActorFrame

var bitmapFont = preload("res://ubuntu-font-family/BitmapFont.tscn")
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
	$LabelCharName.text = curChar
	Globals.playerData.currentCharacter=charSel
	charSel=n

func _ready():
	Globals.previous_screen = "ScreenDebugSelect"
	CheckpointPlayerStats.clearEverything()
	#reinaAudioPlayer=ReinaAudioPlayer.new(self)
	#reinaAudioPlayer.load_song("StageSelect","Mega Man 10 (recreated).nsf",8)
	
	#var font = load("res://ubuntu-font-family/FallbackPixelFont.tres")
	stages = Globals.STAGES_REINA.keys()
	stgLen = len(stages)
	for i in range(stgLen):
		var labelpos = Vector2((i&1)*600,floor(i/2)*50)
		
		var f = bitmapFont.instance()
		f.wrap_at = 14
		f.text = stages[i].substr(0,14)
		f.position = labelpos
		f.scale_by = 5
#		var f = Def.LoadFont(font,{
#			text=stages[i],
#			uppercase=true,
#			rect_position=labelpos
#		})
		lvSel.add_child(f)
	GainFocusCommand(pos)

	set_character(charSel)

func GainFocusCommand(p:int):
	for i in range(stgLen):
		var actor = lvSel.get_child(i)
		if i==p:
			actor.modulate = Color.yellow
			#actor.set("custom_colors/font_color",Color.yellow)
		else:
			actor.modulate = Color.white
			#actor.set("custom_colors/font_color",Color.white)
	

# warning-ignore:unused_argument
func _input(event):
# warning-ignore:integer_division
	var jump:int=stgLen/2
	if event.is_action_pressed("ui_accept"):
		var newScreen = Globals.STAGES_REINA[stages[pos]]
		if newScreen != "":
			$Confirm.play()
			get_tree().change_scene(Globals.STAGES_REINA[stages[pos]])
		else:
			$NoWay.play()
		#Globals.change_screen(get_tree(),Globals.STAGES_REINA[stages[pos]])
		return
	elif event.is_action_pressed("ui_cancel"):
		Globals.change_screen(get_tree(),"ScreenTitleMenu")
		return
	
	if event.is_action_pressed("ui_down") and pos<stgLen-2:
		pos+=2
		$Select.play()
	elif event.is_action_pressed("ui_up") and pos>1:
		pos-=2
		$Select.play()
	elif event.is_action_pressed("ui_right") and pos < stgLen-1:
		pos+=1
		$Select.play()
	elif event.is_action_pressed("ui_left") and pos > 0:
		pos-=1
		$Select.play()
		
	if event.is_action_pressed("R1"):
		if charSel<Globals.Characters.LENGTH_CHARACTERS-1:
			set_character(charSel+1)
		else:
			set_character(0)
	elif event.is_action_pressed("L1"):
		if charSel>0:
			set_character(charSel-1)
	GainFocusCommand(pos)

#If Android back button pressed
func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
		Globals.change_screen(get_tree(),"ScreenTitleMenu")
