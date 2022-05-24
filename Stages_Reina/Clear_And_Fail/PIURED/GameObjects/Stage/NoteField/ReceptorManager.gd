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

#// Space to the right or left of a given step.
const stepShift = 4/5;
#// Note that the receptor steps are a bit overlapped. This measure takes into
#// acount this overlap.
const stepOverlap = 0.02 ;

var receptor=preload("res://Stages_Reina/Clear_And_Fail/PIURED/GameObjects/Stage/NoteField/Receptor_Single.tscn")
#class stepReceptor:
#	var xPos:float=0.0;
#	var explosion:AnimatedSprite
#	var tapAnim:Sprite
var receptorColumns:Array = []
func constructor(beatManager, keyInput, padId, animationRate, noteskin:String, numColumns:int=5):
	
	self._noteskin = noteskin ;
	self._keyInput = keyInput ;
	self._beatManager = beatManager ;
	self._animationRate = animationRate ;
	self._padId = padId ;



	# If you change this, I really, REALLY hope you know what you're doing!
	# Because the sprite is hardcoded for 5 columns!
	receptorColumns.resize(numColumns)
	for i in range(numColumns):
		var r = receptor.instance()
		r.position.x=-2*(stepShift - stepOverlap)+i*(stepShift - stepOverlap)
		self.add_child(r)

func animateExplosionStep(step:String):
	#let tapEffect = null ;
	#let explosion = null ;
	#let stepNote = null ;
	#const kind = step.kind ;
	var receptorToAnimate=get_child(0)
	match step:
		'dl':
			tapEffect = this.dlBounce
			explosion = this.dlFX ;
			stepNote = this.dlStepNote ;
		'ul':
			tapEffect = this.ulBounce ;
			explosion = this.ulFX ;
			stepNote = this.ulStepNote ;
		'c':
			tapEffect = this.cBounce ;
			explosion = this.cFX ;
			stepNote = this.cStepNote ;
		'ur':
			tapEffect = this.urBounce ;
			explosion = this.urFX ;
			stepNote = this.urStepNote ;
		'dr':
			tapEffect = this.drBounce ;
			explosion = this.drFX ;
			stepNote = this.drStepNote ;
	receptorToAnimate.animateExplosion()
	