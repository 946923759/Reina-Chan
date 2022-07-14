extends Node2D

onready var parent = get_node("../")
var existing_children:int
var displayedOptions:int=0

#var optionsList:PoolStringArray = []
func _ready():
	#I miss StepMania... A lot...
	"""
	for i,option in ipairs(options) do
		local tmpFrame = Def.ActorFrame{
			Name="Frame"..i;
			Def.ActorMultiVertex{
				Name="Vertex";
				InitCommand=function(subself)
					subself:xy(-25,-20);
					subself:SetDrawState{Mode="DrawMode_QuadStrip"}
					--subself:ztest(true):ztestmode("ZTestMode_WriteOnFail");
				end;
				GainFocusCommand=function(q)
					q:stoptweening():SetVertices({
						{{0, 0, 0}, Color.HoloBlue},
						{{40, 0, 0}, Color.HoloBlue},
						{{0, 40, 0}, Color.HoloBlue},
						{{0, 40, 0}, Color.HoloBlue}
					})
					q:decelerate(.45):SetVertices({
						{{0, 0, 0}, Color.HoloBlue},
						{{400+40, 0, 0}, Color.HoloBlue},
						{{0, 40, 0}, Color.HoloBlue},
						{{400-2, 40, 0}, Color.HoloBlue}
					})
				end;
				LoseFocusCommand=function(q)
					q:finishtweening():SetVertices({
						{{0, 0, 0}, Color.HoloBlue},
						{{0, 0, 0}, Color.HoloBlue},
						{{0, 40, 0}, Color.HoloBlue},
						{{0, 40, 0}, Color.HoloBlue}
					})
				end;
			};
			Def.BitmapText{
				Name="Text";
				Font="Common Normal";
				Text=option.string;
				InitCommand=cmd(horizalign,left);
				GainFocusCommand=cmd(stoptweening;linear,.1;diffuse,Color.Black);
				LoseFocusCommand=cmd(stoptweening;diffuse,color("ffffff"));
				--GainFocusCommand=cmd(stoptweening;linear,.1;zoom,1;diffuse,Color.Blue);
				--LoseFocusCommand=cmd(stoptweening;linear,.1;zoom,0.9;diffuse,color("ffffff"));
			}
		}
		if option.optionType then
				local clr = {.5,.5,.5,1};
				tmpFrame[#tmpFrame+1] = Def.ActorMultiVertex{
				Name="Vertex2";
				InitCommand=function(subself)
					subself:xy(200-50,-20);
					subself:SetDrawState{Mode="DrawMode_QuadStrip"}
					--subself:ztest(true):ztestmode("ZTestMode_WriteOnFail");
				end;
				GainFocusCommand=function(q)
					q:stoptweening():SetVertices({
						{{0, 0, 0}, clr},
						{{0, 0, 0}, clr},
						{{-40, 40, 0}, clr},
						{{-40, 40, 0}, clr}
					})
					q:sleep(.45/4):decelerate(.45*.7):SetVertices({
						{{0, 0, 0}, clr},
						{{200+40+25, 0, 0}, clr},
						{{-40, 40, 0}, clr},
						{{200-2+25, 40, 0}, clr}
					})
				end;
				LoseFocusCommand=function(q)
					q:finishtweening():SetVertices({
						{{0, 0, 0}, {0,0,0,.5}},
						{{0, 0, 0}, {0,0,0,.5}},
						{{0, 40, 0}, {0,0,0,.5}},
						{{0, 40, 0}, {0,0,0,.5}}
					})
				end;
			};
		
			if option.optionType == "int" then
				--[[tmpFrame[#tmpFrame+1] = rectGen(200,8,1,{.5,.5,.5,.5})..{
					InitCommand=cmd(x,225);
				};]]
				--[[tmpFrame[#tmpFrame+1]=Def.Quad{
					InitCommand=cmd(setsize,223,40;x,223+40;diffuse,Color.Red)
				}]]
				tmpFrame[#tmpFrame+1] = Def.Quad{
					Name="SliderBack";
					InitCommand=cmd(setsize,1,8;zoomtowidth,150;diffuse,Color.Black;horizalign,left;x,240-150/2);
					GainFocusCommand=cmd(stoptweening;sleep,.15;linear,.1;diffuse,Color.Black);
					LoseFocusCommand=cmd(stoptweening;diffuse,Color.White);
					
				}
				tmpFrame[#tmpFrame+1] = Def.Quad{
					Name="Slider";
					InitCommand=cmd(setsize,1,8;zoomtowidth,150;diffuse,Color.HoloBlue;horizalign,left;x,240-150/2)
				}
				tmpFrame[#tmpFrame+1] = Def.BitmapText{
					Font="Common Normal";
					Name='Value';
					Text='100';
					InitCommand=cmd(x,350;maxwidth,50);
				}
			else
				--[[tmpFrame[#tmpFrame+1]=Def.Quad{
					InitCommand=cmd(setsize,223,40;x,223+40;diffuse,Color.Red)
				}]]
				tmpFrame[#tmpFrame+1] = Def.BitmapText{
					Font="Common Normal";
					Text='OFF';
					Name='BoolOff';
					InitCommand=cmd(x,223+40-223/2+223*.25;diffuse,Color.White);
					--GainFocusCommand=cmd(stoptweening;linear,.1;diffuse,Color.Black);
					GainFocusCommand=function(self)
						self:stoptweening():linear(.1):diffuse({0,0,0,self:GetDiffuseAlpha()});
					end;
					LoseFocusCommand=function(self)
						self:diffuse({1,1,1,self:GetDiffuseAlpha()});
					end;
				}
				
				tmpFrame[#tmpFrame+1] = Def.BitmapText{
					Font="Common Normal";
					Text='ON';
					Name='BoolOn';
					InitCommand=cmd(x,223+40-223/2+223*.75;diffuse,{1,1,1,.5});
					GainFocusCommand=function(self)
						self:stoptweening():linear(.1):diffuse({0,0,0,self:GetDiffuseAlpha()});
					end;
					LoseFocusCommand=function(self)
						self:diffuse({1,1,1,self:GetDiffuseAlpha()});
					end;
				}
			end;
		end;
		oas[#oas+1] = tmpFrame;
	end;
	"""
	existing_children=get_child_count()
	
	var i = 0
	for option in Globals.OPTIONS:
		
		#Skip the fullscreen option on consoles
		if OS.has_feature("console") and option == "isFullscreen":
			continue
		
		var optionItem = Node2D.new()
		optionItem.name="Item"+str(i)
		optionItem.set_meta("opt_name",option)
		optionItem.position=Vector2(0,i*70)
		var optionNameActor = parent.BitmapText({
			"name":"TextActor",
			"text":INITrans.GetString("SystemOptions",option),
			"uppercase":true
		})
		#print(parent.font.get_string_size(option))
		#print(Globals.OPTIONS[option])
		match Globals.OPTIONS[option]['type']:
			"int","list":
				optionItem.add_child(parent.BitmapText({
					name="Value",
					text=str(Globals.OPTIONS[option]['value']),
					"uppercase":true,
					rect_position=Vector2(650,0)
				}))
				#optionItem.get_node("Value").connect("gui_input",self,"mouse_input")
			_:
				optionItem.add_child(parent.BitmapText({
					"name":"BoolOff",
					"text":"Off",
					"rect_position":Vector2(650,0),
					"uppercase":true
				}))
				optionItem.add_child(parent.BitmapText({
					"name":"BoolOn",
					"text":"On",
					"rect_position":Vector2(820,0),
					"uppercase":true
				}))
		
		displayedOptions+=1
		optionItem.add_child(optionNameActor)
		i=i+1
		
		self.add_child(optionItem)
		#optionsList.append(option)
	highlightList()
	updateTranslation()
	realInitPos=position

func OffCommand():
	Globals.save_system_data()

var selection = 0

func highlightList():
	for node in get_children():
		if node.name == "Item"+str(selection):
			node.set("modulate", Color(1,1,1,1));
		else:
			node.set("modulate", Color(.5,.5,.5,1));
		if node.has_node("BoolOn"):
			var opt = node.get_meta("opt_name")
			#print(opt)
			highlightBool(node,Globals.OPTIONS[opt]['value'])
			
func highlightBool(node,b):
	node.get_node("BoolOff").set("modulate", Color(.5,.5,.5,1) if b else Color(1,1,1,1));
	node.get_node("BoolOn").set("modulate", Color(.5,.5,.5,1) if not b else Color(1,1,1,1));

func updateValue(selection,option):
	get_child(existing_children+selection).get_node("Value").text=Globals.OPTIONS[option]['value']

func updateTranslation(refresh:bool=false,t:String=""):
	if refresh:
		INITrans.SetLanguage(t)
		parent.setTranslated()
		parent.get_node("DifficultySelect").reload_translation()
	for node in get_children():
		if node.has_meta("opt_name"):
			var o = node.get_meta("opt_name")
			var tn = node.get_node("TextActor")
			tn.text=INITrans.GetString("SystemOptions",o)
			var width = INITrans.font.get_string_size(tn.text).x
			if width > 600:
				var scaling = 600/width
				tn.rect_scale.x=scaling
			else:
				tn.rect_scale.x=1.0
#				#print(width)
			for nn in node.get_children():
				if nn is Label:
					nn.set("custom_fonts/font",INITrans.font)
			#tn.set("custom_fonts/font",INITrans.font)
			#if node.has_node("BoolOn"):
			#	node.get_node("BoolOff").set("custom_fonts/font",INITrans.font)
			#	node.get_node("BoolOn").set("custom_fonts/font",INITrans.font)
			#elif node.has_node("")
#What
var realInitPos
func moveListUp():
	#print(String(realInitPos))
	var tween2 = get_node("../Tween2");
	var subList = self
	tween2.interpolate_property(subList, 'position:y',
	null,
	realInitPos.y-175, #move 100px up
	.25, Tween.TRANS_QUAD, Tween.EASE_OUT);
	tween2.start();
	
func moveListDown():
	var tween2 = get_node("../Tween2");
	var subList = self
	tween2.interpolate_property(subList, 'position:y',
	null,
	realInitPos.y, #move to original position
	.25, Tween.TRANS_QUAD, Tween.EASE_OUT);
	tween2.start()

func mouse_input(event):
	for i in range(existing_children,get_child_count()):
		var n = get_child(i)
		if !(n is Node2D):
			continue
		var nPos = n.position+position
		if event.position.y > nPos.y and event.position.y < nPos.y+70:
			#print(n.get_meta('opt_name'))
			selection = i-existing_children
			highlightList()
			if selection < 6:
				moveListDown()
			else:
				moveListUp()
				
			if event.position.x > nPos.x+650:
				var o = n.get_meta('opt_name')
				if Globals.OPTIONS[o]['type']=="bool":
					Globals.OPTIONS[o]['value']=event.position.x > 820
					highlightBool(n,event.position.x > 820)
			else:
				parent.selectSound.play()
			break
func input():
	if Input.is_action_pressed("ui_down") and selection < displayedOptions-1:
		selection+=1
		highlightList()
		if selection > 5:
			moveListUp()
		parent.selectSound.play()
	elif Input.is_action_pressed("ui_up") and selection > 0:
		selection-=1
		highlightList()
		if selection < 6:
			moveListDown()
		parent.selectSound.play()
	elif Input.is_action_pressed("ui_left"):
		var option = get_child(existing_children+selection).get_meta("opt_name")
		if Globals.OPTIONS[option]['type']=="bool":
			Globals.OPTIONS[option]['value']=false
			highlightBool(get_child(existing_children+selection),false)
			if option=="isFullscreen":
				Globals.set_fullscreen(false)
		elif Globals.OPTIONS[option]['type']=="int":
			var val = Globals.OPTIONS[option]['value']
			if val > 0:
				val-=10
				Globals.OPTIONS[option]['value']=val
				get_child(existing_children+selection).get_node("Value").text=String(val)
				if option=="AudioVolume" or option=="SFXVolume" or option=="VoiceVolume":
					if parent.reinaAudioPlayer.nsf_player != null:
						var realVolumeLevel = Globals.OPTIONS['AudioVolume']['value']*.6-60
						parent.reinaAudioPlayer.nsf_player.set_volume(realVolumeLevel);
					Globals.set_audio_levels()
				if option == "VoiceVolume":
					$Announcer.stop()
					$Announcer.play()
				#else:
				#	print("a")
		elif Globals.OPTIONS[option]['type']=="list":
			var val = Globals.OPTIONS[option]['value']
			var idx = Globals.OPTIONS[option]['choices'].find(val,0)
			if idx >0:
				Globals.OPTIONS[option]['value']=Globals.OPTIONS[option]['choices'][idx-1]
				var t = Globals.OPTIONS[option]['value']
				if option=="language":
					updateTranslation(true,t)
					t=INITrans.GetString("Language",t)
				get_child(existing_children+selection).get_node("Value").text=t
		else:
			print("Unknown type! "+Globals.OPTIONS[option]['type'])
	elif Input.is_action_pressed("ui_right"):
		var option = get_child(existing_children+selection).get_meta("opt_name")
		match Globals.OPTIONS[option]['type']:
			"bool":
				Globals.OPTIONS[option]['value']=true
				highlightBool(get_child(existing_children+selection),true)
				if option=="isFullscreen":
					Globals.set_fullscreen(true)
			"int":
				var val = Globals.OPTIONS[option]['value']
				if val < 100:
					val+=10
					Globals.OPTIONS[option]['value']=val
					get_child(existing_children+selection).get_node("Value").text=String(val)
					if option=="AudioVolume" or option=="SFXVolume" or option=="VoiceVolume":
						if parent.reinaAudioPlayer.nsf_player != null:
							var realVolumeLevel = Globals.OPTIONS['AudioVolume']['value']*.6-60
							parent.reinaAudioPlayer.nsf_player.set_volume(realVolumeLevel);
						Globals.set_audio_levels()
					if option == "VoiceVolume":
						$Announcer.stop()
						$Announcer.play()
			"list":
				var val = Globals.OPTIONS[option]['value']
				var idx = Globals.OPTIONS[option]['choices'].find(val,0)
				if idx < len(Globals.OPTIONS[option]['choices'])-1:
					Globals.OPTIONS[option]['value']=Globals.OPTIONS[option]['choices'][idx+1]
					var t = Globals.OPTIONS[option]['value']
					if option=="language":
						updateTranslation(true,t)
						t=INITrans.GetString("Language",t)
					get_child(existing_children+selection).get_node("Value").text=t
	#elif Input.is_action_just_pressed("ui_select"):
	#	call("action_"+get_child(selection).name)
