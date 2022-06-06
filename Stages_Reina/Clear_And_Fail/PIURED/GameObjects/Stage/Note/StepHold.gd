extends "res://Stages_Reina/Clear_And_Fail/PIURED/GameObjects/Stage/Note/StepNote.gd"
class_name StepHold

#/*
# * # Copyright (C) Pedro G. Bascoy
# # This file is part of piured-engine <https://github.com/piulin/piured-engine>.
# #
# # piured-engine is free software: you can redistribute it and/or modify
# # it under the terms of the GNU General Public License as published by
# # the Free Software Foundation, either version 3 of the License, or
# # (at your option) any later version.
# #
# # piured-engine is distributed in the hope that it will be useful,
# # but WITHOUT ANY WARRANTY; without even the implied warranty of
# # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# # GNU General Public License for more details.
# #
# # You should have received a copy of the GNU General Public License
# # along with piured-engine.If not, see <http://www.gnu.org/licenses/>.
# *
# */

var _holdExtensible ;
var _lastGapLength:float= 0.0
var _endBeat:float ;
var _originalEndBeat:float ;
var endTimeStamp:float
#const holdZDepth := -2 ;

func constructHoldExtensible(endBeat:float ):
	self._endBeat = endBeat ;
	self._originalEndBeat = endBeat ;
	#self._holdExtensible = new Hold(self._resourceManager,self.kind, noteskin) ;
	#self._holdExtensible.object.position.z = self.holdZDepth ;
	#self._holdExtensible.object.position.x = self._stepNote.object.position.x ;
	#self._object.add(self._holdExtensible.object) ;



func gapLength()->float:
	var beginningHoldYPosition = position.y ;
	var endHoldYPosition = self._endBeat ;
	return beginningHoldYPosition - endHoldYPosition ;

func _ready():
	#self.updateHoldExtensiblePosition()
	pass

func updateHoldExtensiblePosition():
#	self._lastGapLength = self.gapLength() ;
#	var gap = abs(self._lastGapLength) ;
#	self._holdExtensible.size = gap + 0.5 ;
#
#	if self._lastGapLength >= 0:
#		self._holdExtensible.object.position.y = position.y - self._lastGapLength/2 - 0.25;
#	else:
#		self._holdExtensible.object.position.y = position.y - self._lastGapLength/2 + 0.25;
#
#
#
#	if self._lastGapLength <0 && self._holdExtensible.object.scale.y >= 0:
#		self._holdExtensible.object.scale.y *= -1 ;
#	elif self._lastGapLength >=0 && self._holdExtensible.object.scale.y < 0:
#		self._holdExtensible.object.scale.y *= 1 ;
#
	pass

func _process(delta):
	#update()
#	var gapLength = self.gapLength() ;
#
#	if gapLength != self._lastGapLength:
#		self.updateHoldExtensiblePosition() ;
	pass
