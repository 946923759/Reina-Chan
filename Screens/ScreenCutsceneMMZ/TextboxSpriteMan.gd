extends Node2D

const POOL_SIZE = 5


#No need to run get_children(), we can just store the pointers to the portrait nodes
#here. And we don't want that one tween anyways.
var portraits:Array

onready var maskOverlay = $MaskOverlay

func get_current_portrait_name() -> String:
	for p in portraits:
		if p.visible:
			return p.lastLoaded
	return "default"

func get_portrait_from_sprite(spr:String):
	for p in portraits:
		if p.lastLoaded==spr:
			return p
	#printerr("Tried getting a portrait "+spr+" that doesn't exist")
	return null

#Load texture but don't display
func preload_portraits(arr:Array):
	#TODO: Do not preload until no portraits are shown
	for i in range(portraits.size()):
		if i < arr.size()-1:
			#idx=i+1 since first element in the array is the command name
			portraits[i].set_texture_wrapper(arr[i+1])
			print("Preloaded "+arr[i+1])

func delay_set_portrait(name:String, radioMask:bool=false, delay:float=0.3):
	if delay<=0.0:
		#printerr("NO DELAY????")
		set_portrait(name,radioMask)
	else:
		#print("Delay?? "+String(delay))
		#$Tween.interpolate_callback()
		$Tween.interpolate_callback(self,delay,"set_portrait",name,radioMask)
		$Tween.start()

func set_portrait(name: String, radioMask: bool = false)->Node2D:
	# checks if exist
	# Unnecessary? CutsceneMain already checks if there's a spare portrait
	#var lastUsed = get_portrait_from_sprite(name)
	#if lastUsed:
	#	#print("Already loaded, skipping...")
	#	return lastUsed

	var found = false
	var lastUsed
	for p in portraits:
		if p.lastLoaded==name:
			lastUsed=p
			p.visible=true
			found=true
		else:
			p.visible=false
	if found==false:
		for p in portraits:
			if p.visible==false:
				lastUsed = p
				print(name)
				p.set_texture_wrapper(name)
				p.visible=true
				break
				
	#print("[PortraitMan] MasK "+String(radioMask))
	maskOverlay.set_process(radioMask)
	maskOverlay.visible=radioMask

	return lastUsed

#func set_active(spr:String):
#	var found = false
#	for p in portraits:
#		if p.lastLoaded==spr:
#			p.visible=true
#			found=true
#		else:
#			p.visible=false
#	if found==false:
#		set_portrait(spr,0)

func _ready():

	maskOverlay.set_process(false)
	maskOverlay.visible=false

	var vnPortraithandler = load("res://Screens/ScreenCutsceneMMZ/MugshotImageHandler.gd")
	for _i in range(POOL_SIZE):
		var p = Sprite.new()
		p.set_script(vnPortraithandler)
		p.visible=false
		p.scale=Vector2(3,3)
		portraits.append(p)
		add_child(p)
