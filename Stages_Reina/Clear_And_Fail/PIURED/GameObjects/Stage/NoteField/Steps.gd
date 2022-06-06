extends Node2D
#WHAT THE HELL IS GOING ON????? - YIIK dude

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
#"use strict"; # good practice - see https:#developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Strict_mode


# Depth of stage elements
const receptorZDepth := -3 ;
const holdZDepth := -2 ;
const holdEndNoteZDepth := -1 ;
const stepNoteZDepth := 1;
	
var _object ;
var _noteskin ;
var dlXPos ;
var ulXPos ;
var cXPos ;
var urXPos ;
var drXPos ;
var receptorsApart ;
var stepTextureAnimationRate ;
var lastEffectSpeed ;
var effectSpeed ;
var effectSpeed2 ;
var newTargetSpeed ;
var stepQueue ;
var beatManager ;
var _speedTween ;
var padSteps:Dictionary ;
var stepList ;
var _song ;
var _level ;
var _userSpeed ;
var idLeftPad ;
var idRightPad ;
var keyListener ;


func _ready():
	set_process(false)

func constructor(
			stepQueue,
			beatManager,
			song,
			level:int=0,
			userSpeed:float=1.0,
			idLeftPad:int=1,
			idRightPad:int=2,
			keyListener=null,
			noteskin:String="Prime"):
	#super(resourceManager);


	# Set up positions for steps
	self.configureStepConstantsPositions() ;

	# For managing changes of SPEED (by tweening)
	self.lastEffectSpeed = 1;
	self.effectSpeed = 1;
	self.newTargetSpeed = 1 ;
	self._noteskin = noteskin ;

	#stepQueue to initialize (or use)
	self.stepQueue = stepQueue ;

	self.beatManager = beatManager ;
	self._song = song ;
	self._level = level ;
	self._userSpeed = userSpeed ;
	self.idLeftPad = idLeftPad ;
	self.idRightPad = idRightPad ;
	self.keyListener = keyListener ;

	#
	#self._object = new THREE.Object3D() ;

	# to store leftmost and rightmost steps.
	self.padSteps = {} ;
	self.stepList = [] ;

	configureStepConstantsPositions()
	self.constructSteps() ;


func constructSteps():

	# if level is single, then we construct only the 5 leftmost steps
	if self._song.getLevelStyle(self._level) == 'pump-single':
		self.composePad(0, self.idLeftPad) ;

	# clean empty step slots.
	self.stepQueue.cleanUpStepQueue() ;





func configureStepConstantsPositions ():

	# define position of the notes w.r.t. the receptor

	# Space to the right or left of a given step.
	var stepShift = 100;
	# Note that the receptor steps are a bit overlapped. This measure takes into
	# acount this overlap.
	var stepOverlap = 0.02 ;
	self.dlXPos =  -2*(stepShift - stepOverlap) ;
	self.ulXPos =  -(stepShift - stepOverlap) ;
	self.cXPos =  0 ;
	self.urXPos =  (stepShift - stepOverlap) ;
	self.drXPos =  2*(stepShift - stepOverlap) ;

	self.receptorsApart = 1.96 ;
	self.stepTextureAnimationRate = 30 ;


#PadId: 1,2,etc
func composePad(stepDataOffset:int=0, padId:int=1):


	# object containing all the steps of the given Pad.
	#var steps = new THREE.Object3D();

	var noteData:Array = self._song.steps[self._level].NOTES;
	print("Got notedata from Steps class, generating track...")
	print("There are "+String(noteData.size())+" measures in this track.")

	var listIndex = 0;
	# i loops the bars
	for i in range(noteData.size()):

		var measure = noteData[i];

		var notesInBar = measure.size();

		# j loops the notes inside the bar
		for j in range(notesInBar):

			listIndex += 1;
			var note = measure[j];

			# calculate current beat
			var beat = (4*i + 4*j/notesInBar) ;
			
			#var [currentYPosition, currentTimeInSong] = 
			var tmp:Array = self.beatManager.getYShiftAndCurrentTimeInSongAtBeat(beat);
			var currentYPosition = tmp[0]
			var currentTimeInSong = tmp[1]
			

			# Add only if the entry is not created already
			if listIndex > self.stepQueue.getLength():
				self.stepQueue.addNewEntryWithTimeStampInfo(currentTimeInSong);
			

			# dl
			self.processNote(
				note[0 + stepDataOffset],
				'dl',
				currentYPosition,
				self.dlXPos,
				currentTimeInSong,
				listIndex - 1,
				padId,
				i,
				j,
				beat);


			#ul
			self.processNote(
				note[1 + stepDataOffset],
				'ul',
				currentYPosition,
				self.ulXPos,
				currentTimeInSong,
				listIndex - 1,
				padId,
				i,
				j,
				beat);

			# c
			self.processNote(
				note[2 + stepDataOffset],
				'c',
				currentYPosition,
				self.cXPos,
				currentTimeInSong,
				listIndex - 1,
				padId,
				i,
				j,
				beat);

			# ur
			self.processNote(
				note[3 + stepDataOffset],
				'ur',
				currentYPosition,
				self.urXPos,
				currentTimeInSong,
				listIndex - 1,
				padId,
				i,
				j,
				beat);

			# dr
			self.processNote(
				note[4 + stepDataOffset],
				'dr',
				currentYPosition,
				self.drXPos,
				currentTimeInSong,
				listIndex - 1,
				padId,
				i,
				j,
				beat);


	print("Finished generating note track! There are "+String(get_child_count())+" notes spawned.")
	#return steps ;


#'N' for node... Because you can't name it the same as the class
const StepNoteN = preload("res://Stages_Reina/Clear_And_Fail/PIURED/GameObjects/Stage/Note/StepNote.tscn")
const StepHoldN = preload("res://Stages_Reina/Clear_And_Fail/PIURED/GameObjects/Stage/Note/StepHold.tscn")
"""
Godot doesn't support literals, but 'note' is a literal.
note:Literal['1','2','3'] etc. 1 is tap, 2 is hold start, 3 is hold end.
kind:Literal['dl','ul','c','ur','dr']
currentYPosition
XStepPosition
steps:&Array (Reference to an array)
"""
func processNote(note:String, kind:String, currentYPosition:float, stepXpos:float, currentTimeInSong, index,  padId:int, i,j, beat):


	# Process StepNote
	match note:
		'1','2':
			# var step = self.stepFactory.getStep(kind);
			var step = StepNoteN.instance()
			step.constructor(kind, padId, currentTimeInSong, self._noteskin )

			#add_child(step)
			#var stepMesh = step.object ;

			step.position=Vector2(stepXpos,currentYPosition)
			#stepMesh.position.y = currentYPosition ;
			step.originalYPos = currentYPosition ;
			#stepMesh.position.x = XStepPosition ;
			step.z_index = stepNoteZDepth ;
			print("Placed step at "+String(step.position))


			#Notice how this is NOT added as a child,
			#that's because it needs to calculate hold ends and it will
			#be added when the hold end is found.
			if note == '2':
				var stepHold = StepHoldN.instance()
				stepHold.constructor(kind, padId, currentTimeInSong, self._noteskin )
				

				stepHold.position=Vector2(stepXpos,currentYPosition)
				#stepMesh.position.y = currentYPosition ;
				stepHold.originalYPos = currentYPosition ;
				#stepMesh.position.x = XStepPosition ;
				stepHold.z_index = stepNoteZDepth ;
				
				#var stepHold = new StepHold(self._resourceManager, step, kind ) ;

				# don't add steps into the stepqueue if they are inside a warp section
				if !self.beatManager.isNoteInWarp(beat):
					self.stepQueue.addStepToStepList(stepHold, index, i,j) ;
				self.stepQueue.setHold(kind, padId, stepHold) ;
				self.stepList.append(stepHold) ;
			else:
				# don't add steps into the stepqueue if they are inside a warp section
				if !self.beatManager.isNoteInWarp(beat):
					self.stepQueue.addStepToStepList(step, index, i, j);
				
				add_child(step)
				#steps.add(stepMesh) ;
				self.stepList.append(step) ;
		'3':
			var holdObject = self.stepQueue.getHold( kind , padId ) ;

			holdObject.constructHoldExtensible(currentYPosition) ;

			holdObject.endTimeStamp = currentTimeInSong ;
			add_child(holdObject) ;

func updateCurrentSpeed():

	self.effectSpeed = self.beatManager.getCurrentSpeed() ;

func animateSpeedChange():

	if self.lastEffectSpeed != self.effectSpeed:

		var effectSpeed = self.effectSpeed ;

		for step in stepList:

			if step is StepNote:
				# apply new speed
				step.position.y = effectSpeed*step.originalYPos;
			elif step is StepHold:
				step.position.y = effectSpeed*step.originalYPos ;
				step.endBeat = step.originalEndBeat*effectSpeed ;
			
		self.lastEffectSpeed = effectSpeed ;

func updateActiveHoldsPosition():

	var listActiveHolds = self.stepQueue.activeHolds.asList() ;

	for i in range(listActiveHolds.size()):
		var step = listActiveHolds[i] ;
		# check if hold is pressed.
		if self.keyListener.isHeld(step.kind, step.padId):
			self.updateHoldPosition(step) ;

func updateHoldPosition(hold:StepHold):

	var distanceToOrigin =  -self.position.y - hold.position.y ;

	# update step note position
	hold.position.y += distanceToOrigin ;


func removeStep(step:StepNote):
	print("removeStep() stub! Was asked to remove StepNote from rendering")
	#self.padSteps[step.padId].remove(step) ;


func _process(delta):
	if not is_instance_valid(beatManager):
		print("Can't process without beatManager! call steps.constructor()!")
		return

	self.updateCurrentSpeed() ;

	self.animateSpeedChange() ;

	self.position.y = self.beatManager.currentYDisplacement * self._userSpeed * self.effectSpeed ;

	# important, last thing to update.
	self.updateActiveHoldsPosition() ;
