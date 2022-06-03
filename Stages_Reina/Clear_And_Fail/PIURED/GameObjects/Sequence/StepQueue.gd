extends Node

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

#lmao
class StepInfo:
	var stepList:Array
	var timeStamp:float

	func constructor(stepList_:Array,timeStamp_:float):
		stepList=stepList_
		timeStamp=timeStamp_


var _stepDict ;

var HoldsStateC = preload("res://Stages_Reina/Clear_And_Fail/PIURED/HoldStructs.gd")

var activeHolds:HoldsState

var playerStage
var keyInput
var beatManager
var accuracyMargin

var checkForNewHolds:bool=true
var stepQueue:Array = []
var stepDict:Dictionary = {}

func constructor(playerStage, keyInput, beatManager, accuracyMargin, frameLog):

	#super(resourceManager) ;

	self.keyInput = keyInput ;

	self.playerStage = playerStage ;

	self.beatManager = beatManager ;

	self.accuracyMargin = accuracyMargin ;


	#Ayy lmao
	activeHolds = HoldsStateC.new()
	activeHolds.constructor([1])

	self.frameLog = frameLog ;


func update(delta):

	# console.log('tal') ;

	var currentAudioTime = self.beatManager.currentAudioTime;
	var currentBeat = self.beatManager.currentBeat;
	self.updateActiveHolds(currentAudioTime, delta, currentBeat);
	self.updateStepQueue(currentAudioTime);





#func input():
#
#	var pressedKeys = self.keyInput.getPressed() ;
#
#	for ( var [kind, padId] of pressedKeys :
#		# self.frameLog.logPadInput(kind,padId) ;
#		self.stepPressed(kind,padId) ;
#
#	}
#
#}


# THESE METHODS ARE CALLED WHEN CONSTRUCTING THE SCENE.

func addNewEntryWithTimeStampInfo( timeStamp:float ):

	var stepInfo = StepInfo.new()
	stepInfo.constructor([],timeStamp)
	#var stepInfo = new StepInfo([], timeStamp);
	self.stepQueue.append(stepInfo)

func cleanUpStepQueue():

	var newStepQueue = []
	for i in range(stepQueue.size()):
		if stepQueue[i].stepList.size()>0:
			newStepQueue.append(stepQueue[i])
	stepQueue=newStepQueue
#	self.stepQueue = self.stepQueue.filter(function (el:
#		return el.stepList.length > 0 ;
#	});

	self.resetHolds() ;

#This function is never called, so I have no idea what it's for
#func addStepToLastStepInfo (step):
#	self.stepQueue[self.stepQueue.length -1].stepList.push(step) ;

#step is either StepNote or StepHold type
func addStepToStepList ( step, index, i,j ):
	var stepId = PIURED_ID.getId( step.kind,step.padId, i,j ) ;
	step.id = stepId ;

	# save in the dict.
	self._stepDict[stepId] = step ;
	#save in the list.
	self.stepQueue[index].stepList.push(step) ;

#Why is this a function lol
func getLength()->int:
	return self.stepQueue.size() ;


func getStepTimeStampFromTopMostStepInfo()->float:
	return stepQueue[0].timeStamp ;

#lmao
func removeFirstElement():
	stepQueue.pop_front()


func removeElement(index):
	#self.stepQueue.splice(index,1) ;
	stepQueue.remove(index)


func getStepFromTopMostStepInfo (index):
	return self.stepQueue[0].stepList[index] ;

func getTopMostStepListLength():
	return self.stepQueue[0].stepList.length ;

func getTopMostStepsList():
	return self.stepQueue[0].stepList ;

func setHold(kind, padId, step):
	self.activeHolds.beginningHoldChunk = true ;
	self.activeHolds.lastAddedHold = step ;
	self.activeHolds.setHold(kind, padId, step) ;

func getHold( kind, padId )->StepHold:
	return activeHolds.getHold(kind, padId) ;

func resetHolds():
	#self.activeHolds = new HoldsState(self.keyInput.getPadIds()) ;
	activeHolds = HoldsStateC.new()
	activeHolds.constructor([1])


# ----------------------- THESE METHODS ARE CALLED EACH FRAME ---------------------- #


func updateActiveHolds(currentAudioTime, delta, beat):

	var validHold:StepHold = self.findFirstValidHold(currentAudioTime);

	# update hold Run.
	if validHold != null :
		if !self.activeHolds.holdRun:
			self.activeHolds.holdRun = true ;
			self.activeHolds.firstHoldInHoldRun = validHold ;
		
	else:
		self.activeHolds.holdRun = false ;
	

	# Hold contribution to the combo
	if validHold != null:

		var tickCounts = self.beatManager.currentTickCount ;

		self.judgeHolds(delta, currentAudioTime, beat, tickCounts) ;

		# Note that, to be exact, we have to add the remainder contribution of the hold that was not processed on the last
		# frame
	elif self.activeHolds.needFinishJudgment:
		var tickCounts = self.beatManager.currentTickCount ;
		var difference = self.activeHolds.judgmentTimeStampEndReference - self.activeHolds.cumulatedHoldTime ;
		self.endJudgingHolds(difference, tickCounts) ;
		self.activeHolds.cumulatedHoldTime = 0;
		self.activeHolds.needFinishJudgment = false;
	

	self.removeHoldsIfProceeds(currentAudioTime) ;


func updateStepQueue( currentAudioTime:float) :

	if self.getLength() > 0 :

		var stepTime:float = self.getStepTimeStampFromTopMostStepInfo() ;

		var difference:float = (stepTime) - currentAudioTime ;
		# this condition is met when we run over a hold. We update here the current list of holds
		if difference < 0 && self.checkForNewHolds:
			# console.log(onlyHoldsInTopMostStepInfo) ;

			self.checkForNewHolds = false ;

			self.addHolds() ;


			# if we only have holds, and all of them are being pressed beforehand, then it's a perfect!
			if self.areThereOnlyHoldsInTopMostStepInfo() && self.areHoldsBeingPressed() :

				self.needToAnimateReceptorFX(self.getTopMostStepsList()) ;
				self.playerStage.judgment.perfect() ;

				self.removeFirstElement() ;
				self.checkForNewHolds = true ;


		# we count a miss, if we go beyond the time of the topmost step info, given that there are no holds there
		if difference < -self.accuracyMargin :

			self.playerStage.judgment.miss() ;
			self.removeFirstElement() ;
			self.checkForNewHolds = true ;

func needToAnimateReceptorFX(stepList):
	self.frameLog.logAnimateReceptorFX(stepList) ;
	self.playerStage.animateReceptorFX(stepList) ;

func needToRemoveStep(step):
	self.frameLog.logRemoveStep(step) ;
	self.playerStage.removeStep(step) ;

# the boolean end is used to compute the remainder combo left after a set of holds.
func judgeHolds(delta, currentAudioTime, beat, tickCounts):


	self.activeHolds.cumulatedHoldTime += delta ;


	self.activeHolds.timeCounterJudgmentHolds += delta ;

	var secondsPerBeat:float = 60.0 / self.beatManager.currentBPM ;

	var secondsPerKeyCount:float = secondsPerBeat/ tickCounts ;

	var numberOfHits = floor(self.activeHolds.timeCounterJudgmentHolds / secondsPerKeyCount ) ;


	# console.log(numberOfPerfects) ;


	if numberOfHits > 0 :


		var aux = self.activeHolds.timeCounterJudgmentHolds ;
		#TODO: Does not work in Godot currently
		var remainder:int=0
		#var remainder = self.activeHolds.timeCounterJudgmentHolds % secondsPerKeyCount;
		self.activeHolds.timeCounterJudgmentHolds = 0 ;


		var difference =  abs((self.activeHolds.lastAddedHold.beginTimeStamp) - currentAudioTime) ;
		# case 1: holds are pressed on time
		if self.areHoldsBeingPressed():

			# TODO:
			# self.composer.judgmentScale.animateJudgement('p', numberOfHits);
			# self.composer.animateTapEffect(self.activeHolds.asList());
			self.needToAnimateReceptorFX(self.activeHolds.asList()) ;
			self.playerStage.judgment.perfect(numberOfHits) ;
			# console.log('perfect') ;
		# case 2: holds are not pressed. we need to give some margin to do it
		elif self.activeHolds.beginningHoldChunk && difference < self.accuracyMargin :

			self.activeHolds.timeCounterJudgmentHolds += aux -remainder ;

			# case 3: holds are not pressed and we run out of the margin
		else:

			self.playerStage.judgment.miss(numberOfHits) ;
			self.activeHolds.beginningHoldChunk = false ;
		


		self.activeHolds.timeCounterJudgmentHolds += remainder;

func endJudgingHolds(remainingTime, tickCounts):


		var secondsPerBeat = 60.0 / self.beatManager.currentBPM ;
		var secondsPerKeyCount = secondsPerBeat/ tickCounts ;

		var numberOfHits:int = floor(remainingTime / secondsPerKeyCount ) ;

		# console.log('end numberOfHits: ' + numberOfHits) ;


		if self.areHoldsBeingPressed() && self.activeHolds.wasLastKnowHoldPressed:

			self.needToAnimateReceptorFX(self.activeHolds.asList()) ;
			self.playerStage.judgment.perfect(numberOfHits) ;
			# console.log('perfect') ;
		else:
			# TODO: misses should not be in the same count.
			# TODO:
			# self.composer.judgmentScale.miss() ;
			# console.log('miss') ;
			self.playerStage.judgment.miss(numberOfHits) ;
		

		#reset
		self.activeHolds.timeCounterJudgmentHolds = 0 ;



func areThereOnlyHoldsInTopMostStepInfo()->bool:
	var lenn = self.getTopMostStepListLength() ;
	for i in range(lenn):
		var step = self.getStepFromTopMostStepInfo(i) ;
		if !(step is StepHold):
			return false ;
		
	
	return true ;



# remove holds that reached the end.
func removeHoldsIfProceeds(currentAudioTime):

	var listActiveHolds = self.activeHolds.asList() ;


	# This is used to know whether the last judgment for the hold must be fail or not.
	self.activeHolds.wasLastKnowHoldPressed = self.areHoldsBeingPressed() ;

	for i in range(listActiveHolds.size()):
		var step = listActiveHolds[i] ;

		if step != null && currentAudioTime > step.endTimeStamp :
			self.activeHolds.setHold(step.kind, step.padId, null) ;

			# save the endHoldTimeStamp to compute the remainder judgments.
			self.activeHolds.needFinishJudgment = true ;
			self.activeHolds.judgmentTimeStampEndReference = step.endTimeStamp - self.activeHolds.firstHoldInHoldRun.beginTimeStamp ;


			# if the hold is active, we can remove it from the render and give a perfect judgment, I think.
			if self.keyInput.isHeld(step.kind, step.padId):


				self.playerStage.judgment.perfect() ;

				self.needToRemoveStep(step) ;


				self.needToAnimateReceptorFX([step]) ;



			# otherwise we have a miss.
			else:
				self.playerStage.judgment.miss() ;



# update activeHolds using the topmost element of the stepQueue
func addHolds():

	# add new holds

	var length =  self.getTopMostStepListLength() ;
	# console.log(self.stepQueue.stepQueue[0]);
	for i in range(length):
		var note = self.getStepFromTopMostStepInfo(i) ;
		if note is StepHold:
			self.setHold(note.kind, note.padId, note);
			# console.log('hold added:' + note.held) ;




# ----------------------- THESE METHODS ARE CALLED WHEN A KEY IS PRESSED ---------------------- #


#So I guess suddenly it's totally okay not to use a struct even though
#all the other functions are?
#Returns [stepInfo, step, i, difference] or [null,null,null,null]
func getFirstStepWithinMargin(currentAudioTime:float, kind:String, padId:int)->Array:

	for i in range (stepQueue.size()):

		var stepInfo = self.stepQueue[i] ;
		var timeStamp = stepInfo.timeStamp ;

		var difference =  abs((timeStamp) - currentAudioTime) ;

		# console.log(difference) ;

		if difference < self.accuracyMargin :

			for j in range(stepInfo.stepList.size()):

				var step = stepInfo.stepList [j] ;

				if step.kind == kind && step.padId == padId:
					return [stepInfo, step, i, difference] ;
				

			

		else:
			return [null, null, null, null] ;
		

	
	return [null, null, null, null] ;



func stepPressed(kind, padId):


	var currentAudioTime = self.beatManager.currentAudioTime ;

	# keep track if there is an upcoming hold

	var tmp = self.getFirstStepWithinMargin(currentAudioTime, kind, padId) ;
	var stepInfo:StepInfo=tmp[0]
	var step=tmp[1]
	var hitIndex=tmp[2]
	var difference=tmp[3]


	# with the second condition, we make sure that we don't treat the holds here. Holds, when pressed
	# beforehand (anytime), count always as a perfect.
	if step != null :


		step.pressed = true;


		# If all steps have been pressed, then we can remove them from the steps to be rendered
		if self.areStepsInNoteListPressed(stepInfo.stepList):

			var grade = self.playerStage.judgment.grade(difference) ;

			#
			if grade == 'b' || grade == 'go':
				if step is StepHold:
					self.setHold(step.kind, step.padId, step) ;
				

			else:


				self.needToAnimateReceptorFX(stepInfo.stepList) ;
				self.needToAnimateReceptorFX(self.activeHolds.asList()) ;
				self.removeNotesFromStepObject(stepInfo.stepList) ;

			



			# remove front
			self.removeElement(hitIndex);

			self.checkForNewHolds = true;



# Returns true if all the steps have been pressed
func areStepsInNoteListPressed(noteList:Array)->bool:
	var length =  noteList.size() ;
	# var length =  self.getTopMostStepListLength() ;
	for i in range(length):

		var note = noteList[i] ;
		if note.pressed == false :
			if note is StepHold && self.keyInput.isHeld(note.kind, note.padId) :
				continue ;
			
			return false ;
		
	

	# Also check if the holds are being pressed.
	return self.areHoldsBeingPressed() ;




func areHoldsBeingPressed()->bool:

	var listActiveHolds = self.activeHolds.asList() ;
	for i in range(listActiveHolds.size()):
		var step = listActiveHolds[i] ;

		if step != null && self.keyInput.isHeld(step.kind, step.padId) :
			continue ;
			# listActiveHolds[i] = null ;
			# console.log('removed:' + listActiveHolds[i]) ;
		else:
			return false ;
		

	
	return true ;

# this means, holds that are not only in the activeHolds list, but on time to be triggered
func findFirstValidHold (currentAudioTime:float):

	var listActiveHolds = self.activeHolds.asList() ;
	for step in listActiveHolds:
		#var step = listActiveHolds[i] ;

		if step != null && step.beginTimeStamp <= currentAudioTime:
			return step ;
		
	
	return null ;

# this means, holds that are not only in the activeHolds list, but on time to be triggered
func areThereHolds (currentAudioTime:float)->bool:

	var listActiveHolds = self.activeHolds.asList() ;
	for i in range(listActiveHolds.size()):

		var step = listActiveHolds[i] ;

		if step != null :
			return true ;
		

	return false ;

# remove all steps in the noteList from the steps Object, so they are not rendered anymore
func removeNotesFromStepObject(noteList):


	var length =  noteList.length ;
	for i in range(length):
		var note = noteList[i] ;

		# remove the step if it's not a hold, obviously.
		if !(note is StepHold) :

			self.needToRemoveStep(note) ;
			# add it to the active holds early
		else:
			self.setHold(note.kind, note.padId, note) ;
