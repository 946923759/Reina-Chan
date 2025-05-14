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
var msgColumn:int=1
var ChoiceTable:PoolStringArray = []

export(PoolStringArray) var standalone_message
export(bool) var automatically_advance_text = false
var message: Array
var tw:SceneTreeTween

#onready var PORTRAITMAN:Node2D = $CenterContainer_v2/MugshotsV2
onready var animPlayer = $CenterContainer_v2/AnimationPlayer
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

func advance_text()->bool:
	tw = create_tween()
	curPos+=1
# warning-ignore:unused_variable
	var tmp_txt:String=""
	while true:
		if curPos >= message.size():
			tw.kill() #Shut up the error message about empty tweens
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
				tw.tween_callback(text,"set_bbcode",[tmp_txt]).set_delay(waitForAnim)
				
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
			'msgbox_add':
				var leftSide=true
				var vPosition = -1
				
				
				var newPortrait = ""
				var shouldMask = false
				var splits = curMessage[1].split(",",true,1)
				newPortrait = splits[0]
				if len(splits) > 1:
					shouldMask = splits[1].to_lower() == "true"
				
				if len(curMessage) > 3:
					match curMessage[3].to_lower():
						"bottom","bot","b":
							vPosition=0
						"middle","mid","m":
							vPosition=1
						"top",'t':
							vPosition=2
				if len(curMessage) > 2:
					leftSide=curMessage[2].to_lower()!="right"
					#print(curMessage[1])
				print("Messagebox add queued: "+String(leftSide)+", "+String(vPosition))
				$CenterContainer_v2/MugshotsV2.set_portrait(newPortrait, shouldMask)
				waitForAnim += $CenterContainer_v2.add(leftSide, vPosition)

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
				waitForAnim += $CenterContainer_v2.close_and_open2(leftSide, newPortrait, shouldMask)
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
			'choice', 'nop','label','speaker':
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
				printerr("[CutsceneMMZ] Unknown opcode encountered: "+curMessage[0]+". It will be ignored and skipped.")
		# msg opcode will break the loop, but for everything else,
		# keep incrementing the instruction position and processing
		# new instructions.
		curPos+=1
	
	
	#var TEXT_SPEED=float(Globals['OPTIONS']['textSpeed']['value'])
	#print(TEXT_SPEED)
	if TEXT_SPEED<100:
		tw.tween_property(text,"visible_characters",tmp_txt.length(),
			1/TEXT_SPEED*tmp_txt.length()
			#1
		).from(0) #.set_delay(waitForAnim)
		print("[CutsceneMMZ] Should tween to "+String(tmp_txt.length())+" chars. Speed=",1/TEXT_SPEED*(text.text.length()-text.visible_characters))
		tw.tween_callback(blinkingCursor,"show")
	else: #Fake tween that just waits for waitForAnim
		tw.tween_property(text,"visible_characters",text.text.length(),0).set_delay(waitForAnim)
	
	print("[CutsceneMMZ] Tweening... waitForAnim is "+String(waitForAnim))
	waitForAnim=0
	#If there was any processing done at all, this should be true
	return true

func _ready():
	$PressStartToSkip.text = INITrans.GetString("Cutscene","PRESS START TO SKIP")
	#print("Text speed is "+String(TEXT_SPEED))
	set_process(false)
	visible = false
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
	blinkingCursor.hide()
	$CenterContainer_v2/AnimationPlayer.stop(true)
	visible = true
	advance_text()
	set_process(true)

func end_cutscene():
	print("[CutsceneMMZ] Hit the end. Now closing the textbox...")
	$CenterContainer_v2.remove()
	yield($CenterContainer_v2/AnimationPlayer,"animation_finished")
	set_process(false)
	visible = false
	emit_signal("cutscene_finished")

# Honestly, this is a mess. When it was in lua the input handling and the VN processing
# wasn't coupled together, instead vntext:advance() would be called and if it returned
# false it meant there was no more text.
var manualTriggerForward=false

var isWaitingForChoice=false

func _process(_delta):
	
	if Input.is_action_just_pressed("ui_pause"):
		end_cutscene()
	
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
			tw.pause()
			tw.custom_step(10.0) #Seek forward 10 seconds (usually past the end)
			text.visible_characters = text.text.length()
			blinkingCursor.show()
		else:
			if is_instance_valid(tw) and tw.is_running():
				if Input.is_action_pressed("ui_cancel"):
					tw.set_speed_scale(2.0)
				else:
					tw.set_speed_scale(1.0)
	manualTriggerForward=false
