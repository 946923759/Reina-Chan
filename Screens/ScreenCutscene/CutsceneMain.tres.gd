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

const nightShader = preload("res://ParticleEffects/NightShader.tres")
var backgrounds:Control
var backgrounds_to_load:Array
var lastBackground:smSprite
enum BG_TWEEN {
	DEFAULT,
	FADE,
	IMMEDIATE,
	NONE
}

enum OPCODES {
	MSG, 
	PORTRAITS, 
	PRELOAD_PORTRAITS, 
	EMOTE,
	SPEAKER, 
	BG, 
	MATCH_NAMES, 
	MSGBOX_TRANSITION,
	CHOICE,
	#REWRITE_HISTORY #Edit the history! lol
	CONDJMP_CHOICE, #Oh no
	CONDJMP_NOT_EQUAL_LANG,
	CONDJMP_EQUAL_LANG,
	LABEL, #It's like JMP, but for people who don't like math /jk
	JMPLABEL,
	#JMP,
	LONGJMP,
	NOP, #It's needed so jumps are accurate
	MUSIC,
	STOPMUSIC,
	SFX
	}

var curPos: int = -1

"""var message=[
	[OPCODES.PORTRAITS,"Nyto_7","pic_UMP9"],
	[OPCODES.SPEAKER,"UMP9"],
	[OPCODES.MSG,"This is the first string"]
]"""
export(PoolStringArray) var standalone_message
export(bool) var automatically_advance_text = false
export(bool) var dim_the_background_if_standalone = true
var message: Array

var portraits:Array=[]

var musicToLoad:Array=[]
var soundsToLoad:Array=[]

#Array of 2D arrays
var textHistory:Array=[]
onready var historyActor=$CutsceneHistory


onready var text = $CenterContainer/textActor_better
onready var textboxSpr = $CenterContainer/textBackground
onready var speakerActor = $CenterContainer/SpeakerActor

var choiceResult:int=-1

func push_back_from_idx_one(arr,arr2):
	for i in range(1,arr2.size()):
		arr.push_back(arr2[i])
	return arr

#What an abomination of a function
func parse_string_array(arr,delimiter:String="|",msgColumn:int=1):
	message = []
	for s in arr:
		var splitString = s.split(delimiter) #,true,1
		if splitString[0].begins_with('/'): #Chaosoup's idea, since typing two opcodes every time was getting obnoxious
			message.push_back([OPCODES.SPEAKER,splitString[0].substr(1)])
			if msgColumn > splitString.size()-1:
				print("Hey moron, you're missing the translation for this line: "+String(splitString))
				message.push_back([OPCODES.MSG,splitString[1]])
			else:
				message.push_back([OPCODES.MSG,splitString[msgColumn]])
			#message.push_back([OPCODES.MSG,splitString[1]])
			continue
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
			"emote":
				message.push_back([OPCODES.EMOTE,splitString[1],int(splitString[2])])
			"preload_portraits":
				var newCmd=[OPCODES.PRELOAD_PORTRAITS]
				message.push_back(push_back_from_idx_one(newCmd,splitString))
				#var params = splitString[1].split("|")
				#for i in range(1,splitString.size()):
				#	newCmd.push_back(splitString[i])
				#message.push_back(newCmd)
			"bg":
				var c = BG_TWEEN.DEFAULT
				if len(splitString) > 2:
					match splitString[2]:
						"none":
							c=BG_TWEEN.NONE
						"immediate":
							c=BG_TWEEN.IMMEDIATE
						"fade":
							c=BG_TWEEN.FADE
				message.push_back([OPCODES.BG,splitString[1],c])
				if splitString[1] != "none" and !(splitString[1] in backgrounds_to_load):
					backgrounds_to_load.append(splitString[1])
			"matchnames":
				var data = [] 
				push_back_from_idx_one(data,splitString)
				#var params = splitString[1].split("|")
				for i in range(1,splitString.size()):
					data.push_back(splitString[i])
				message.push_back([OPCODES.MATCH_NAMES,data])
			"msgboxTransition":
				message.push_back([OPCODES.MSGBOX_TRANSITION])
			"nop": # "no-operation"
				message.push_back([OPCODES.NOP])
			"label":
				message.push_back([OPCODES.LABEL,splitString[1]])
			"choice":
				#var newCmd=[OPCODES.CHOICE]
				#message.push_back(push_back_from_idx_one(newCmd,splitString))
				
				var newCmd=[]
				push_back_from_idx_one(newCmd,splitString)
				message.push_back([OPCODES.CHOICE,newCmd])
			#"jmp":
			#	message.push_back([OPCODES.JMP,int(splitString[1])])
			"jmp":
				message.push_back([OPCODES.LONGJMP,splitString[1]])
			"condjmp_c":
				message.push_back([OPCODES.CONDJMP_CHOICE,splitString[1],int(splitString[2])])
			"music":
				message.push_back([OPCODES.MUSIC,splitString[1]])
				if !(splitString[1] in musicToLoad):
					musicToLoad.append(splitString[1])
			"stopmusic":
				message.push_back([OPCODES.STOPMUSIC,float(splitString[1]) if splitString[1] else 0.0])
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
var ChoiceTable:PoolStringArray = []
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
				
				if curPos < message.size()-1 and message[curPos+1][0]==OPCODES.CHOICE:
					ChoiceTable=message[curPos+1][1]
				break #Stop processing opcodes and wait for user to click
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
					speakerActor.text=curMessage[1]
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
				#print(speakerActor.text)
			OPCODES.PRELOAD_PORTRAITS:
				#TODO: Change to a portrait pooling class
				#TODO: Do not preload until no portraits are shown
				for i in range(len(portraits)):
					if i < curMessage.size()-1:
						portraits[i].set_texture_wrapper(curMessage[i+1])
						print("Preloaded "+curMessage[i+1])
			OPCODES.BG:
				var actor = backgrounds.get_node(curMessage[1].replace("/","$"))
				if !is_instance_valid(actor):
					printerr(curMessage[1]+" is an invalid background! DO NOT USE SLASHES IN BACKGROUNDS!!!!!!")
				else:
					print(actor)
					
					#Shitty way of handling transitions
					#If it works don't fix it... or something
					for n in backgrounds.get_children():
						if n!=lastBackground and n!=actor:
							n.modulate.a=0
					
					if curMessage[2]==BG_TWEEN.FADE:
						if is_instance_valid(lastBackground):
							VisualServer.canvas_item_set_z_index(lastBackground.get_canvas_item(),-11)
						VisualServer.canvas_item_set_z_index(actor.get_canvas_item(),-10)
						actor.modulate.a=0
						actor.showActor(.5)
					elif curMessage[2]==BG_TWEEN.IMMEDIATE:
						actor.modulate.a=1
						if is_instance_valid(lastBackground):
							lastBackground.modulate.a=0
					else:
						if is_instance_valid(lastBackground):
							#bgFadeLayer
							pass
							lastBackground.hideActor(.5)
							actor.showActor(.5,.5)
							if waitForAnim<.3:
								waitForAnim+=.5
						else:
							#print("ShowActor!")
							actor.showActor(.5)
						#print("unknown bg tween? "+String(curMessage[2]))
					lastBackground=actor
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
			#This is a NOP since the msg handler checks if there is a choice right after.
			#"But what if I want a choice without any text?"
			#I don't know, fuck you
			OPCODES.CHOICE, OPCODES.NOP:
				pass
			#OPCODES.JMP:
			#	curPos+=curMessage[1]
			OPCODES.LONGJMP,OPCODES.CONDJMP_CHOICE:
				#if curMessage[0] == OPCODES.CONDJMP_CHOICE:
				#	print("Processing CONDJUMP... cRes is "+String(choiceResult)+", jump if "+String(curMessage[2]))
				#else:
				#	print("processing LONGJUMP")
				if curMessage[0] == OPCODES.LONGJMP or curMessage[2]==choiceResult:
					#print(curMessage)
					var jumped:bool=false
					for i in range(curPos,message.size()):
						if message[i][0]==OPCODES.LABEL and curMessage[1]==message[i][1]:
							curPos=i
							jumped=true
							break
					if !jumped:
						for i in range(0,curPos):
							if message[i][0]==OPCODES.LABEL and curMessage[1]==message[i][1]:
								curPos=i
								jumped=true
					if !jumped:
						printerr("The label '"+curMessage[1]+"' was not found!")
				#Reset here?
				choiceResult=-1
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
	#t.append(textboxSpr,'scale:y',0,.3).set_trans(Tween.TRANS_QUAD)
	#print("Closing textbox with delay of "+String(delay))
	t.interpolate_property(textboxSpr,"rect_scale:y",1,0,.3,Tween.TRANS_QUAD,Tween.EASE_IN,delay)
	t.interpolate_property(speakerActor,"rect_scale:y",1,0,.3,Tween.TRANS_QUAD,Tween.EASE_IN,delay)
	t.interpolate_property(speakerActor,"modulate:a",1,0,.3,Tween.TRANS_QUAD,Tween.EASE_IN,delay)

func openTextbox(t:Tween,delay:float=0):
	#print("Opening textbox with delay of "+String(delay))
	t.interpolate_property(textboxSpr,"rect_scale:y",0,1,.3,Tween.TRANS_QUAD,Tween.EASE_OUT,delay)
	t.interpolate_property(speakerActor,"rect_scale:y",0,1,.3,Tween.TRANS_QUAD,Tween.EASE_OUT,delay)
	t.interpolate_property(speakerActor,"modulate:a",0,1,.3,Tween.TRANS_QUAD,Tween.EASE_OUT,delay)
	

onready var historyTween = $HistoryTween
#Updated every frame... Might be slow
#onready var screenWidth=Globals.gameResolution.x
func tween_in_history():
	#tw.stop_all()
	tw.stop(text,"visible_characters")
	closeTextbox(historyTween)
	historyTween.interpolate_property(historyActor,"rect_position:x",
		get_viewport().get_visible_rect().size.x*-1,0,.3,
		Tween.TRANS_QUAD,Tween.EASE_OUT,.2)
	historyTween.interpolate_property(text,"modulate:a",null,0,.3)
	historyTween.start()
	
func tween_out_history():
	tw.resume(text,"visible_characters")
	openTextbox(historyTween,.2)
	historyTween.interpolate_property(historyActor,"rect_position:x",
		0,get_viewport().get_visible_rect().size.x*-1,.3,
		Tween.TRANS_QUAD,Tween.EASE_IN,0)
	historyTween.interpolate_property(text,"modulate:a",null,1,.3,
	Tween.TRANS_LINEAR,Tween.EASE_OUT,.2)
	historyTween.start()

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
	#portraits=[$Portrait1,$Portrait2,$Portrait3,$Portrait4,$Portrait5]
	var vnPortraithandler = load("res://Screens/ScreenCutscene/VNPortraitHandler.gd")
	for _i in range(5):
		var p = Node2D.new()
		p.set_script(vnPortraithandler)
		p.modulate.a=0.0
		p.scale=Vector2(.75,.75) #We do it here instead of the whole node because scaling the whole node breaks positioning.
		portraits.append(p)
		$Portraits.add_child(p)
	$Portraits.connect("resized",self,"update_portrait_positions")
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



func init_(message, parent:Node, dim_background = true,_backgrounds:Control=null,delim:String="|",msgColumn:int=1):
	if parent:
		parent_node = parent
		
	if _backgrounds:
		backgrounds=_backgrounds
	else:
		backgrounds = $Backgrounds
	$dim.color.a=0
	textboxSpr.rect_scale.y=0
	var t := get_tree().create_tween()
	t.set_pause_mode(SceneTreeTween.TWEEN_PAUSE_PROCESS)
	t.tween_property(textboxSpr,'rect_scale:y',1,.5).set_trans(Tween.TRANS_QUAD)
	if dim_background:
# warning-ignore:return_value_discarded
		t.parallel().tween_property($dim,'color:a',.6,.5).from_current()
	
	parse_string_array(message,delim,msgColumn)
	
	for i in range(len(backgrounds_to_load)):
		var bgToLoad = backgrounds_to_load[i]
		
		var nightFilter = false
		if "," in bgToLoad:
			nightFilter = bgToLoad.split(",")[1].to_lower()=="true"
			bgToLoad = bgToLoad.split(",")[0]
		var c = Color(1,1,1,0)
		var s = Def.Sprite({
			modulate=c,
			Texture=bgToLoad,
			cover=true,
			name=bgToLoad
		})
		if nightFilter:
			s.material=nightShader
		backgrounds.add_child(s)
		VisualServer.canvas_item_set_z_index(s.get_canvas_item(),-10)
	backgrounds.connect("resized",self,"set_rect_size")
	advance_text()
	set_process(true)

func end_cutscene():
	print("Hit the end. Now I will kill myself!")
	set_process(false)
	for p in portraits:
		if p.is_active:
			p.stop()
	#https://github.com/godot-extended-libraries/godot-next/pull/50
	var seq := get_tree().create_tween()
	seq.set_pause_mode(SceneTreeTween.TWEEN_PAUSE_PROCESS)
# warning-ignore:return_value_discarded
	seq.tween_property(textboxSpr,'rect_scale:y',0,.5).set_trans(Tween.TRANS_QUAD)
	seq.parallel().tween_property(text,'modulate:a',0,.3)
	seq.parallel().tween_property(speakerActor,'modulate:a',0,.3)
	#seq.parallel().append($SpeakerActor,'position:y',600,.3)
	seq.parallel().tween_property($dim,'color:a',0,.5).set_trans(Tween.TRANS_QUAD)
	#seq.parallel().append($PressStartToSkip,'rect_position:x',-$PressStartToSkip.rect_size.x,.5).set_trans(Tween.TRANS_QUAD)
	seq.parallel().tween_property($PressStartToSkip,'modulate:a',0,.5)
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
