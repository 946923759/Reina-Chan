extends Node2D

const POOL_SIZE = 5
var SCREEN_CENTER: Vector2

#TODO: Shouldn't be necessary when cache is implemented, cache.size() will return
#the size of active portraits
var numPortraits:int=0
#TODO: The cache isn't implemented
var cache: Array = []	# Holds dictionaries (see below for details)
"""
		{
			"name": SpriteName,
			"radioMask": bool,		# this could change into a tag list for different types of masks
			"y_offset": float		# in case you want to make characters shorter
		}
"""

#No need to run get_children(), we can just store the pointers to the portrait nodes
#here. And we don't want that one tween anyways.
var portraits:Array

onready var maskOverlay = $MaskOverlay

func get_portrait_from_sprite(spr:String):
	for p in portraits:
		if p.lastLoaded==spr:
			return p
	#printerr("Tried getting a portrait "+spr+" that doesn't exist")
	return null

#Load texture but don't display
func preload_portraits(arr:Array):
	#TODO: Do not preload until no portraits are shown
	for i in range(get_child_count()):
		if i < arr.size()-1:
			#idx=i+1 since first element in the array is the command name
			get_child(i).set_texture_wrapper(arr[i+1])
			print("Preloaded "+arr[i+1])

func delay_set_portrait(name:String,radioMask:bool=false,delay:float=0.3):
	if delay<=0.0:
		set_portrait(name,radioMask)
	else:
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

	var vnPortraithandler = load("res://Cutscene/MugshotImageHandler.gd")
	for _i in range(POOL_SIZE):
		var p = Sprite.new()
		p.set_script(vnPortraithandler)
		p.visible=false
		p.scale=Vector2(3,3)
		portraits.append(p)
		add_child(p)
