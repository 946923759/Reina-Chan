extends AnimatedSprite
class_name StepNote

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


var _kind:String ; #DR, DL, C, UL, UR. No idea why this is needed. I guess PIURED makes no distinction between columns?
var _padId ; #Not sure why this is needed either, if it's in column 6 or above it would be P2 no?

#???
var originalYPos:float

"""
In PIU, co-op notes (P2, P3, P4) are just noteskin overrides.
But this is here just in case we want to handle judging a P2 note
on P1 side in the future, such as handling co-op with separate scoring.
"""
var forWhichPlayer:int=1

#'Vanish' means the note will vanish halfway up... Well, it's supposed
#to be adjustable but Godot shaders are super jank
#'Appear' - It appears halfway up
#'Stealth' - This note doesn't appear
enum NoteDisplay {NORMAL, VANISH, APPEAR, STEALTH}

var noteDisplay = NoteDisplay.NORMAL
var isFakeNote:bool=false

var _timeStamp ;
var _pressed:bool=false ;

var id:String ;

func constructor(kind:String, padId:int, timeStamp:float, noteskin:String, noteDisplay=0,isFake=false):

	self._kind = kind ;
	self._padId = padId ;
	#this._mesh = this._resourceManager.constructStepNote( this._kind, noteskin ) ;
	self._timeStamp = timeStamp ;
	
	self.noteDisplay=noteDisplay
	isFakeNote=isFake
