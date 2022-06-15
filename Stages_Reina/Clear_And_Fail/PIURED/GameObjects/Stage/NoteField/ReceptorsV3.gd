extends Node2D

# /*
#  * # Copyright (C) Pedro G. Bascoy
#  # This file is part of piured-engine <https://github.com/piulin/piured-engine>.
#  #
#  # piured-engine is free software: you can redistribute it and/or modify
#  # it under the terms of the GNU General Public License as published by
#  # the Free Software Foundation, either version 3 of the License, or
#  # (at your option) any later version.
#  #
#  # piured-engine is distributed in the hope that it will be useful,
#  # but WITHOUT ANY WARRANTY; without even the implied warranty of
#  # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  # GNU General Public License for more details.
#  #
#  # You should have received a copy of the GNU General Public License
#  # along with piured-engine.If not, see <http://www.gnu.org/licenses/>.
#  *
#  */

# Receptors AREN'T TIED TO NOTES!!! Not really, anyways.
# The receptor and notes and columns are both part of a NoteField object.

var _noteskin:String
var _keyInput
var _beatManager;
var _animationRate;
var _padId;

#var receptor=preload("res://Stages_Reina/Clear_And_Fail/PIURED/GameObjects/Stage/NoteField/Receptor_Single.tscn")
#class stepReceptor:
#	var xPos:float=0.0;
#	var explosion:AnimatedSprite
#	var tapAnim:Sprite
var receptorColumns:Array = []
func constructor(beatManager, keyInput, padId, noteskin:String):
	
	self._noteskin = noteskin ;
	self._keyInput = keyInput ;
	self._beatManager = beatManager ;
	self._padId = padId ;

	set_process(true)


func setColumnPositions(colPos:Array):
	self.position.x=colPos[2]

#onready var dlTap = $Receptor
#onready var 
onready var t:Tween = $Tween
onready var highlight:Sprite = $Sprite2
func _ready():
	set_process(false)

	for k in ['dl','ul','c','ur','dr']:
		get_node(k).connect("animation_finished",self,"explosion_finished",[get_node(k)])

	pass



var lastBeat = -1
func _process(delta):
	$Label.text=String(_beatManager.currentAudioTime)+"\n"+String(_beatManager.song.getCurrentAudioTime(_beatManager.level))
	if floor(_beatManager.currentBeat) > lastBeat:
		lastBeat=_beatManager.currentBeat
		t.stop_all()
		t.interpolate_property(highlight,"modulate:a",1,0,.3)
		t.start()

func explosion_finished(node):
	node.visible=false

func animateExplosionStep(step:String):
	var explosion = get_node(step)
	explosion.frame=0
	explosion.play()
	explosion.visible=true

	#Ayy lmao
	#var receptorToAnimate=get_node(step)
	#receptorToAnimate.animateExplosion()
	
	
	#let tapEffect = null ;
	#let explosion = null ;
	#let stepNote = null ;
	#const kind = step.kind ;
#	match step:
#		'dl':
#			tapEffect = this.dlBounce
#			explosion = this.dlFX ;
#			stepNote = this.dlStepNote ;
#		'ul':
#			tapEffect = this.ulBounce ;
#			explosion = this.ulFX ;
#			stepNote = this.ulStepNote ;
#		'c':
#			tapEffect = this.cBounce ;
#			explosion = this.cFX ;
#			stepNote = this.cStepNote ;
#		'ur':
#			tapEffect = this.urBounce ;
#			explosion = this.urFX ;
#			stepNote = this.urStepNote ;
#		'dr':
#			tapEffect = this.drBounce ;
#			explosion = this.drFX ;
#			stepNote = this.drStepNote ;
