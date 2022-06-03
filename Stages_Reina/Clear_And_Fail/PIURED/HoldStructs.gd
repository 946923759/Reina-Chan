
class_name HoldsState
#/*
# * # Copyright (C) Pedro G. Bascoy
# # This file is part of piured-engine <https:#github.com/piulin/piured-engine>.
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
# # along with piured-engine.If not, see <http:#www.gnu.org/licenses/>.
# *
# */


# Data structure that supports the StepQueue functionality
# It holds at a given time, the current holds and their state.
class Holds:
	var padId:int
	
	#No idea what this is for
	var dl:StepHold
	var ul:StepHold
	var c:StepHold
	var ur:StepHold
	var dr:StepHold

	func constructor(padId_:int):
		padId=padId_

	func setHold (kind:String, value:StepHold):
		match kind:
			'dl':
				self.dl = value ;
				
			'ul':
				self.ul = value ;
				
			'c':
				self.c = value ;
				
			'ur':
				self.ur = value  ;
				
			'dr':
				self.dr = value ;
				

	func getHold(kind:String)->StepHold:
		match kind:
			'dl':
				return self.dl ;
				
			'ul':
				return self.ul ;
				
			'c':
				return self.c ;
				
			'ur':
				return self.ur  ;
				
			'dr':
				return self.dr ;
		#Fallback
		return self.dl;


	func asList()->Array:
		var list = [] ;
		if self.dl != null:
			list.append(self.dl) ;
		
		if self.ul != null:
			list.append(self.ul) ;
		
		if self.c != null:
			list.append(self.c) ;
		
		if self.ur != null:
			list.append(self.ur) ;
		
		if self.dr != null:
			list.append(self.dr) ;
		
		return list ;
		
# Data structure that supports the StepQueue functionality
# It holds at a given time, the current holds and their state.

# All these values are directly updated by the StepQueue

# This stores the amount of time that a hold has been run (pressed or not).
# It is used to calculate the remainder steps to add to the judgment.
var cumulatedHoldTime:float = 0.0 ;

# This flag states whether a judgment is needed after the hold has reached the end
var needFinishJudgment:bool = false;

# it holds the elapsed time between the first and last hold in the hold run (sequence).
var judgmentTimeStampEndReference:float = 0.0 ;

# It keeps the time elapsed between frames in order to judge a hold.
var timeCounterJudgmentHolds:float = 0.0 ;

# It states whether the hold was pressed until the end.
var wasLastKnowHoldPressed:bool = true ;

#
var beginningHoldChunk:bool = false ;

# Keeps track of the last Hold added
var lastAddedHold = null ;

# States if we are currently in a hold run
var holdRun:bool = false ;

# Keeps the first hold Object3D of the hold run
var firstHoldInHoldRun = null ;


#Indexed by int (1 or 2)
var holdsDict:Dictionary = {}
var holds:Array = []
	
func constructor(padIds:Array):

	#We need one holds instance for each pad.
	for id in padIds:
		var h = Holds.new()
		h.constructor(id)
		#Why does it have two references????????? -AmWorks
		self.holds.append(h) ;
		self.holdsDict[id] = h ;



func setHold (kind:String, padId:int, value:StepHold):
	# console.log(padId);
	self.holdsDict[padId].setHold(kind,value) ;


func getHold (kind:String, padId:int)->StepHold:
	return self.holdsDict[padId].getHold(kind) ;



func asList()->Array:
	var list = [] ;
	for hold in holds:
		list.append_array(hold.asList()) ;
	
	return list ;


