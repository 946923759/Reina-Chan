extends Node
# Better known as ScoreKeeper on StepMania

"""
This is loosely based on StepMania's JudgmentMessage
PlayerNumber: 1 or 2
isOnline: Always false (We don't have online support obviously)
FirstColumn: The first column this note appeared on, if it's a jump. Otherwise just the column this note was hit on.
TapNoteScore: Broadcasts the judgment, which is a literal 'p', 'gr', 'go', 'b', 'm', or "" if it's a hold.
Early: true if hit early, false if hit late.
TapNoteOffset: offset of when you hit it and when you were supposed to hit it, in floats.
ComboCount: duh
HoldNoteScore: "" if not a hold note, otherwise the score as a literal (Same as TapNoteScore)
"""
signal JudgmentMessage(PlayerNumber,isOnline,FirstColumn,TapNoteScore,Early,TapNoteOffset,ComboCount,HoldNoteScore)



# /*
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

var playerNumber:int=1
var _judgment:Node2D ;
var _lifeBar:Node2D ;

#I'm not entirely sure what this is used for, to be honest
var _state = 0 ;
var _counter = 0 ;

var _barSteps = 60 ;
var _currentStep = 30 ;
var _frameLog ;

var accuracyMargin:float
var levelStyle:String;
var levelDifficulty:int=0;

var comboCount:int=0;
var missComboCount;
var stats:Dictionary;
var score;
var generalScoreMultiplier ;

func setResources(lifeBar:Node2D,judgment:Node2D):
	_lifeBar = lifeBar
	_judgment = judgment

func constructor(playerNumber:int, accuracyMargin, stepsType, levelDifficulty):

	self.accuracyMargin = accuracyMargin ;
	self.levelStyle = stepsType ;
	self.levelDifficulty = levelDifficulty ;
	#self._frameLog = frameLog ;

	ready()


func ready():

	# score multiplier
	self.generalScoreMultiplier = 1.0 ;

	if (self.levelDifficulty > 10):
		self.generalScoreMultiplier *= self.levelDifficulty/10.0 ;
	
	if (self.levelStyle == 'pump-double'):
		self.generalScoreMultiplier *= 1.2 ;
	

	self.comboCount = 0 ;
	self.missComboCount = 0 ;
	self.score = 0 ;
	self.stats = {
		p=0,
		gr=0,
		go=0,
		b=0,
		m=0,
		maxCombo=0,
		score=0,
		grade=''
	}

func _process(delta):
	if (self._currentStep <= 0):
		self._currentStep = 0 ;
	

func updateCombo(value):
	self.comboCount = value ;
	if (self.comboCount > self.stats.maxCombo):
		self.stats.maxCombo = self.comboCount ;
	
func broadcastJudgment(stepColumn:String,grade:String,timeStamp:float,curCombo:int):
	#JudgmentMessage(PlayerNumber,isOnline,FirstColumn,TapNoteScore,Early,TapNoteOffset,ComboCount,HoldNoteScore)
	emit_signal("JudgmentMessage",playerNumber,false,stepColumn,grade,timeStamp<0,timeStamp,curCombo,0)
	pass

# TODO:
func miss ( comboIncrement = 1 ):
	self.updateCombo(0) ;
	self.missComboCount += comboIncrement ;
	self.stats.m += comboIncrement;
	self.addJudgmentToScore(-500) ;
	#self._judgment.animate('m',self.comboCount) ;


	if (self._currentStep > 60 ):
		self._state = 5;
		self._counter = 0;
		self._currentStep = 60 ;
	

	if ( self._state == 5 ):
		if ( self._counter >=3 ):
			self._currentStep = 54 ;
			self._state = 0 ;
			self._counter = 0 ;
		else:
			self._counter += 1 ;
		
	else:
		self._currentStep -= 6 ;
		self._counter = 0 ;
		self._state = 0 ;
	

	#self._lifeBar.setsize( self._currentStep/self._barSteps ) ;

	#self._frameLog.logJudgment( 'm',self.comboCount, self._currentStep ) ;

func bad ():
	self.missComboCount = 0;
	self.updateCombo(0) ;
	self.stats.b += 1;
	self.addJudgmentToScore(-200) ;
	#self._judgment.animate('b',self.comboCount) ;

	self._state = 0 ;
	self._counter = 0 ;

	#self._frameLog.logJudgment( 'b',self.comboCount, self._currentStep ) ;

func good ( ):
	self.missComboCount = 0 ;
	self.stats.go += 1;
	self.addJudgmentToScore(100) ;
	#self._judgment.animate('go',self.comboCount) ;

	self._state = 0 ;
	self._counter = 0 ;

	#self._frameLog.logJudgment( 'go',self.comboCount, self._currentStep ) ;

func great ( ):
	self.missComboCount = 0;
	self.stats.gr += 1;
	self.updateCombo(self.comboCount + 1) ;
	self.addJudgmentToScore(500) ;
	#self._judgment.animate('gr',self.comboCount) ;

	if (self._state == 5 ):
		self._state = 0 ;
	

	self.counterUpdatePerfect(7,0,1,0) ;

	#self._frameLog.logJudgment( 'gr',self.comboCount, self._currentStep ) ;

func perfect ( comboIncrement = 1 ):
	self.missComboCount = 0 ;
	self.stats.p += comboIncrement;
	self.updateCombo(self.comboCount + comboIncrement) ;
	self.addJudgmentToScore(1000) ;
	#self._judgment.animate('p',self.comboCount) ;

	if (self._state == 5 ):
		self._state = 0 ;
	


	self.counterUpdatePerfect(7,0,1, comboIncrement) ;
	self.counterUpdatePerfect(6,1,2, comboIncrement) ;
	self.counterUpdatePerfect(4,2,3, comboIncrement) ;
	self.counterUpdatePerfect(2,3,3, comboIncrement) ;

	#self._frameLog.logJudgment( 'p',self.comboCount, self._currentStep ) ;

func counterUpdatePerfect(updateCondition, fromState, toState, comboIncrement):
	if ( self._state == fromState):
		if (self._counter < updateCondition-1 ):
			self._counter += comboIncrement ;
		else:
			self._currentStep += 1 ;
			self._counter = 0 ;
			self._state = toState ;
			#self._lifeBar.setsize( self._currentStep/self._barSteps ) ;
				

func addJudgmentToScore(points):

	var multiplier = 1.0 ;
	var bonus = 0 ;
	if (self.comboCount > 50):
		bonus = 1000 ;
	

	self.score += (points+bonus)*self.generalScoreMultiplier*multiplier ;



func grade(step:StepNote,timeElapse:float)->String:

	var tiersTime = self.accuracyMargin / 8;
	var tier = int(floor( abs(timeElapse) / tiersTime )) ;

	var grade:String = "b" ;

	match tier:
		0,1,2:
			self.perfect() ;
			grade = 'p' ;
		3,4:
			self.great() ;
			grade =  'gr' ;
		5,6:
			self.good() ;
			grade =  'go' ;
		7:
			self.bad() ;
			grade =  'b' ;
		_:
			print("Hey moron, there's no match for "+String(tier))
	print(String(tier)+" "+String(step.kind)+" "+grade+" "+String(timeElapse)+" "+String(comboCount))
	#func broadcastJudgment(stepColumn:String,grade:String,timeStamp:float,comboCount:int):
	broadcastJudgment(step.kind,grade,timeElapse,comboCount)
	return grade ;

#This is not used for offline play, but it doesn't matter because 
#even if it was it would be replicated using Godot's signals anyways
# func setJudgment(grade, combo, step):
# 	self.updateCombo(combo) ;
# 	self._currentStep = step ;
# 	self._lifeBar.setsize( self._currentStep/self._barSteps ) ;
# 	self._judgment.animate( grade, self.comboCount );

func get_performance()->Dictionary:

	self.computeFinalGrade() ;
	self.stats.score = self.score;
	if (self.stats.grade == 'SSS'):
		self.stats.score += 300000 ;
	elif ( self.stats.grade =='SS'):
		self.stats.score += 150000 ;
	elif (self.stats.grade == 'S' ):
		self.stats.score += 100000 ;
	
	return self.stats ;

func computeFinalGrade():
	print("computeFinalGrade() stub!")
	self.stats.grade='SSS'

# func computeFinalGrade():
# 	var {p, gr, go, b, m, maxCombo} = self.stats;
# 	if (gr == 0 && go == 0 && b == 0 && m == 0) {
# 		self.stats.grade = 'SSS';
# 	elif (go == 0 && b == 0 && m == 0) {
# 		self.stats.grade = 'SS';
# 	else:
# 		var accuracy = ((p*1.0)+(gr*0.8)+(go*0.6)+(maxCombo*0.025)-(b*1.0)-(m*2.0))/(p+gr+go+b+m) ;
# 		if (accuracy > 1.0) {
# 			self.stats.grade = 'S' ;
# 		elif (accuracy > 0.9) {
# 			self.stats.grade = 'A' ;
# 		elif (accuracy > 0.85) {
# 			self.stats.grade = 'B' ;
# 		elif (accuracy > 0.8) {
# 			self.stats.grade = 'C' ;
# 		elif (accuracy > 0.75) {
# 			self.stats.grade = 'D' ;
# 		else:
# 			self.stats.grade = 'F' ;
# 		}
# 	}
# }
