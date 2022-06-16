extends CanvasLayer

"""
This one file is CC-BY-NC-SA 4.0 instead of GPLv3
That means NO COMMERCIAL USE! Contact me for commercial use.
https://creativecommons.org/licenses/by-nc-sa/4.0/
- Amaryllis Works
"""

var time: float = 0.0
var waitForAnim: float = 0.0
onready var TEXT_SPEED: float = max(Globals.OPTIONS['TextSpeed']['value']/2,1)

var parent_node


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

var musicToLoad:Array=[]
var soundsToLoad:Array=[]


onready var text = $CenterContainer_v2/textActor_better
onready var textboxSpr = $CenterContainer_v2/TextboxBack
onready var speakerActor = $CenterContainer_v2/SpeakerActor

var choiceResult:int=-1

func push_back_from_idx_one(arr,arr2):
	for i in range(1,arr2.size()):
		arr.push_back(arr2[i])
	return arr

var msgColumn:int=1
var lastPortraitTable = {}
var ChoiceTable:PoolStringArray = []
var matchedNames = []

onready var tw = $TextboxTween
func advance_text()->bool:
	curPos+=1
	var tmp_speaker = "NoSpeaker!!"
	var tmp_tn = ""
	while true:
		if curPos >= message.size():
			print("Fix your code, idiot. You already hit the end.")
			print("curPos: "+String(curPos))
			print("message size: "+String(message.size()))
			return false
		var curMessage = message[curPos]
		
		match curMessage[0]:
			#'tn':
			#	if msgColumn < curMessage.size():
			#		tmp_tn=curMessage[msgColumn]
			'msg':
				#Do it up here since /setDispChr command might override it.
				text.visible_characters=0
				var tmp_txt:String
				if msgColumn < curMessage.size():
					tmp_txt = curMessage[msgColumn]
				elif curMessage.size() > 1:
					#print("msg ")
					tmp_txt= curMessage[1]
				#else:
					
				
					
				text.bbcode_text = tmp_txt
				
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
			#Compatibility opcode for Girls' Frontline
			'msgbox_transition':
				closeTextbox(tw)
				openTextbox(tw,.3)
				waitForAnim+=.6
			'msgbox_close':
				if curMessage.size() > 1 and curMessage[1]=="instant":
					print("Removing tw")
					#tw.remove(textboxSpr,"interpolate_property")
					tw.remove_all()
					closeTextbox(tw,0,0)
				else:
					closeTextbox(tw)
					waitForAnim+=.3
			'msgbox_open':
				openTextbox(tw)
				waitForAnim+=.3
#			'set_fs': #Should this close the textbox too?
#				if curMessage[1].to_lower()=="true":
#					tw.interpolate_property(fsContainer,"modulate:a",null,1,.3,Tween.TRANS_QUAD,Tween.EASE_IN,waitForAnim)
#					isFullscreenMessageBox=true
#					fsText.text=""
#					fsContainer.visible=true
#					#shouldTextBoxBeVisible=false
#				else:
#					tw.interpolate_property(fsContainer,"modulate:a",null,1,.3,Tween.TRANS_QUAD,Tween.EASE_IN,waitForAnim)
#					isFullscreenMessageBox=false
#					fsContainer.visible=false
					#shouldTextBoxBeVisible=true
				
			'match_names':
				matchedNames=push_back_from_idx_one([],curMessage)
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
				PORTRAITMAN.set_portrait(curMessage[1],curMessage[2])
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
		curPos+=1
	
	#WHAT COULD POSSIBLY GO WRONG
	#textHistory.push_back([speakerActor.text,text.text])
	$TN_Actor.visible=(tmp_tn!="")
	if tmp_tn!="":
		$TN_Actor/TranslationNote.text=tmp_tn
		#print($TN_Actor/TranslationNote.has_focus())
	var TEXT_SPEED=float(Globals['OPTIONS']['textSpeed']['value'])
	#print(TEXT_SPEED)
	if TEXT_SPEED<100:
		#print(1/TEXT_SPEED*(text.text.length()-text.visible_characters))
		tw.interpolate_property(text,"visible_characters",text.visible_characters,text.text.length(),
			1/TEXT_SPEED*(text.text.length()-text.visible_characters),
			Tween.TRANS_LINEAR,
			Tween.EASE_IN,
			waitForAnim
		)
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
	return
	#t.append(textboxSpr,'scale:y',0,.3).set_trans(Tween.TRANS_QUAD)
	#print("Closing textbox with delay of "+String(delay))
	t.interpolate_property(textboxSpr,"rect_scale:y",1,0,animTime,Tween.TRANS_QUAD,Tween.EASE_IN,delay)
	t.interpolate_property(speakerActor,"rect_scale:y",1,0,animTime,Tween.TRANS_QUAD,Tween.EASE_IN,delay)
	t.interpolate_property(speakerActor,"modulate:a",1,0,animTime,Tween.TRANS_QUAD,Tween.EASE_IN,delay)
	

func openTextbox(t:Tween,delay:float=0):
	return
	#print("Opening textbox with delay of "+String(delay))
	t.interpolate_property(textboxSpr,"rect_scale:y",0,1,.3,Tween.TRANS_QUAD,Tween.EASE_OUT,delay)
	t.interpolate_property(speakerActor,"rect_scale:y",0,1,.3,Tween.TRANS_QUAD,Tween.EASE_OUT,delay)
	t.interpolate_property(speakerActor,"modulate:a",0,1,.3,Tween.TRANS_QUAD,Tween.EASE_OUT,delay)
	

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

	#for debugging
#	init_([
#		'speaker speaker name',
#		'portrait pic_MAC10|Nyto_7',
#		"msg test message 1",
#		"msg test message 2"
#	],
#	null,
#	true)
	
	if len(standalone_message)!=0:
		init_(standalone_message,null)



func init_(message, parent,delim="|",msgColumn:int=1):
	if parent:
		parent_node = parent
		
	#var t := TweenSequence.new(get_tree())
	#t._tween.pause_mode = Node.PAUSE_MODE_PROCESS
	
	self.message=message
	self.msgColumn=msgColumn
	#parse_string_array(message,delim,msgColumn)
	
	advance_text()
	set_process(true)

func end_cutscene():
	print("Hit the end. Now I will kill myself!")
	set_process(false)
	#for p in portraits:
	#	if p.is_active:
	#		p.stop()
	#https://github.com/godot-extended-libraries/godot-next/pull/50
	var seq := TweenSequence.new(get_tree())
	seq._tween.pause_mode = Node.PAUSE_MODE_PROCESS
# warning-ignore:return_value_discarded
	seq.append(textboxSpr,'rect_scale:y',0,.5).set_trans(Tween.TRANS_QUAD)
	seq.parallel().append(text,'modulate:a',0,.3)
	seq.parallel().append(speakerActor,'modulate:a',0,.3)
	#seq.parallel().append($SpeakerActor,'position:y',600,.3)
	seq.parallel().append($dim,'color:a',0,.5).set_trans(Tween.TRANS_QUAD)
	#seq.parallel().append($PressStartToSkip,'rect_position:x',-$PressStartToSkip.rect_size.x,.5).set_trans(Tween.TRANS_QUAD)
	seq.parallel().append($PressStartToSkip,'modulate:a',0,.5)
# warning-ignore:return_value_discarded
	seq.connect("finished",self,"end_cutscene_2")
	#seq.tween_callback()
	#.from_current()
	#queue_free()

# Honestly, this is a mess. When it was in lua the input handling and the VN processing
# wasn't coupled together, instead vntext:advance() would be called and if it returned
# false it meant there was no more text.
var manualTriggerForward=false

var isHistoryBeingShown=false
var isWaitingForChoice=false

func _process(delta):
	
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
		elif Input.is_action_just_pressed("ui_select") and $Choices.selection!=-1:
			choiceResult=$Choices.selection+1
			$Choices.visible=false
			ChoiceTable=[]
			advance_text()
			isWaitingForChoice=false
			#$Choices.input
		return
	
	var forward = Input.is_action_just_pressed("ui_select") or manualTriggerForward
	if text.visible_characters >= text.text.length():
		if ChoiceTable.size()>0:
			$Choices.setChoices(ChoiceTable)
			$Choices.visible=true
			isWaitingForChoice=true
		elif forward:
			print("advancing")
			if curPos >= message.size() or !advance_text():
				end_cutscene()
	else:
		if forward:
			tw.stop_all()
			textboxSpr.rect_scale.y=1
			speakerActor.rect_scale.y=1
			speakerActor.modulate.a=1
			text.visible_characters = text.text.length()
		else:
			if Input.is_action_pressed("ui_cancel"):
				tw.playback_speed=2.0
			else:
				tw.playback_speed=1.0
	manualTriggerForward=false
	
#Fucking piece of shit game engine
func _input(event):
	if isWaitingForChoice:
		if event is InputEventMouseMotion:
			$Choices.input_cursor(event.position)
		elif (event is InputEventMouseButton and event.is_pressed() and event.button_index == BUTTON_LEFT) or (
			event is InputEventScreenTouch and event.is_pressed()
		):
			if $Choices.input_cursor(event.position,true):
				choiceResult=$Choices.selection+1
				$Choices.visible=false
				ChoiceTable=[]
				advance_text()
				isWaitingForChoice=false
		return
			
	
	if (event is InputEventMouseButton and event.is_pressed() and event.button_index == BUTTON_LEFT) or (
		event is InputEventScreenTouch and event.is_pressed()
	):
		manualTriggerForward=true

signal cutscene_finished()
func end_cutscene_2():
	if parent_node:
		get_tree().paused = false
	else:
		print("No parent node...")
	emit_signal("cutscene_finished")
	queue_free()
