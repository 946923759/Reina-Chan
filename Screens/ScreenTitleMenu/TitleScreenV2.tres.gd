extends Control
signal menu_switched(new_menu)

var font = preload("res://ubuntu-font-family/FallbackPixelFont.tres")
var fallbackFont = preload("res://ubuntu-font-family/FallbackPixelFont.tres")
var currentlyHandledMenu;
var selection = 0;
onready var mainMenu = $MainMenu
onready var confirmSound = $Confirm
onready var selectSound = $Select


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

static func highlightList(actor:Node, param:int = -1):
	for i in range(actor.get_child_count()):
		if i != param:
			actor.get_child(i).set("custom_colors/font_color", Color(.5,.5,.5,1));
		else:
			actor.get_child(i).set("custom_colors/font_color", Color(1,1,1,1));


var translationCache:Dictionary = {}
func _ready():
	get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_2D,SceneTree.STRETCH_ASPECT_EXPAND,Vector2(1280,720))
	#font.size=40
	if OS.has_feature("console"):
		mainMenu.get_node("QuitLabel").queue_free()
		#home page can be kept since it works on Android TV and chrome supports controllers
	
	$DifficultySelect.modulate.a=0
	$DifficultySelect_Description.modulate.a=0
	$Extras.modulate.a=0
	$OptionsList.modulate.a=0
	# Need to set false so mouse doesn't touch it
	$DifficultySelect.visible=false
	#$DifficultySelect_Description.visible=false
	$Extras.visible=false
	$OptionsList.visible=false
	
	if Globals.playerHasSaveData:
		selection=1
	else:
		$MainMenu/Continue.modulate=Color(.5,.5,.5)
		
	for i in range(mainMenu.get_child_count()):
		mainMenu.get_child(i).connect("gui_input",self,"input_touch", [i])
	highlightList(mainMenu, selection);
	

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


func input_confirm():
	#self.get_node("Debug").text = list.get_child(selection).text;
	var sel = mainMenu.get_child(selection);
	if sel.hasSubmenu:
		confirmSound.play()
		currentlyHandledMenu = get_node(sel.submenuNode);
		if currentlyHandledMenu.has_method("OnCommand"):
			currentlyHandledMenu.OnCommand()
		emit_signal("menu_switched",currentlyHandledMenu)
		tweenMainMenu();
		return
	else:
		sel.action();
		$Continue_Sound.play()

func _input(event):
	if Input.is_key_pressed(KEY_0):
		OnCommand()
	
	if event is InputEventJoypadMotion or event is InputEventMouseMotion:
		return
	elif (event is InputEventMouseButton and event.pressed) or (event is InputEventScreenTouch and event.pressed):
		if (event is InputEventMouseButton and event.button_index == 2) or (event is InputEventScreenTouch and event.index==1):
			if currentlyHandledMenu:
				tweenMainMenuIn();
				if currentlyHandledMenu.has_method("OffCommand"):
						currentlyHandledMenu.OffCommand()
				currentlyHandledMenu = null
				emit_signal("menu_switched",currentlyHandledMenu)
				return
	if currentlyHandledMenu:
		if Input.is_action_just_pressed("ui_cancel"):
			#currentlyHandledMenu.visible=false
			#$MainMenu.visible=true
			tweenMainMenuIn();
			if currentlyHandledMenu.has_method("OffCommand"):
					currentlyHandledMenu.OffCommand()
			currentlyHandledMenu = null
			emit_signal("menu_switched",currentlyHandledMenu)
			#return
		else:
			currentlyHandledMenu.input(event);
	else:
		if Input.is_action_just_pressed("ui_down"):
			
			while true:
				selection += 1
				if selection > mainMenu.get_child_count() - 1:
					selection = 0
					break;
				#Skip continue if there's no save file
				elif selection == 1 and !Globals.playerHasSaveData:
					pass
				elif mainMenu.get_child(selection).visible:
					break
			
			selectSound.play()
			highlightList(mainMenu,selection);
				
		if Input.is_action_just_pressed("ui_up"):
			
			while true:
				selection -= 1
				if selection < 0:
					selection = mainMenu.get_child_count() - 1
					break
				#Skip continue if there's no save file
				elif selection == 1 and !Globals.playerHasSaveData:
					pass
				elif mainMenu.get_child(selection).visible:
					break
			
			selectSound.play()
			highlightList(mainMenu, selection);
				
		if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_pause"):
			input_confirm()

func input_touch(event: InputEvent, sel:int = -1):
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		if sel == 1 and !Globals.playerHasSaveData:
			return
		elif sel==selection:
			input_confirm()
		else:
			selectSound.play()
			selection=sel
			highlightList(mainMenu,selection);

var initialPosition = 35
func tweenMainMenu():
	#TODO: Remove this shit and replace it with the newer tweens
	
	#First tween out main menu
	var tween = $Tween;
	var tween2 = $Tween2;
	tween.remove_all()
	tween2.remove_all()
	
	tween.interpolate_property(mainMenu, 'rect_position:x',
	null, initialPosition-200, .25, Tween.TRANS_QUAD, Tween.EASE_OUT);
	tween.interpolate_property(mainMenu, 'modulate',
	null, Color(1,1,1,0), .25, Tween.TRANS_QUAD, Tween.EASE_OUT);
	tween.interpolate_property(mainMenu,"visible",
	null,false,0.0,Tween.TRANS_LINEAR,Tween.EASE_IN,.25);
	
	#Tween in the submenu
	var property = "rect_position:x"
	#print(currentlyHandledMenu.get_class())
	if currentlyHandledMenu.get_class() == "Node2D":
		property = "position:x"	
	
	var subList = currentlyHandledMenu;
	
	tween2.interpolate_property(subList,"visible",
	null, true, 0.0,Tween.TRANS_LINEAR,Tween.EASE_IN);
	tween2.interpolate_property(subList, property,
	initialPosition+200,
	initialPosition,
	.25, Tween.TRANS_QUAD, Tween.EASE_OUT);
	tween2.interpolate_property(subList, 'modulate',
	null, Color(1,1,1,1), .25, Tween.TRANS_QUAD, Tween.EASE_OUT);
	
	tween.start();
	tween2.start();

func tweenMainMenuIn():
	
	#Tween the main menu back in
	var tween = $Tween;
	var tween2 = $Tween2;
	tween.remove_all()
	tween2.remove_all()
	
	tween.interpolate_property(mainMenu,"visible",
	null, true, 0.0,Tween.TRANS_LINEAR,Tween.EASE_IN);
	tween.interpolate_property(mainMenu, 'rect_position:x',
	null, initialPosition, .25, Tween.TRANS_QUAD, Tween.EASE_OUT);
	tween.interpolate_property(mainMenu, 'modulate',
	null, Color(1,1,1,1), .25, Tween.TRANS_QUAD, Tween.EASE_OUT);
	tween.start();
	
	
	#Tween the submenu out
	var property = "rect_position:x"
	if currentlyHandledMenu.get_class() == "Node2D":
		property = "position:x"
		
	tween2.interpolate_property(currentlyHandledMenu, property,
	null,
	initialPosition+200,
	.25, Tween.TRANS_QUAD, Tween.EASE_OUT);
	tween2.interpolate_property(currentlyHandledMenu, 'modulate',
	null, Color(1,1,1,0), .25, Tween.TRANS_QUAD, Tween.EASE_OUT);
	tween2.interpolate_property(currentlyHandledMenu,"visible",
	null,false,0.0,Tween.TRANS_LINEAR,Tween.EASE_IN,.25);
	
	tween.start();
	tween2.start();

func OnCommand():
	var t = $Tween3
	var lim = mainMenu.get_child_count()
	for i in range(lim):
		var c = mainMenu.get_child(i)
		
		#Because godot makes no sense, setting visible will reset the rect position
		#inside a VBoxContainer. But not modulate.
		c.modulate=Color.transparent
		t.interpolate_property(c,"modulate",null,Color.white,0,Tween.TRANS_CUBIC,Tween.EASE_OUT,i*.05)
		t.interpolate_property(c,"rect_position:x",-1000,0,.5,Tween.TRANS_CUBIC,Tween.EASE_OUT,i*.05)
	#Not working?
	#t.interpolate_property(mainMenu,"visible",null,true,0.0)
	#t.interpolate_property(mainMenu,"visible",null,true,0.0)
	#print("MainMenu visible!")
	t.start()
	set_process_input(true)
