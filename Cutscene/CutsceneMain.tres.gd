extends CanvasLayer

"""
This one file is CC-BY-NC-SA 4.0 instead of GPLv3
That means NO COMMERCIAL USE! Contact me for commercial use.
https://creativecommons.org/licenses/by-nc-sa/4.0/
- Amaryllis Works
"""

var text
var time: float = 0.0
var waitForAnim: float = 0.0
onready var TEXT_SPEED: float = max(Globals.OPTIONS['TextSpeed']['value']/2,1)

var parent_node
var backgrounds:Node2D

enum OPCODES {
	MSG, 
	PORTRAITS, 
	PRELOAD_PORTRAITS, 
	SPEAKER, 
	BG, 
	MATCH_NAMES, 
	MSGBOX_TRANSITION,
	#REWRITE_HISTORY #Edit the history! lol
	CONDJMP, #Oh no
	JMP_NOT_EQUAL_LANG,
	JMP_EQUAL_LANG,
	JMP,
	#NOP
	}

var curPos: int = -1

"""var message=[
	[OPCODES.PORTRAITS,"Nyto_7","pic_UMP9"],
	[OPCODES.SPEAKER,"UMP9"],
	[OPCODES.MSG,"This is the first string"]
]"""
export(PoolStringArray) var standalone_message
export(PoolStringArray) var backgrounds_to_load
export(bool) var automatically_advance_text = false
export(bool) var dim_the_background_if_standalone = true
var message: Array

var portraits:Array=[]

#Array of 2D arrays
var textHistory:Array=[]
onready var historyActor=$CutsceneHistory

func push_back_from_idx_one(arr,arr2):
	for i in range(1,arr2.size()):
		arr.push_back(arr2[i])
	return arr

#What an abomination of a function
func parse_string_array(arr,delimiter:String="|",msgColumn:int=1):
	message = []
	for s in arr:
		var splitString = s.split(delimiter) #,true,1
		match splitString[0]:
			'msg':
				if msgColumn > splitString.size()-1:
					print("Hey moron, you're missing the translation for this line: "+String(splitString))
					message.push_back([OPCODES.MSG,splitString[1]])
				else:
					message.push_back([OPCODES.MSG,splitString[msgColumn]])
			'speaker':
				if splitString.size()==1:
					message.push_back([OPCODES.SPEAKER,""])
				else:
					message.push_back(push_back_from_idx_one([OPCODES.SPEAKER],splitString))
			"portrait":
				var pOpcode = [OPCODES.PORTRAITS]
				if splitString.size()>1:
					#var params = splitString[1].split("|")
					#"portraits|ump9,false,0|Nyto_7
					for i in range(1,splitString.size()):
						var p = splitString[i]
						if ',' in p:
							var pStructStr = p.split(',')
							assert(pStructStr.size()<=3, "Malformed portrait command. Did you mix up commas and pipes? "+String(pStructStr))
							pOpcode.push_back([pStructStr[0],pStructStr[1].to_lower()=="true",int(pStructStr[2])])
						else:
							pOpcode.push_back(p)
				#print(pOpcode)
				message.push_back(pOpcode)
			"preload_portraits":
				var newCmd=[OPCODES.PRELOAD_PORTRAITS]
				message.push_back(push_back_from_idx_one(newCmd,splitString))
				#var params = splitString[1].split("|")
				#for i in range(1,splitString.size()):
				#	newCmd.push_back(splitString[i])
				#message.push_back(newCmd)
			"bg":
				message.push_back([OPCODES.BG,int(splitString[1])])
			"matchnames":
				var data = [] 
				push_back_from_idx_one(data,splitString)
				#var params = splitString[1].split("|")
				for i in range(1,splitString.size()):
					data.push_back(splitString[i])
				message.push_back([OPCODES.MATCH_NAMES,data])
			"nop": # "no-operation"
				pass
			"msgboxTransition":
				message.push_back([OPCODES.MSGBOX_TRANSITION])
			_:
				printerr("Unknown command:"+splitString[0])

func get_portrait_from_sprite(spr):
	for p in portraits:
		if p.lastLoaded==spr:
			return p
	#printerr("Tried getting a portrait "+spr+" that doesn't exist")
	return null
	
func get_portrait_at_idx(idx):
	for p in portraits:
		if p.idx==idx:
			return p
	return null


var lastPortraitTable = {}
var matchedNames = []
onready var tw = $TextboxTween
func advance_text()->bool:
	curPos+=1
	var tmp_speaker = "NoSpeaker!!"
	while true:
		if curPos >= message.size():
			print("Fix your code, idiot. You already hit the end.")
			print("curPos: "+String(curPos))
			print("message size: "+String(message.size()))
			return false
		var curMessage = message[curPos]
		
		match curMessage[0]:
			OPCODES.MSG:
				var tmp_txt = curMessage[1]
				while tmp_txt.begins_with("/"):
					if tmp_txt.begins_with("/hl["):
						var cmd_end = tmp_txt.find("]", 4);
						#print("end bracket "+String(cmd_end))
						if cmd_end==-1:
							printerr("Bad hl command!")
						else:
							var val = int(tmp_txt.substr(4,cmd_end-4))
							for p in portraits:
								if p.idx==val:
									p.undim()
									p.z_index = 0
								elif p.is_active:
									p.dim()
									p.z_index = -1
							#print("Highlighting at idx "+String(val))
							tmp_txt=tmp_txt.substr(cmd_end+1,len(tmp_txt))
							#print(tmp_txt)
					elif tmp_txt.begins_with("/dim["):
						var cmd_end = tmp_txt.find("]", 5);
						if cmd_end==-1:
							printerr("Bad dim command!")
						else:
							var val = int(tmp_txt.substr(4,cmd_end-4))
							for p in portraits:
								if p.idx==val:
									p.dim()
									break
							#print("Highlighting at idx "+String(val))
							tmp_txt=tmp_txt.substr(cmd_end+1,len(tmp_txt))
					elif tmp_txt.begins_with("/close"):
						closeTextbox(tw,waitForAnim)
						waitForAnim+=.3
						tmp_txt=tmp_txt.substr(6,len(tmp_txt))
					elif tmp_txt.begins_with("/open"):
						openTextbox(tw,waitForAnim)
						waitForAnim+=.3
						tmp_txt=tmp_txt.substr(5,len(tmp_txt))
					else:
						printerr("Unknown command used, giving up: "+tmp_txt)
						break
					
				text.visible_characters=0
				text.bbcode_text = tmp_txt
				
				
				break
			#Compatibility opcode for Girls' Frontline
			OPCODES.MSGBOX_TRANSITION:
				closeTextbox(tw)
				openTextbox(tw,.3)
				waitForAnim+=.6
			OPCODES.MATCH_NAMES:
				matchedNames=curMessage[1]
			OPCODES.SPEAKER: 
				# I really didn't think this one through when I made /close and /open
				# a mini command instead of an opcode
				if waitForAnim>0:
					tw.interpolate_callback(self,.3,"shitty_interpolate_label",curMessage[1])
					#tw.interpolate_property($SpeakerActor,"text","null",tmp_speaker,0,Tween.TRANS_LINEAR,Tween.EASE_IN,.3)
				else:
					$SpeakerActor.text=curMessage[1]
				tmp_speaker=curMessage[1]
				if len(matchedNames) > 1:
					#print(matchedNames)
					for i in range(len(matchedNames)):
						if matchedNames[i]==curMessage[1]:
							print("Matched portrait "+curMessage[1]+" at idx "+String(i))
							for p in portraits:
								if p.idx==i:
									p.undim()
									p.z_index = 0
								elif p.is_active:
									p.dim()
									p.z_index = -1
							break
						#print("|"+matchedNames[i]+"| != |"+curMessage[1]+"|")
					#print("Couldn't match "+curMessage[1]+ " in "+String(matchedNames))
			OPCODES.PRELOAD_PORTRAITS:
				#TODO: Change to a portrait pooling class
				#TODO: Do not preload until no portraits are shown
				for i in range(len(portraits)):
					if i < curMessage.size()-1:
						portraits[i].set_texture_wrapper(curMessage[i+1])
						print("Preloaded "+curMessage[i+1])
			OPCODES.BG:
				var actor = backgrounds.get_child(curMessage[1])
				print(actor)
				actor.showActor(.5)
			OPCODES.PORTRAITS:
				#Badly translated lua code
				#Duplicate curMessage while skipping the 0th element
				#because it is the opcode
				var new_table = [];
				for i in range(1,curMessage.size()):
					new_table.push_back(curMessage[i])
				#Trace(table_print(new_table))
				var relation = lastPortraitTable.duplicate()
				lastPortraitTable={} #Wipe table so there aren't a bunch of indexed 'false' portraits
				
				var numPortraits = 0
				for pos in range(new_table.size()):
					var portrait = new_table[pos]
					numPortraits+=1
					if typeof(portrait)==TYPE_ARRAY: #[name,isMasked,offset]
						"""
						To use for next iteration, self.lastPortraitTable will get copied to relation. Anything that has a new position
						will get the false value in relation overwritten. If any portrait that existed in lastPortraitTable doesn't exist
						in this one, it will still have the value of false.
						"""
						lastPortraitTable[portrait[0]]=false
						relation[portrait[0]]=[pos,portrait[1],portrait[2]]
					else: #If they just specified a name
						lastPortraitTable[portrait]=false
						relation[portrait]=[pos,false,0] #pos,isMasked,offset
					
				#print(relation)
				for name in relation:
					var pStruct = relation[name]
					#assert(self.portraits[name],"A portrait by the name of "..name.." does not exist, either you made a typo or you forgot to put it in LoadImages.");
					if typeof(pStruct)==TYPE_ARRAY:
						#Pos,isMasked,offset
						#This is basically just a really stupid way of pooling
						#If the sprite is already loaded just reuse it, otherwise
						#Find an unused one and use that one
						var lastUsed = get_portrait_from_sprite(name)
						if lastUsed == null:
							for p in portraits:
								if p.is_active==false:
									lastUsed = p
									print(name)
									p.set_texture_wrapper(name)
									break
						#print(lastUsed.lastLoaded)
						#print(pStruct)
						lastUsed.position_portrait(pStruct[0],pStruct[1],pStruct[2],numPortraits)
						print("Set portrait "+name)
					else:
						#self.portraits[name].actor:playcommand("Stop")
						var lastUsed = get_portrait_from_sprite(name)
						if lastUsed != null:
							print("Stopping sprite"+name)
							get_portrait_from_sprite(name).stop()
							
		curPos+=1
	
	#WHAT COULD POSSIBLY GO WRONG
	textHistory.push_back([tmp_speaker,text.text])
	tw.interpolate_property(text,"visible_characters",0,text.text.length(),
		1/TEXT_SPEED*text.text.length(),
		Tween.TRANS_LINEAR,
		Tween.EASE_IN,
		waitForAnim
	)
	print("Tweening... waitForAnim is "+String(waitForAnim))
	tw.start()
	waitForAnim=0
	#If there was any processing done at all, this should be true
	return true

func closeTextbox(t:Tween,delay:float=0):
	#t.append($textbox,'scale:y',0,.3).set_trans(Tween.TRANS_QUAD)
	#print("Closing textbox with delay of "+String(delay))
	t.interpolate_property($textbox,"scale:y",1,0,.3,Tween.TRANS_QUAD,Tween.EASE_IN,delay)
	t.interpolate_property($SpeakerActor,"rect_position:y",460,533,.3,Tween.TRANS_QUAD,Tween.EASE_IN,delay)
	t.interpolate_property($SpeakerActor,"modulate:a",1,0,.3,Tween.TRANS_QUAD,Tween.EASE_IN,delay)

func openTextbox(t:Tween,delay:float=0):
	#print("Opening textbox with delay of "+String(delay))
	t.interpolate_property($textbox,"scale:y",0,1,.3,Tween.TRANS_QUAD,Tween.EASE_OUT,delay)
	t.interpolate_property($SpeakerActor,"rect_position:y",533,460,.3,Tween.TRANS_QUAD,Tween.EASE_OUT,delay)
	t.interpolate_property($SpeakerActor,"modulate:a",0,1,.3,Tween.TRANS_QUAD,Tween.EASE_OUT,delay)
	#t.append($textbox,'scale:y',1,.3).set_trans(Tween.TRANS_QUAD)

onready var historyTween = $HistoryTween
func tween_in_history():
	#tw.stop_all()
	tw.stop(text,"visible_characters")
	closeTextbox(historyTween)
	historyTween.interpolate_property(historyActor,"position:x",
		Globals.gameResolution.x*-1,0,.3,
		Tween.TRANS_QUAD,Tween.EASE_OUT,.2)
	historyTween.interpolate_property(text,"modulate:a",null,0,.3)
	historyTween.start()
	
func tween_out_history():
	tw.resume(text,"visible_characters")
	openTextbox(historyTween,.2)
	historyTween.interpolate_property(historyActor,"position:x",
		0,Globals.gameResolution.x*-1,.3,
		Tween.TRANS_QUAD,Tween.EASE_IN,0)
	historyTween.interpolate_property(text,"modulate:a",null,1,.3,
	Tween.TRANS_LINEAR,Tween.EASE_OUT,.2)
	historyTween.start()

func shitty_interpolate_label(s:String):
	#print("Now I set speaker to"+s+"!!")
	$SpeakerActor.text=s

func _ready():
	$PressStartToSkip.text=INITrans.GetString("Cutscene","PRESS START TO SKIP")
	print("Text speed is "+String(TEXT_SPEED))
	set_process(false)
	text = $textActor_better
	#text.visible_characters=0
	#portraits=[$Portrait1,$Portrait2,$Portrait3,$Portrait4,$Portrait5]
	var vnPortraithandler = load("res://Cutscene/VNPortraitHandler.gd")
	for _i in range(5):
		var p = Node2D.new()
		p.set_script(vnPortraithandler)
		p.modulate.a=0.0
		p.scale=Vector2(.75,.75) #We do it here instead of the whole node because scaling the whole node breaks positioning.
		portraits.append(p)
		$Portraits.add_child(p)
	
	#for p in portraits:
	#	p.modulate.a=0.0
	
	#TODO: Don't hardcode the dim quad! Make it fit to window size!
	
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
		init_(standalone_message,null,dim_the_background_if_standalone)


func init_(message, parent, dim_background = true,_backgrounds=null,delim="|",msgColumn:int=1):
	if parent:
		parent_node = parent
	if _backgrounds:
		backgrounds=_backgrounds
	$dim.modulate.a=0
	$textbox.scale.y=0
	var t := TweenSequence.new(get_tree())
	t._tween.pause_mode = Node.PAUSE_MODE_PROCESS
	t.append($textbox,'scale:y',1,.5).set_trans(Tween.TRANS_QUAD)
	if dim_background:
# warning-ignore:return_value_discarded
		t.parallel().append($dim,'modulate:a',.6,.5).from_current()
	parse_string_array(message,delim,msgColumn)
	advance_text()
	set_process(true)

func end_cutscene():
	print("Hit the end. Now I will kill myself!")
	set_process(false)
	for p in portraits:
		if p.is_active:
			p.stop()
	#https://github.com/godot-extended-libraries/godot-next/pull/50
	var seq := TweenSequence.new(get_tree())
	seq._tween.pause_mode = Node.PAUSE_MODE_PROCESS
# warning-ignore:return_value_discarded
	seq.append($textbox,'scale:y',0,.5).set_trans(Tween.TRANS_QUAD)
	seq.parallel().append(text,'modulate:a',0,.3)
	seq.parallel().append($SpeakerActor,'modulate:a',0,.3)
	#seq.parallel().append($SpeakerActor,'position:y',600,.3)
	seq.parallel().append($dim,'modulate:a',0,.5).set_trans(Tween.TRANS_QUAD)
	seq.parallel().append($PressStartToSkip,'rect_position:x',-$PressStartToSkip.rect_size.x,.5).set_trans(Tween.TRANS_QUAD)
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

func _process(delta):
	
	if isHistoryBeingShown:
		return
	if Input.is_action_just_pressed("ui_pause"):
		end_cutscene()
	elif Input.is_action_just_pressed("DebugButton1"):
		get_tree().reload_current_scene()
	
	var forward = Input.is_action_just_pressed("ui_select") or manualTriggerForward
	if text.visible_characters >= text.text.length():
		if forward:
			print("advancing")
			if curPos >= message.size() or !advance_text():
				end_cutscene()
	else:
		if forward:
			#print("skipped")
			tw.stop_all()
			$textbox.scale.y=1
			$SpeakerActor.rect_position.y=460
			$SpeakerActor.modulate.a=1
			#openTextbox(tw)
			#tw.start()
			text.visible_characters = text.text.length()
		#elif waitForAnim > 0.0:
		#	waitForAnim-=delta
		else:
			#time+=delta
			
			#var speedupMultiplier = 1.0
			if Input.is_action_pressed("ui_cancel"):
				tw.playback_speed=2.0
			else:
				tw.playback_speed=1.0
				#speedupMultiplier = 2.0
			
			#if time > .25/(TEXT_SPEED*speedupMultiplier):
			#	time=0
			#	text.visible_characters+=1
	manualTriggerForward=false
	
#Fucking piece of shit game engine
func _input(event):
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == BUTTON_LEFT:
		manualTriggerForward=true
	if event is InputEventKey and event.is_pressed() and event.scancode == KEY_1:
		if isHistoryBeingShown:
			print("Hiding history!")
			tween_out_history()
		else:
			print("Displaying history!!!")
			tween_in_history()
			historyActor.set_history(textHistory)
		isHistoryBeingShown=!isHistoryBeingShown

signal cutscene_finished()
func end_cutscene_2():
	if parent_node:
		get_tree().paused = false
	else:
		print("No parent node...")
	emit_signal("cutscene_finished")
	queue_free()
