extends Node2D
"""
PlayerStage - It holds each player!
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
onready var stepQueue = $NoteField
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


#Each player must have its own BeatManager so per-step timing can be calculated.
var BeatManager = load("res://Stages_Reina/Clear_And_Fail/PIURED/GameObjects/BeatManager/BeatManager.gd")

var playerConfig:Dictionary
var beatManager
var _id:int=1 ;
var _song:AudioStreamPlayer ;
var _level:int=0;
var _steps;
const keyboardLag:float = 0.07
var _userSpeed:float=1.0
var _noteskin:String
var accuracyMargin:float
var playbackSpeed:float=1.0; #TODO: Should be kept in ScreenGameplay
var lifebarOrientation:String #TODO: This should be an enum


func constructor(song,
				playerConfig,
				playBackSpeed:float=1.0,
				myStageIndex:int=1, #If P1 or P2, 1 indexed.
				lifebarOrientation:String = 'left2right'):

	# Save properties.
	self.playerConfig = playerConfig ;
	self._song = song ;
	self._level = playerConfig.level ;
	self._userSpeed = playerConfig.speed ;
	self._id = myStageIndex ;
	self._noteskin = playerConfig.noteskin ;
	self.accuracyMargin = playerConfig.accuracyMargin ;
	self.lifebarOrientation = lifebarOrientation ;
	self.playbackSpeed = playBackSpeed ;

	self.configureBeatManager() ;

	self.configureInputPlayerStage(playerConfig.inputConfig) ;

	constructStepQueue()


func configureBeatManager():
	print("Spawning new BeatManager to manage timing for steps given")
	# Creates a new beat manager with the options of the player.
	# Each player must have its own BeatManager so per-step timing can be calculated.
	self.beatManager = BeatManager.new() ;
	beatManager.constructor(
		self._song,
		self._level,
		self._userSpeed,
		self.keyboardLag,
		self.playbackSpeed
	);

func configureKeyInputPlayerStage(inputConfig):
	print("configureKeyInputPlayerStage() stub!")
	pass

#	# Create a KeyInput object
#	let playerInput = new KeyInput(self._resourceManager, self.frameLog)  ;
#
#	# Pad ids are used for identifying steps in double-style.
#	let pad1Id = '0' ;
#	let pad2Id = '1' ;
#
#	# We create two pads. Theoretically, more than 2 pads can be added, but in practice we only have either one or two.
#	playerInput.addPad(inputConfig.lpad, pad1Id) ;
#	playerInput.addPad(inputConfig.rpad, pad2Id) ;
#
#	# We store the input as a keyListener
#	self.keyListener = playerInput ;
#	self.idLeftPad = pad1Id ;
#	self.idRightPad = pad2Id ;
#
#	# We add the KeyInput to the stage (nothing to draw, in this case).
#	self._object.add(playerInput.object) ;

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

func configureInputPlayerStage(inputConfig):
	self.configureKeyInputPlayerStage(inputConfig) ;

func setNewPlayBackSpeed ( newPlayBackSpeed ):
	self.beatManager.setNewPlayBackSpeed(newPlayBackSpeed);

func constructStepQueue():
	#self.stepQueue = $NoteField
	stepQueue.constructor(self, null, self.beatManager, self.accuracyMargin, null) ;
	#engine.addToInputList(self.stepQueue) ;


func logFrame(json):
	self.keyListener.applyFrameLog(json) ;
	self.stepQueue.applyFrameLog(json) ;
