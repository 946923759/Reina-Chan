extends CanvasLayer
signal cutscene_finished()

"""
This one file is CC-BY-NC-SA 4.0 instead of GPLv3
That means NO COMMERCIAL USE! Contact me for commercial use.
https://creativecommons.org/licenses/by-nc-sa/4.0/
- Amaryllis Works
"""

var time: float = 0.0
var waitForAnim: float = 0.0
onready var TEXT_SPEED: float = max(Globals.OPTIONS['TextSpeed']['value']/2,1)



var curPos: int = -1

"""var message=[
	[OPCODES.PORTRAITS,"Nyto_7","pic_UMP9"],
	[OPCODES.SPEAKER,"UMP9"],
	[OPCODES.MSG,"This is the first string"]
]"""
export(PoolStringArray) var standalone_message
export(bool) var automatically_advance_text = false
var message: Array

onready var PORTRAITMAN:Node2D = $CenterContainer_v2/Mugshots

#var musicToLoad:Array=[]
#var soundsToLoad:Array=[]


onready var text = $CenterContainer_v2/textActor_better
onready var textboxSpr = $CenterContainer_v2/TextboxBack
onready var blinkingCursor = $CenterContainer_v2/Blinky
onready var speakerActor = $CenterContainer_v2/SpeakerActor

var choiceResult:int=-1

func push_back_from_idx_one(arr,arr2): #Arrays are passed by reference so there's no need to return them, but whatever
	for i in range(1,arr2.size()):
		arr.push_back(arr2[i])
	return arr

#This function will load backgrounds and music in advance.
#It will also split the delimiter in advance.
func preparse_string_array(arr:PoolStringArray,delimiter:String="|")->bool:
	var musicToLoad:Array=[]
	var soundsToLoad:Array=[]
	#var backgrounds_to_load:Array=[]
	message = []
	
	var needs_to_add_msgbox = true
	var first_msgbox_position = ""
	
	#Should return false if delimiter is incorrect
	for s in arr:
		var splitString = s.split(delimiter,true) #,true,1
		#This changes the command order, so it probably shouldn't be preprocessed right?
		if splitString[0].begins_with('/'): #Chaosoup's idea, since typing two opcodes every time was getting obnoxious
			message.push_back(['speaker',splitString[0].substr(1)])
			message.push_back(push_back_from_idx_one(['msg'],splitString))
			#var a = ['msg']
			#message.push_back([OPCODES.MSG,splitString[1]])
			continue
		elif s.begins_with("#") or s.begins_with(";"):
			continue
		match splitString[0]:
			#"bg":
			#	if splitString[1] != "black" and splitString[1] != "none" and !(splitString[1] in backgrounds_to_load):
			#		backgrounds_to_load.append(splitString[1])
			"music":
				#message.push_back([OPCODES.MUSIC,splitString[1]])
				if !(splitString[1] in musicToLoad):
					musicToLoad.append(splitString[1])
			"se":
				if !(splitString[1] in soundsToLoad):
					soundsToLoad.append(splitString[1])
			"speaker":
				if splitString.size() < 2:
					splitString=['speaker','']
			"msgbox_add":
				needs_to_add_msgbox = false
			"msgbox":
				if not first_msgbox_position:
					first_msgbox_position = splitString[2]
		message.push_back(splitString)
					
	if needs_to_add_msgbox:
		#print(["msgbox_add",first_msgbox_position,"top"])
		message.insert(0,["msgbox_add",first_msgbox_position,"top"])
	
	
	for m in musicToLoad:
		#print("m "+m)
		var s = Def.Sound({
			File=m,
			name=m.replace("/","$"),
			bus="Music"
		})
		$Music.add_child(s)
	for m in soundsToLoad:
		#It still returns an smSound... The name is not very good
		#The only difference is that sound effects load from the Sounds folder and don't loop
		var s = Def.SoundEffect({
			File=m,
			name=m.replace("/","$"),
			bus="SFX"
		})
		$SoundEffects.add_child(s)
	print(message)
	return true

var msgColumn:int=1
var lastPortraitTable = {}
var ChoiceTable:PoolStringArray = []
var matchedNames = []

onready var tw = $TextboxTween
onready var animPlayer = $CenterContainer_v2/AnimationPlayer
func advance_text()->bool:
	tw.remove_all()
	curPos+=1
# warning-ignore:unused_variable
	var tmp_speaker = "NoSpeaker!!"
# warning-ignore:unused_variable
	var tmp_tn = ""
	var tmp_txt:String=""
	while true:
		if curPos >= message.size():
			print("Fix your code, idiot. You already hit the end.")
			print("curPos: "+String(curPos))
			print("message size: "+String(message.size()))
			return false
		var curMessage = message[curPos]
		
		match curMessage[0]:
			'msg':
				#Do it up here since /setDispChr command might override it.
				#text.visible_characters=0
				if msgColumn < curMessage.size():
					tmp_txt = curMessage[msgColumn]
				elif curMessage.size() > 1:
					#print("msg ")
					tmp_txt= curMessage[1]
				#else:
					
				
				#tw.interpolate_property(text,"bbcode_text","lol",tmp_txt,0,Tween.TRANS_LINEAR,Tween.EASE_IN,waitForAnim)
				#text.bbcode_text = tmp_txt
				text.waitForSetText(tmp_txt,waitForAnim)
				
				if curPos < message.size()-1 and message[curPos+1][0]=='choice':
					#TODO: This is horrible
					ChoiceTable = []
					for i in range(1,message[curPos+1].size()):
						var a = message[curPos+1][i].split("##",true)
						var b = msgColumn-1
						if b<a.size():
							ChoiceTable.push_back(a[b])
						else:
							print("Current language is "+String(b)+", but this choice only had "+String(a.size())+" languages to choose from")
							print(a)
							ChoiceTable.push_back(a[0])
					#ChoiceTable=push_back_from_idx_one([],message[curPos+1])
				break #Stop processing opcodes and wait for user to click
#			'msgbox_transition':
#				#waitForAnim+=$CenterContainer_v2.close()
#				closeTextbox(tw)
#				openTextbox(tw,.3)
#				waitForAnim+=.6
			'msgbox_add':
				var leftSide=true
				var vPosition = -1
				if len(curMessage) > 2:
					match curMessage[2].to_lower():
						"bottom","bot","b":
							vPosition=0
						"middle","mid","m":
							vPosition=1
						"top",'t':
							vPosition=2
				if len(curMessage) > 1:
					leftSide=curMessage[1].to_lower()!="right"
					#print(curMessage[1])
				print("Messagebox add queued: "+String(leftSide)+", "+String(vPosition))
				waitForAnim+=$CenterContainer_v2.add(leftSide, vPosition)
#			'msgbox_remove':
#				waitForAnim+=$CenterContainer_v2.remove()
#				#text.text=""
#				#text.waitForSetText("",.2) #Clear text
#				pass
#			'msgbox_close':
#				if curMessage.size() > 1 and curMessage[1]=="instant":
#					print("Removing tw")
#					#tw.remove(textboxSpr,"interpolate_property")
#					tw.remove_all()
#					closeTextbox(tw,0,0)
#				else:
#					closeTextbox(tw)
#					waitForAnim+=.3
			'msgbox':
				var leftSide=true
				#var vPosition:int = 2
				
				var newPortrait = ""
				var shouldMask = false
				var splits = curMessage[1].split(",",true,1)
				newPortrait = splits[0]
				if len(splits) > 1:
					shouldMask = splits[1].to_lower() == "true"
				
				if len(curMessage) > 3:
					match curMessage[3].to_lower():
						"bottom","bot","b":
							$CenterContainer_v2.lastPosition=0
						"middle","mid","m":
							$CenterContainer_v2.lastPosition=1
						"top",'t':
							$CenterContainer_v2.lastPosition=2
				if len(curMessage) > 2:
					leftSide=curMessage[2].to_lower()!="right"
					#print(curMessage[1])
				#need delay_set_portrait() here...
				#$CenterContainer_v2.de
				waitForAnim+=$CenterContainer_v2.close_and_open2(leftSide, newPortrait, shouldMask)
			'speaker': 
				
				# I really didn't think this one through when I made /close and /open
				# a mini command instead of an opcode
				if waitForAnim>0:
					tw.interpolate_callback(self,.3,"shitty_interpolate_label",curMessage[1])
					#tw.interpolate_property($SpeakerActor,"text","null",tmp_speaker,0,Tween.TRANS_LINEAR,Tween.EASE_IN,.3)
				else:
					speakerActor.text=curMessage[1]
				tmp_speaker=curMessage[1] #Store it for text history
				
			'preload_portraits':
				PORTRAITMAN.preload_portraits(curMessage)
			#'bg':
			#	var transition:String = curMessage[2].to_lower() if curMessage.size() > 2 else ""
			#	backgrounds.setNewBG(curMessage[1].replace("/","$"),transition,waitForAnim)
			'portrait':
				if len(curMessage)>2:
					PORTRAITMAN.delay_set_portrait(curMessage[1],curMessage[2].to_lower()=="true",waitForAnim)
				else:
					PORTRAITMAN.delay_set_portrait(curMessage[1],false,0.3)
#			'emote':
#				var lastUsed = PORTRAITMAN.get_portrait_from_sprite(curMessage[1])
#				if lastUsed != null:
#					lastUsed.cur_expression = int(curMessage[2])
#					lastUsed.update()
#					#print("Set new portrait sprite")
#				else:
#					print("There is no active portrait named "+curMessage[1])
			#This is a NOP since the msg handler checks if there is a choice right after.
			#"But what if I want a choice without any text?"
			#I don't know, fuck you
			'choice', 'nop','label':
				pass
			#OPCODES.JMP:
			#	curPos+=curMessage[1]
			'jmp','condjmp_c':
				#if curMessage[0] == OPCODES.CONDJMP_CHOICE:
				#	print("Processing CONDJUMP... cRes is "+String(choiceResult)+", jump if "+String(curMessage[2]))
				#else:
				#	print("processing LONGJUMP")
				if curMessage[0] == 'jmp' or int(curMessage[2])==choiceResult:
					#print(curMessage)
					var jumped:bool=false
					for i in range(curPos,message.size()):
						if message[i][0]=='label' and curMessage[1]==message[i][1]:
							curPos=i
							jumped=true
							break
					if !jumped:
						for i in range(0,curPos):
							if message[i][0]=='label' and curMessage[1]==message[i][1]:
								curPos=i
								jumped=true
					if !jumped:
						printerr("The label '"+curMessage[1]+"' was not found!")
				#Reset here?
				choiceResult=-1
#			'music':
#				var m = $Music.get_node_or_null(curMessage[1].replace("/","$"))
#				if is_instance_valid(lastMusic):
#					lastMusic.stop()
#				if m!=null:
#					print("Playing "+m.name)
#					print(m.stream)
#					m.play()
#					lastMusic=m
#				else:
#					printerr("FIX YOUR MUSIC NAMES!! DON'T USE SPECIAL CHARACTERS! "+curMessage[1])
			'se':
				var se = $SoundEffects.get_node_or_null(curMessage[1].replace("/","$"))
				if se!=null:
					se.play()
#			'stopmusic':
#				if is_instance_valid(lastMusic):
#					lastMusic.fade_music(float(curMessage[1]))
#			"shake_camera":
#				var howMuch:float = float(curMessage[1]) if len(curMessage) > 1 else 3.0
#				backgrounds.shakeCamera(howMuch)
			_:
				printerr("Unknown opcode encountered: "+curMessage[0]+". It will be ignored and skipped.")
		# msg opcode will break the loop, but for everything else,
		# keep incrementing the instruction position and processing
		# new instructions.
		curPos+=1
	
	
	#var TEXT_SPEED=float(Globals['OPTIONS']['textSpeed']['value'])
	#print(TEXT_SPEED)
	if TEXT_SPEED<100:
		#print(1/TEXT_SPEED*(text.text.length()-text.visible_characters))
		tw.interpolate_property(text,"visible_characters",0,tmp_txt.length(),
			1/TEXT_SPEED*(tmp_txt.length()-0),
			Tween.TRANS_LINEAR,
			Tween.EASE_IN,
			waitForAnim
		)
		print("[CutsceneMMZ] Should tween to "+String(tmp_txt.length())+" chars")
		tw.interpolate_callback(blinkingCursor,waitForAnim+1/TEXT_SPEED*tmp_txt.length(),"show")
	else: #Fake tween that just waits for waitForAnim
		tw.interpolate_property(text,"visible_characters",text.visible_characters,text.text.length(),
			0,
			Tween.TRANS_LINEAR,
			Tween.EASE_IN,
			waitForAnim
		)
	
	print("Tweening... waitForAnim is "+String(waitForAnim))
	tw.start()
	waitForAnim=0
	#If there was any processing done at all, this should be true
	return true


func closeTextbox(t:Tween,delay:float=0,animTime:float=.3):
	$CenterContainer_v2.close()
	return
	#t.append(textboxSpr,'scale:y',0,.3).set_trans(Tween.TRANS_QUAD)
	#print("Closing textbox with delay of "+String(delay))
# warning-ignore:unreachable_code
	t.interpolate_property(textboxSpr,"rect_scale:y",1,0,animTime,Tween.TRANS_QUAD,Tween.EASE_IN,delay)
	t.interpolate_property(speakerActor,"rect_scale:y",1,0,animTime,Tween.TRANS_QUAD,Tween.EASE_IN,delay)
	t.interpolate_property(speakerActor,"modulate:a",1,0,animTime,Tween.TRANS_QUAD,Tween.EASE_IN,delay)
	

# warning-ignore:unused_argument
func openTextbox(t:Tween,_delay:float=0):
	$CenterContainer_v2.open()
	return
	#print("Opening textbox with delay of "+String(delay))
	#t.interpolate_property($CenterContainer_v2/TextboxBack,"region_rect:size:x",64,240,.3)

func shitty_interpolate_label(s:String):
	#print("Now I set speaker to"+s+"!!")
	speakerActor.text=s

func update_portrait_positions():
	var SCREEN_CENTER_X = get_viewport().get_visible_rect().size.x/2
	for n in $Portraits.get_children():
		n.update_portrait_positions(float(SCREEN_CENTER_X))
		
func set_rect_size():
	for child in $Backgrounds.get_children():
		child.set_rect_size()

func _ready():
	$PressStartToSkip.text=INITrans.GetString("Cutscene","PRESS START TO SKIP")
	print("Text speed is "+String(TEXT_SPEED))
	set_process(false)
	#text = $textActor_better
	#text.visible_characters=0


	
	#if len(standalone_message)!=0:
	#	init_(standalone_message,null)
	
	#for debugging
#	init_([
#		'portrait|Alchemist',
#		'msg|Hello world.',
#		'msg|This is a test cutscene.',
#		"msgbox_transition",
#		"msg|This is very long text. What is a T-Doll? A miserable little pile of nuts and bolts! But enough talk, have at you!",
#		"msgbox_remove",
#		"portrait|UMP9",
#		"msgbox_add|right",
#		"msg|Hello world! From UMP9!"
#	],
#	null)
	#openTextbox($TextboxTween)
	#$CenterContainer_v2.add(true)



func init_(message_:PoolStringArray,delim="|",msgColumn_:int=1):
	assert(message_.size()>0,"You can't pass an empty message to a cutscene!!!")
		
	#var t := get_tree().create_tween()
	#t.set_pause_mode(SceneTreeTween.TWEEN_PAUSE_PROCESS)
	preparse_string_array(message_,delim)
	#self.message=message
	self.msgColumn=msgColumn_
	#parse_string_array(message,delim,msgColumn)
	text.bbcode_text=""
	text.visible_characters=0
	curPos = -1
	waitForAnim=0
	text.waitTime = 0.0
	tw.stop_all()
	blinkingCursor.hide()
	$CenterContainer_v2/AnimationPlayer.stop(true)
	advance_text()
	set_process(true)

func end_cutscene():
	print("Hit the end. Now closing the textbox...")
	$CenterContainer_v2.remove()
	yield($CenterContainer_v2/AnimationPlayer,"animation_finished")
	set_process(false)
	emit_signal("cutscene_finished")

# Honestly, this is a mess. When it was in lua the input handling and the VN processing
# wasn't coupled together, instead vntext:advance() would be called and if it returned
# false it meant there was no more text.
var manualTriggerForward=false

var isHistoryBeingShown=false
var isWaitingForChoice=false

func _process(_delta):
	
	if isHistoryBeingShown:
		return
	if Input.is_action_just_pressed("ui_pause"):
		end_cutscene()
	elif Input.is_action_just_pressed("DebugButton1"):
		get_tree().reload_current_scene()
	
	if isWaitingForChoice:
		if Input.is_action_just_pressed("ui_up"):
			$Choices.input_up()
		elif Input.is_action_just_pressed("ui_down"):
			$Choices.input_down()
		elif Input.is_action_just_pressed("ui_accept") and $Choices.selection!=-1:
			choiceResult=$Choices.selection+1
			$Choices.visible=false
			ChoiceTable=[]
			advance_text()
			isWaitingForChoice=false
			#$Choices.input
		return
	
	var forward = Input.is_action_just_pressed("ui_accept") or manualTriggerForward
	if animPlayer.is_playing():
		forward=false
	if text.visible_characters >= text.text.length() or text.visible_characters < 0:
		#blinkingCursor.show()
		if ChoiceTable.size()>0:
			$Choices.setChoices(ChoiceTable)
			$Choices.visible=true
			isWaitingForChoice=true
		elif forward:
			blinkingCursor.hide()
			print("advancing")
			if curPos >= message.size() or !advance_text():
				end_cutscene()
	else:
		if forward:
			tw.remove_all()
			#$CenterContainer_v2.skipToOpen() #Does not work
			text.waitTime = 0.0
			text.visible_characters = -1
			blinkingCursor.show()
		else:
			if Input.is_action_pressed("ui_cancel"):
				tw.playback_speed=2.0
			else:
				tw.playback_speed=1.0
	manualTriggerForward=false
	
#Fucking piece of shit game engine
#func _input(event):
#	if isWaitingForChoice:
#		if event is InputEventMouseMotion:
#			$Choices.input_cursor(event.position)
#		elif (event is InputEventMouseButton and event.is_pressed() and event.button_index == BUTTON_LEFT) or (
#			event is InputEventScreenTouch and event.is_pressed()
#		):
#			if $Choices.input_cursor(event.position,true):
#				choiceResult=$Choices.selection+1
#				$Choices.visible=false
#				ChoiceTable=[]
#				advance_text()
#				isWaitingForChoice=false
#		return
#
#
#	if (event is InputEventMouseButton and event.is_pressed() and event.button_index == BUTTON_LEFT) or (
#		event is InputEventScreenTouch and event.is_pressed()
#	):
#		manualTriggerForward=true
