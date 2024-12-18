extends Node
var checkpointSet:bool=false

var lastCheckpointPos:Vector2
#I don't know when to use PoolIntArray or Array but the camera function currently takes arrays only so whatever
var lastCameraBounds:Array

var lastWeaponMeters:PoolIntArray

#You can change this to true if you want to debug, clearEverything() will reset it anyways
var watchedBossIntro:bool = OS.is_debug_build()

#To check for cheated time attack scores
var usedDebugMode:bool=false

#If the player should face left when respawning
var shouldFaceLeft:bool=false

#Should this be stored here? Maybe Globals makes more sense?
const playerStartingLifeCount = 3
var playerLivesLeft:int=3

# Store anything you want here!
# Used in Ouroboros' stage to unlock the miniboss door after dying.
# Used in Sangvis3 to store the boss defeat status.
# For you beginner programmers: 
# - To set true, use temporaryStageStats |= (1<<i)
# - To set false, use temporaryStageStats &= ~(1<<i). It's usually less effort to invert, though.
# - To invert a bit, use temporaryStageStats ^= (1<<i)
# - To get, use temporaryStageStats & 1<<i (notice the single &)
var temporaryStageStats:int=0


#It doesn't really belong in Globals... Anyways, this is only used for the item get screen
var lastPlayedStage:int=0

#This is used for the third sangvis stage for the minimap. Yeah. Literally only that one.
var visited_rooms = {}

#Timer gets assigned every checkpoint, but timerWithDeath should
#get assigned every death

var timer:float
var timerWithDeath:float

#So let's say the player died with a timer of 45.00, but 30.00 
#was where he resumed from the checkpoint
#If he dies at 31.00 then it's newTimer-timer for timerWithDeath
func setDeathTimer(newTimer):
	assert(newTimer-timerWithDeath>=0,"Death timer was negative!")
	timerWithDeath+=newTimer-timerWithDeath

func setTimer(newTimer):
	assert(newTimer > timer,"the new checkpoint timer is less than the old one!")
	timer=newTimer

#func getTimeWithDeath(curTimer):
#	if timerWithDeath==0.0:
#		return curTimer
#	return timerWithDeath

func clearEverything():
	lastCheckpointPos=Vector2()
	lastCameraBounds=[]
	lastWeaponMeters=[]
	timer=0.0
	timerWithDeath=0.0
	watchedBossIntro=false
	checkpointSet=false
	playerLivesLeft=3
	shouldFaceLeft=false
	temporaryStageStats=0
	lastPlayedStage=0
	visited_rooms = {}
