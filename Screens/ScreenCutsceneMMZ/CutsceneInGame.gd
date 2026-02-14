extends CanvasLayer
signal cutscene_finished()

"""
This one file is CC-BY-NC-SA 4.0 instead of GPLv3
That means NO COMMERCIAL USE! Contact me for commercial use.
https://creativecommons.org/licenses/by-nc-sa/4.0/
- Amaryllis Works
"""

enum Overlay {
	NONE = 0,
	OPTIONS,
	HISTORY,
	CHOICE,
	VAR_DEBUGGER, 
	OPCODE_DEBUGGER,
	UI_HIDDEN,
	WAITING_FOR_TWEEN,
	WAITING_FOR_BROADCAST
}

var time: float = 0.0
var waitForAnim: float = 0.0
onready var TEXT_SPEED: float = max(Globals.OPTIONS['TextSpeed']['value']/2,1)

var otherScreenIsHandlingInput:int = Overlay.NONE
var manualTriggerForward=false
var isWaitingForChoice=false
var curPos: int = -1
var msgColumn:int = 1
var ChoiceTable:PoolStringArray = []
var choiceResult:int = -1
var cutsceneVars:Dictionary = {}

export(PoolStringArray) var standalone_message
export(bool) var automatically_advance_text = false
var message: Array
var tw:SceneTreeTween
var calling_entity:Node2D

#onready var PORTRAITMAN:Node2D = $CenterContainer_v2/MugshotsV2
onready var animPlayer = $CenterContainer_v2/AnimationPlayer
onready var text = $CenterContainer_v2/textActor_better
onready var textboxSpr = $CenterContainer_v2/TextboxBack
onready var blinkingCursor = $CenterContainer_v2/Blinky
onready var speakerActor = $CenterContainer_v2/SpeakerActor


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
				
				var hasVarCursor = tmp_txt.find("%")
				while hasVarCursor != -1 and hasVarCursor < tmp_txt.length()-1:
					var endTagPos:int = -1
					for jjjj in range(hasVarCursor+1,tmp_txt.length()):
						if tmp_txt[jjjj]==" ": #This also means no %% necessary like renpy
							hasVarCursor=tmp_txt.find("%",jjjj+1)
							#print("encountered space while scanning for var end tag, ignoring and moving on")
							#print("left to scan: ")
							#print(tmp_txt.substr(hasVarCursor))
							break
						elif tmp_txt[jjjj]=="%":
							endTagPos = jjjj
							break
						elif jjjj == tmp_txt.length()-1:
							#print("hit EOL while checking for variable end tag, ignoring this line")
							hasVarCursor=tmp_txt.length()
							break
					if endTagPos != -1:
						#print(endTag-hasVar)
						var varName = tmp_txt.substr(hasVarCursor+1,endTagPos-hasVarCursor-1)
						#print("Got story var "+varName)
						if cutsceneVars.has(varName):
							tmp_txt = tmp_txt.substr(0,hasVarCursor) + String(cutsceneVars[varName]) + tmp_txt.substr(endTagPos+1)
							#print("Replaced text to "+tmp_txt)
							hasVarCursor = tmp_txt.find("%")
							pass
						else:
							printerr("Variable "+varName+" used in script, but not declared yet. Ignoring.")
							break
							
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
			'var':
				var varName:String = curMessage[1]
				var varExpression:String = curMessage[2].to_lower()

				if varExpression=="true":
					cutsceneVars[varName]=1
				elif varExpression=="false":
					cutsceneVars[varName]=0
				else:
					match varExpression[0]:
						
						'"':
							var cmd_end = varExpression.rfind("\"");
							if cmd_end>0:
								cutsceneVars[varName] = curMessage[2].substr(1,len(curMessage[2])-2)
							else:
								printerr("String is malformed in var command, missing end")
						'&':
							var bitflag = int(varExpression.substr(1))
							if !(varName in cutsceneVars):
								cutsceneVars[varName] = (1<<bitflag)
							elif typeof(cutsceneVars[varName])==TYPE_INT:
								cutsceneVars[varName] = cutsceneVars[varName] | (1<<bitflag)
							else:
								printerr("Tried to set a bitflag, but variable is not an integer.")
						'~':
							var bitflag = int(varExpression.substr(1))
							if !(varName in cutsceneVars):
								cutsceneVars[varName] = 0 #If the variable doesn't exist, it's zero...
							elif typeof(cutsceneVars[varName])==TYPE_INT:
								cutsceneVars[varName] = cutsceneVars[varName] & ~(1<<bitflag)
							else:
								printerr("Tried to set a bitflag, but variable is not an integer.")
						_:
							if varExpression.is_valid_integer(): #Likely assignment expression
								cutsceneVars[varName]=int(varExpression)
							elif not varName in cutsceneVars:
								printerr("Failed to deduce type for variable and this variable doesn't exist yet, nothing can be done here.")
								printerr("(Hint: you might want to assign to this variable first)")
							else: #Not sure what this is, attempt complex expression parsing
								var expression:Expression = Expression.new()
								expression.parse(varExpression,[varName])
								#Execute the expression, so Vector2(1,2) would return Vector2(1,2), etc
								var result = expression.execute([cutsceneVars[varName]])
								if expression.has_execute_failed():
									printerr("Failed to deduce type for variable "+varExpression+" and failed to parse this as an expression. "+expression.get_error_text())
								else:
									cutsceneVars[varName]=result
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
			'await_call':
				otherScreenIsHandlingInput = Overlay.WAITING_FOR_BROADCAST
				var n:Node
				if curMessage[1]=="self":
					n = calling_entity
				else:
					n = calling_entity.get_node(curMessage[1])
				n.connect("finished",self,"end_await")
				n.call(curMessage[2])
				set_process(false)
				return true
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



func init_(message_:PoolStringArray, delim="|", msgColumn_:int=1, calling_entity_:Node2D = null):
	assert(message_.size()>0,"You can't pass an empty message to a cutscene!!!")
		
	#var t := create_tween()
	#t.set_pause_mode(SceneTreeTween.TWEEN_PAUSE_PROCESS)
	preparse_string_array(message_, delim)
	#self.message=message
	self.msgColumn=msgColumn_
	self.calling_entity = calling_entity_
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

func init_by_msg_id(message_id:String):
	init_(
		Globals.get_stage_cutscene(message_id),
		"\t",
		Globals.stage_cutscene_data['msgColumn']
	)

func end_cutscene():
	print("[CutsceneMMZ] Hit the end. Now closing the textbox...")
	$CenterContainer_v2.remove()
	yield($CenterContainer_v2/AnimationPlayer,"animation_finished")
	set_process(false)
	visible = false
	emit_signal("cutscene_finished")

func _process(_delta):
	
	if otherScreenIsHandlingInput==Overlay.WAITING_FOR_TWEEN:
		if calling_entity:
			if calling_entity.tweening_state == calling_entity.TWEEN_STATUS.TWEEN_FINISHED:
				otherScreenIsHandlingInput = Overlay.NONE
				advance_text()
		else:
			otherScreenIsHandlingInput = Overlay.NONE
			advance_text()
		return
	#Or you can just turn off processing...
	#elif otherScreenIsHandlingInput==Overlay.WAITING_FOR_BROADCAST:
	#	return
	elif otherScreenIsHandlingInput>0:
		return
	
	
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

func end_await():
	set_process(true)
	otherScreenIsHandlingInput=0
	advance_text()
