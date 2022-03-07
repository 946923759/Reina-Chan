extends Node2D

var font = preload("res://FallbackPixelFont.tres")
var fallbackFont = preload("res://FallbackPixelFont.tres")
var currentlyHandledMenu;
var selection = 0;
onready var mainMenu = $MainMenu
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


var translationCache:Dictionary = {}
func _ready():
	#font.size=40
	if OS.has_feature("console"):
		mainMenu.get_node("QuitLabel").queue_free()
		#home page can be kept since it works on Android TV and chrome supports controllers
	$DifficultySelect.modulate.a=0
	$DifficultySelect_Description.modulate.a=0
	$Extras.modulate.a=0
	$OptionsList.modulate.a=0
	
	if Globals.playerHasSaveData:
		selection=1
	else:
		$MainMenu/Continue.modulate=Color(.5,.5,.5)
	highlightList(mainMenu, selection);
	
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
	print("Caching text keys...")
	for node in $MainMenu.get_children():
		translationCache[node.get_name()]=node.text
	
	print("Translating items...")
	setTranslated()
	
	#Enable resizing (WIP)
	set_process(ProjectSettings.get_setting("display/window/stretch/aspect") != "keep")
	
	print("Title screen ready!")

func _process(_delta):
	$logoHolder.rect_size=get_viewport().get_visible_rect().size
	#$logoHolder/Label2.text = String(get_viewport().get_visible_rect().size)

func setTranslated():
	for node in $MainMenu.get_children():
		node.text=INITrans.GetString("TitleScreen",translationCache[node.get_name()])
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
	elif (event is InputEventMouseButton and event.pressed) or (event is InputEventScreenTouch and event.pressed):
		#print(event.button_index)
		print("Clicked at "+String(event.position))
		if (event is InputEventMouseButton and event.button_index == 2) or (event is InputEventScreenTouch and event.index==1):
			if currentlyHandledMenu:
				tweenMainMenuIn();
				if currentlyHandledMenu.has_method("OffCommand"):
						currentlyHandledMenu.OffCommand()
				currentlyHandledMenu = null
		elif currentlyHandledMenu:
			currentlyHandledMenu.mouse_input(event)
		else:
			for i in range(mainMenu.get_child_count()):
				var n = mainMenu.get_child(i)
				var p = mainMenu.rect_position+n.rect_position
				if event.position.y > p.y and event.position.y < p.y+n.rect_size.y:
					print("Guessed click: "+n.get_name())
					if i == 1 and !Globals.playerHasSaveData:
						return
					elif i==selection:
						input_select()
					else:
						selectSound.play()
						selection=i
						highlightList(mainMenu,selection);
					break
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
			if selection < mainMenu.get_child_count() - 1:
				selectSound.play()
				selection = selection + 1;
				#Skip continue if there's no save file
				if selection == 1 and !Globals.playerHasSaveData:
					selection = 2;
				highlightList(mainMenu,selection);
				
		if Input.is_action_pressed("ui_up"):
			if selection > 0:
				selectSound.play()
				selection = selection - 1;
				if selection == 1 and !Globals.playerHasSaveData:
					selection = 0;
				highlightList(mainMenu, selection);
				
		if Input.is_action_just_pressed("ui_select"):
			input_select()

func input_select():
	#self.get_node("Debug").text = list.get_child(selection).text;
	confirmSound.play()
	var sel = mainMenu.get_child(selection);
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
	tween.interpolate_property(mainMenu, 'rect_position:x',
	null, initialPosition-200, .25, Tween.TRANS_QUAD, Tween.EASE_OUT);
	tween.interpolate_property(mainMenu, 'modulate',
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
	tween.interpolate_property(mainMenu, 'rect_position:x',
	null, initialPosition, .25, Tween.TRANS_QUAD, Tween.EASE_OUT);
	tween.interpolate_property(mainMenu, 'modulate',
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
