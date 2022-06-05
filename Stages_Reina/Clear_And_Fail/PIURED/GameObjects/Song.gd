extends AudioStreamPlayer

# StepMania's Song class, poorly coded in Godot
# by taking parts of StepMania and PIURED and gstep
# and mashing them together until they sort of barely work
# Keep in mind SSC is a god awful format with god awful backwards
# compatibility that shouldn't be necessary, for example a SSC has global
# timing data and then overrides it with step timing data if found

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

var SSCFilePath:String
var meta:Dictionary = {}
var steps:Array = []
var playBackSpeed:float=1.0
var syncTime:float=1.0
var requiresResync:bool=false
var readyToStart:bool=false
var delay:float=0.0

var globalTimingData


func constructor( pathToSSCFile, audioBuf, offset, playBackSpeed, onReadyToStart ):


	SSCFilePath = pathToSSCFile ;

	self.playBackSpeed = playBackSpeed ;

	self.syncTime = offset ;

	self.audioBuf = audioBuf ;

	self.onReadyToStart = onReadyToStart ;

	loadSSC(SSCFilePath)

func loadSSC(sscPath:String)->bool:
	print("Stubbed SSC loader!")
	sscPath="res:#Stages_Reina/Clear_And_Fail/Songs/Gargoyle/Gargoyle.json"
	#const parse = sscParser.parse(content) ;
	var save_game = File.new()
	if not save_game.file_exists(sscPath):
		return false
	save_game.open(sscPath, File.READ)
	var parse:Dictionary=parse_json(save_game.get_as_text())
	save_game.close()
	self.meta = parse.header ;
	self.steps = parse.steps ;
	return true


func getStepsDifficulty(stepsNum:int)->int:
	#No type checking yet so wrap in int()
	return int(self.steps[stepsNum].METER);

#PREPROCESSOR WHEN??????????
#Also these functions aren't supposed to be here
#in the first place, they're supposed to be in the Steps
#class. Too bad the Steps class isn't finished yet!
func getWARPS(stepsNum:int)->Array:
	#let arr ;
	if ( 'WARPS' in self.steps[stepsNum] ):
		return self.steps[stepsNum].WARPS
	elif ('WARPS' in self.meta):
		return self.meta['WARPS']
	return []



func getBPMs(stepsNum:int)->Array:
	if ( 'BPMS' in self.steps[stepsNum] ):
		return self.steps[stepsNum].BPMS ;
	else:
		return self.meta['BPMS'] ;

func getTickCounts(level:int)->Array:
	if ( 'TICKCOUNTS' in self.steps[level] ):
		return self.steps[level].TICKCOUNTS;
	elif ('TICKCOUNTS' in self.meta):
		return self.meta['TICKCOUNTS'] ;
	return [[0.0,4]]

func getScrolls(level)->Array:
	if ( 'SCROLLS' in self.steps[level] ):
		return self.steps[level].SCROLLS ;
	elif ( 'SCROLLS' in self.meta):
		return self.meta['SCROLLS'] ;
	return [[0.0,1.0]] ;
	

func getStops(level:int)->Array:
	if ( 'STOPS' in self.steps[level] ):
		return self.steps[level].STOPS ;
	elif ('STOPS' in self.meta):
		return self.meta['STOPS'] ;
	return []

func getDelays(level:int)->Array:
	if ( 'DELAYS' in self.steps[level] ):
		return self.steps[level].DELAYS;
	elif ( 'DELAYS' in self.meta):
		return self.meta['DELAYS'] ;
	return []

"""
This returns an array of arrays.
The default value is #SPEEDS:0.000000=1.000000=0.000000=0,
which means at the 0th measure, speed is 1.0x with an approach time of 0.0 beats (instant).
The final value is 0 or 1, 0 meaning beats and 1 meaning seconds. It's a boolean value, but
due to javascript absurdities we have to cast it first.
(When the SSC parser is finished there shouldn't be any more casting.)

Another example is
468.750000=0.250000=20.000000=0
At beat 468, switch speed to 0.25x, take 20 beats to scale it down

"""
func getSpeeds(level:int)->Array:
	if ( 'SPEEDS' in self.steps[level] ):
		return self.steps[level].SPEEDS;
	elif ( 'SPEEDS' in self.meta ):
		return self.meta['SPEEDS'] ;
	return [[0.0,1.0,0.0,0]]

func getOffset(level)->float:
	if ( 'OFFSET' in self.steps[level] ):
		return self.steps[level].OFFSET ;
	return self.meta['OFFSET'];
	
#func getBannerPath():
#	return self.pathToSSCFile.substr(0, self.pathToSSCFile.lastIndexOf("/")) + '/' + self.meta['BACKGROUND'] ;
#}

func getTickCountAtBeat(level, beat):
	var tickCounts = self.getTickCounts(level) ;
	var last = tickCounts[0][1];
	for tickCount in tickCounts:
		var beatInTick = tickCount[0] ;
		var tick = tickCount[1] ;
		if ( beat >= beatInTick ):
			last = tick ;
		else:
			return last ;
	return last ;

func getBPMAtBeat(level, beat)->float:

	var tickCounts = self.getBPMs(level) ;
	var last = tickCounts[0][1];
	for tickCount in tickCounts:
		var beatInTick = tickCount[0] ;
		var tick = tickCount[1] ;
		if ( beat >= beatInTick ):
			last = tick ;
		else:
			return last ;
	return last ;

func getSpeedAndTimeAtBeat(level, beat):

	var speeds = self.getSpeeds(level) ;
	var last = speeds[0];
	for speed in speeds:
		var beatInSpeed = speed[0] ;
		if ( beat >= beatInSpeed ):
			last = speed ;
		else:
			# we also return the type: time in seconds or beats.
			return [last[1],last[2], last[3]] ;
	return [last[1],last[2], last[3]] ;


func getLevelStyle(level)->String:
	return self.steps[level].STEPSTYPE ;



func getMusicPath()->String:
	print("Stubbed getMusicPath()!")
	#return this.pathToSSCFile.substr(0, this.pathToSSCFile.lastIndexOf("/")) + '/' + this.meta['MUSIC'] ;
	return 'res:#Stages_Reina/Clear_And_Fail/Songs/Gargoyle/15E5.mp3'

func setNewPlayBackSpeed ( newPlayBackSpeed ):
	self.source.playbackRate.value = newPlayBackSpeed ;
	self.playBackSpeed = newPlayBackSpeed ;
	# self.requiresResync = true ;


func startPlayBack(startDate:float):

	var currentDate:float = OS.get_unix_time()

	##           convert to secs
	self.delay = (startDate - currentDate) / 1000.0 ;


	#self.startTime = self.context.currentTime;

	self.startTime = 0.0;
	## console.log('start time: ' + self.startTime ) ;
	print('computed delay: ' + String(self.delay)) ;
	self.source.start(self.startTime + self.delay) ;
	self.readyToStart = true ;
	pass



func getCurrentAudioTime( level ):
	# return self.context.currentTime ;
	# console.log('Outside start time: ' + self.startTime) ;
	# self.steps[level].meta['OFFSET'] ;
	if ( self.readyToStart == false ):
		return -1.0 ;
	return self.context.currentTime - self.delay + self.getOffset(level)  - self.startTime - self.syncTime;
	# return self.startTime - self.audio.context.currentTime + parseFloat(self.meta['OFFSET']);
	#return self.audio.context.currentTime + self.startTime + parseFloat(self.meta['OFFSET']);

func getTotalOffset(level):
	return - self.delay + self.getOffset(level) - self.startTime;
