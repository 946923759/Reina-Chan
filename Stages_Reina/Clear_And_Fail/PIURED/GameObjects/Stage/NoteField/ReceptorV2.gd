#tool
extends Node2D
# A receptor must provide the following functions:
# animatePress()     - For when the player presses on the pad
# animateExplosion() - For when a note is hit
# animateWhite()     - Seems to also be when a note is hit



export (int,"DownLeft","UpLeft","Center","UpRight","DownRight") var columnToLoad=0

#ABANDON ALL HOPE, YE WHO ENTER HERE!
export (Array,Texture) var receptorTextures

var fallbackTextures = [
	"res://Stages_Reina/Clear_And_Fail/PIURED/Resources/NoteSkin/PRIME/DownLeft Ready Receptor 1x3.png",
	"res://Stages_Reina/Clear_And_Fail/PIURED/Resources/NoteSkin/PRIME/UpLeft Ready Receptor 1x3.png",
	"res://Stages_Reina/Clear_And_Fail/PIURED/Resources/NoteSkin/PRIME/Center Ready Receptor 1x3.png",
	"res://Stages_Reina/Clear_And_Fail/PIURED/Resources/NoteSkin/PRIME/UpRight Ready Receptor 1x3.png",
	"res://Stages_Reina/Clear_And_Fail/PIURED/Resources/NoteSkin/PRIME/DownRight Ready Receptor 1x3.png"
]

onready var base = $Base
onready var glow = $Glow
onready var explosion = $Explosion

func _ready():
	explosion.connect("animation_finished",self,"explosion_finished")

func set_receptor(_columnToLoad:int=0):
	columnToLoad=_columnToLoad
	base.texture=load(fallbackTextures[columnToLoad])
	glow.texture=load(fallbackTextures[columnToLoad])

func explosion_finished():
	explosion.visible=false


#PUBLIC FUNCTIONS
func animateExplosion():
	explosion.play()
	explosion.visible=true
func animatePress():
	pass
func animateWhite():
	pass