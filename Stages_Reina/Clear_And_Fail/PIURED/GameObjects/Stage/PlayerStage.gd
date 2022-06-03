extends Node2D
"""
PlayerStage - It holds the players!
But what is a player, you ask?
A player is:
 * A NoteField Object
   * Contains Receptors, notefield, notes inside it.
 * Judgment graphics vertically aligned to the middle
 * A lifebar at the top
 
 One may ask if a lifebar should be tied to the top since in StepMania custom lifebars are used
 For NotITG or other cool charts, but since this is just for Reina-Chan it's fine for now.
 - Amaryllis Works
"""

# /*
#  * # Copyright (C) Pedro G. Bascoy
#  # This file is part of piured-engine <https:#github.com/piulin/piured-engine>.
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
#  # along with piured-engine.If not, see <http:#www.gnu.org/licenses/>.
#  *
#  */

onready var lifebar = $Lifebar
onready var judgment = $Judgment
func _ready():
	$Judgment.position=Globals.SCREEN_CENTER
	$Lifebar.position=Vector2(Globals.SCREEN_CENTER_X,40)
	
#	self.configureStepConstantsPositions() ;
#
#	self.constructLifeBar() ;
#
#	self.constructJudgment() ;
#
#	self.constructStepQueue() ;
#
#	self.constructSteps() ;
#
#	self.constructReceptors() ;


var _id:int ;
var _song:String ;
var _level:int;
var _steps;
const keyboardLag:float = 0.07
var playbackSpeed:float=1.0; #TODO: Should be kept in ScreenGameplay
var lifebarOrientation:String #TODO: This should be an enum


func constructor(song,
				playerConfig,
				playBackSpeed,
				lifebarOrientation = 'left2right'):

	# Save properties.
	self.playerConfig = playerConfig ;
	self._song = song ;
	self._level = playerConfig.level ;
	self._userSpeed = playerConfig.speed ;
	#self._id = id ;
	self._noteskin = playerConfig.noteskin ;
	self.accuracyMargin = playerConfig.accuracyMargin ;
	self.lifebarOrientation = lifebarOrientation ;
	self.playBackSpeed = playBackSpeed ;

	#
	self.padReceptors = { } ;

	self.configureBeatManager() ;

	self.configureInputPlayerStage(playerConfig.inputConfig) ;


func configureBeatManager():
	# creates a new beat manager with the options of the player
	self.beatManager = new BeatManager(self._resourceManager,
		self._song,
		self._level,
		self._userSpeed,
		self.keyboardLag,
		self.playBackSpeed) ;

configureKeyInputPlayerStage(inputConfig) {

	# Create a KeyInput object
	let playerInput = new KeyInput(self._resourceManager, self.frameLog)  ;

	# Pad ids are used for identifying steps in double-style.
	let pad1Id = '0' ;
	let pad2Id = '1' ;

	# We create two pads. Theoretically, more than 2 pads can be added, but in practice we only have either one or two.
	playerInput.addPad(inputConfig.lpad, pad1Id) ;
	playerInput.addPad(inputConfig.rpad, pad2Id) ;

	# We store the input as a keyListener
	self.keyListener = playerInput ;
	self.idLeftPad = pad1Id ;
	self.idRightPad = pad2Id ;

	# We add the KeyInput to the stage (nothing to draw, in this case).
	self._object.add(playerInput.object) ;
}

# func configureTouchInputPlayerStage(inputConfig):

#     # Create a TouchInput object
#     let playerInput = new TouchInput(self._resourceManager, self.frameLog, self._noteskin) ;

#     # We create two pads. Theoretically, more than 2 pads can be added, but in practice we only have either one or two.
#     let pad1Id = '0' ;
#     let pad2Id = '1' ;

#     # We add  the first touchpad (pump-single)
#     playerInput.addTouchPad(pad1Id) ;

#     # We only add the other pad if the player selected a pump-double or pump-halfdouble level.
#     if ( self._song.getLevelStyle(self._level) === 'pump-double' || self._song.getLevelStyle(self._level) === 'pump-halfdouble') {
#         playerInput.addTouchPad(pad2Id) ;
#     }

#     # We place the touchpad relative to the stage.
#     playerInput.setScale( inputConfig.scale ) ;
#     playerInput.object.position.x += inputConfig.X ;
#     playerInput.object.position.y += inputConfig.Y ;

#     # We store the input as a keyListener
#     self.keyListener = playerInput ;
#     self.idLeftPad = pad1Id ;
#     self.idRightPad = pad2Id ;

#     # We add the KeyInput to the stage (nothing to draw, in this case).
#     self._object.add(playerInput.object) ;


# configureRemoteInputPlayerStage(inputConfig) {
#     let playerInput = new IInput(self._resourceManager, self.frameLog) ;
#     let pad1Id = '0' ;
#     let pad2Id = '1' ;
#     playerInput.addPad(pad1Id) ;
#     # if ( self._song.getLevelStyle(self._level) === 'pump-double' || self._song.getLevelStyle(self._level) === 'pump-halfdouble') {
#     playerInput.addPad(pad2Id) ;
#     # }

#     self.keyListener = playerInput ;
#     self.idLeftPad = pad1Id ;
#     self.idRightPad = pad2Id ;
# }

configureInputPlayerStage(inputConfig) {
	self.configureKeyInputPlayerStage(inputConfig) ;
}

setNewPlayBackSpeed ( newPlayBackSpeed ) {
	self.beatManager.setNewPlayBackSpeed(newPlayBackSpeed) ;
}

constructStepQueue() {
	if (self.playerConfig.inputConfig instanceof RemoteInput ) {
		self.stepQueue = new IStepQueue(self._resourceManager, this, self.keyListener, self.beatManager, self.accuracyMargin) ;
	} else {
		self.stepQueue = new StepQueue(self._resourceManager, this, self.keyListener, self.beatManager, self.accuracyMargin, self.frameLog) ;
		engine.addToInputList(self.stepQueue) ;
	}

}

removeStep(step) {
	self._steps.removeStep(step) ;
}


animateReceptorFX(stepList) {
	for (var step of stepList) {
		self.padReceptors[step.padId].animateExplosionStep(step) ;
	}
}

logFrame(json) {
	self.keyListener.applyFrameLog(json) ;
	self.stepQueue.applyFrameLog(json) ;
}
