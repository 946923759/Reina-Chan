extends Node2D

var font = preload("res://FallbackPixelFont.tres")
var fallbackFont = preload("res://FallbackPixelFont.tres")
var currentlyHandledMenu;
var selection = 0;
onready var list = $MainMenu
onready var confirmSound = $Confirm
onready var selectSound = $Select

export (String) var nsf_music
export (int) var nsf_track_num = 0
#var nsf_player
var reinaAudioPlayer

func BitmapText(d)->Label:
	var l = Label.new()
	for property in d:
		l.set(property,d[property])
	l.set("custom_fonts/font",font)
	l.add_to_group("Translatable")
	return l
	
func diffusealpha(node,alpha):
	var tween = $Tween3
	tween.stop_all()
	tween.interpolate_property(node, 'modulate:a',
	null, alpha, .25, Tween.TRANS_QUAD, Tween.EASE_OUT);
	tween.start();

func highlightList(actor,param):
	for i in range(actor.get_child_count()):
		if i != param:
			actor.get_child(i).set("custom_colors/font_color", Color(.5,.5,.5,1));
		else:
			actor.get_child(i).set("custom_colors/font_color", Color(1,1,1,1));

func _ready():
	#font.size=40
	if OS.has_feature("console"):
		list.get_node("QuitLabel").queue_free()
		#home page can be kept since it works on Android TV and chrome supports controllers
	$DifficultySelect.modulate.a=0
	$DifficultySelect_Description.modulate.a=0
	$Extras.modulate.a=0
	$OptionsList.modulate.a=0
	
	if Globals.playerHasSaveData:
		selection=1
	else:
		$MainMenu/Continue.modulate=Color(.5,.5,.5)
	highlightList(list, selection);
	
	#print(OS.get_executable_path().get_base_dir()+"/CustomMusic/")
	print("Starting music...")
	reinaAudioPlayer=Globals.ReinaAudioPlayer.new(self)
	reinaAudioPlayer.load_song("TitleScreen",nsf_music,nsf_track_num)
	print("Success.")
	#var music = Globals.get_custom_music("TitleScreen")
	#$DifficultySelect.visible=false
	#$Extras.visible=false
	#$OptionsList.visible=false
	#optionItem.add_child()
	CheckpointPlayerStats.clearEverything()
	print("Translating items...")
	setTranslated()
	print("Title screen ready!")

func setTranslated():
	for node in $MainMenu.get_children():
		node.text=INITrans.GetString("TitleScreen",node.text)
		if INITrans.currentLanguageType!=INITrans.LanguageType.ASCII:
			node.set("custom_fonts/font",INITrans.font)
#	if TranslationServer.get_locale() != "en_US":
#		print("user lang: "+TranslationServer.get_locale())
#		for l in get_tree().get_nodes_in_group("TEST"):
#
#			#print(l.text)
#			print(l.get_path())
#			#l.get_parent()
#			if l.get_parent()==$OptionsList:
#				var width = fallbackFont.get_string_size(tr(l.text)).x
#				#print(width)
#				if width > 550:
#					var scaling = 550/width
#					l.rect_scale.x=scaling
#			l.set("custom_fonts/font",fallbackFont)

func _input(event):
	if event is InputEventJoypadMotion or event is InputEventMouseMotion: #XInput controllers are broken on Windows :P
		return
	#print(String(event.get_device())+" "+event.as_text())
	if currentlyHandledMenu:
		if Input.is_action_just_pressed("ui_cancel"):
			#currentlyHandledMenu.visible=false
			#$MainMenu.visible=true
			tweenMainMenuIn();
			if currentlyHandledMenu.has_method("OffCommand"):
					currentlyHandledMenu.OffCommand()
			currentlyHandledMenu = null
			#return
		else:
			currentlyHandledMenu.input();
	else:
		if Input.is_action_pressed("ui_down"):
			if selection < list.get_child_count() - 1:
				selectSound.play()
				selection = selection + 1;
				#Skip continue if there's no save file
				if selection == 1 and !Globals.playerHasSaveData:
					selection = 2;
				highlightList(list,selection);
				
		if Input.is_action_pressed("ui_up"):
			if selection > 0:
				selectSound.play()
				selection = selection - 1;
				if selection == 1 and !Globals.playerHasSaveData:
					selection = 0;
				highlightList(list, selection);
				
		if Input.is_action_just_pressed("ui_select"):
			#self.get_node("Debug").text = list.get_child(selection).text;
			confirmSound.play()
			var sel = list.get_child(selection);
			if sel.hasSubmenu:
				currentlyHandledMenu = get_node(sel.submenuNode);
				if currentlyHandledMenu.has_method("OnCommand"):
					currentlyHandledMenu.OnCommand()
				#$MainMenu.visible=false
				#currentlyHandledMenu.visible=true
				#currentSubmenu.selection = 0;
				#currentSubmenu.highlightList(currentSubmenu.selection);
				#inSubmenu = true;
				tweenMainMenu();
				return
			else:
				sel.action();

var initialPosition = 35
func tweenMainMenu():
	#TODO: Remove this shit and replace it with the newer tweens
	
	#First tween out main menu
	var tween = $Tween;
	tween.interpolate_property(list, 'rect_position:x',
	null, initialPosition-200, .25, Tween.TRANS_QUAD, Tween.EASE_OUT);
	tween.interpolate_property(list, 'modulate',
	null, Color(1,1,1,0), .25, Tween.TRANS_QUAD, Tween.EASE_OUT);
	tween.start();
	
	#Tween in the submenu
	var property = "rect_position:x"
	#print(currentlyHandledMenu.get_class())
	if currentlyHandledMenu.get_class() == "Node2D":
		property = "position:x"	
	
	var tween2 = get_node("Tween2");
	var subList = currentlyHandledMenu;
	tween2.interpolate_property(subList, property,
	initialPosition+200,
	initialPosition,
	.25, Tween.TRANS_QUAD, Tween.EASE_OUT);
	tween2.interpolate_property(subList, 'modulate',
	null, Color(1,1,1,1), .25, Tween.TRANS_QUAD, Tween.EASE_OUT);
	tween2.start();

func tweenMainMenuIn():
	
	#Tween the main menu back in
	var tween = $Tween;
	tween.interpolate_property(list, 'rect_position:x',
	null, initialPosition, .25, Tween.TRANS_QUAD, Tween.EASE_OUT);
	tween.interpolate_property(list, 'modulate',
	null, Color(1,1,1,1), .25, Tween.TRANS_QUAD, Tween.EASE_OUT);
	tween.start();
	
	
	#Tween the submenu out
	var property = "rect_position:x"
	if currentlyHandledMenu.get_class() == "Node2D":
		property = "position:x"	
	var tween2 = get_node("Tween2");
	tween2.interpolate_property(currentlyHandledMenu, property,
	null,
	initialPosition+200,
	.25, Tween.TRANS_QUAD, Tween.EASE_OUT);
	tween2.interpolate_property(currentlyHandledMenu, 'modulate',
	null, Color(1,1,1,0), .25, Tween.TRANS_QUAD, Tween.EASE_OUT);
	tween2.start();


func _on_CheatCodeHandler_cheat_detected():
	pass # Replace with function body.
