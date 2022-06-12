extends AudioStreamPlayer
#class_name Song

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
var audioBuf:String
var meta:Dictionary = {}
var steps:Array = []
var playBackSpeed:float=1.0
var globalOffset:float=0.0
var requiresResync:bool=false
var readyToStart:bool=false
var delay:float=0.0

var globalTimingData


func constructor(
	pathToSSCFile:String="res://Stages_Reina/Clear_And_Fail/Songs/Breaking The Habit/song.ssc",
	#audioFilePath:String="res://Stages_Reina/Clear_And_Fail/Songs/Breaking The Habit/song.ogg",
	offset:float=1.0,
	playBackSpeed:float=1.0):

	print("Loading SSC!")

	SSCFilePath = pathToSSCFile ;

	self.playBackSpeed = playBackSpeed ;

	self.globalOffset = offset ;

	#self.audioBuf = audioFilePath ;

	#self.onReadyToStart = onReadyToStart ;

	loadSSC(SSCFilePath)
	print("Load SSC fin! "+String(steps.size())+" charts have been loaded.")
	var songPath = meta["MUSIC"]
	print("Got song path: "+songPath)
	var last = pathToSSCFile.find_last("/")
	songPath = pathToSSCFile.substr(0,last)+"/"+songPath
	print("Real path is "+songPath)
	print("Got meter: "+String(steps[0].METER))

	print("Loading song!")
	self.stream = ExternalAudio.loadfile(songPath)

func loadSSC(sscPath:String)->bool:
	
	var parse:Dictionary
	
	if true:
		parse = loadSSC_real(sscPath)
	else:
		print("Stubbed SSC loader!")
		#sscPath="res://Stages_Reina/Clear_And_Fail/Songs/Breaking The Habit/song.json"
		#const parse = sscParser.parse(content) ;
		var save_game = File.new()
		if not save_game.file_exists(sscPath):
			return false
		save_game.open(sscPath, File.READ)
		parse=parse_json(save_game.get_as_text())
		save_game.close()


	self.meta = parse.header ;
	self.steps = parse.steps ;


	return true

enum CurrentlyParsing {
	HEADER
	PER_STEPS_DATA,
	NOTEDATA
}

static func insertIntoHeaderOrSteps(dictByReference:Dictionary,k:String,val,currentlyParsing:int,curSteps:int):
	if currentlyParsing==CurrentlyParsing.PER_STEPS_DATA:
		dictByReference['steps'][curSteps][k]=val
	else:
		dictByReference['header'][k]=val

static func loadSSC_real(sscPath:String)->Dictionary:

	var sscData:Dictionary = {"header":{},"steps":[]}
	
	var f = File.new()
	if not f.file_exists(sscPath):
		print("There is no SSC at "+sscPath+". Now the game will crash.")
		return sscData
	f.open(sscPath, File.READ)

	var line:String = ""
	var curParse = CurrentlyParsing.HEADER
	var curSteps:int = 0
	var curNotesMeasure:int=0

	while !f.eof_reached():
		if curParse == CurrentlyParsing.NOTEDATA:
			line = f.get_line().strip_escapes()
			if line.begins_with("//"):
				continue
			elif line.begins_with(","): #End of current measure
				curNotesMeasure+=1
				sscData['steps'][curSteps]["NOTES"].append([])
			elif line.begins_with(";"):
				print("Finished parsing notes block with "+String(curNotesMeasure)+" measures.")
				curParse=CurrentlyParsing.PER_STEPS_DATA
				line=""
			else:
				#https://github.com/RhythmLunatic/stepmania/blob/550b13c4aab9d3e0be66b4baae6865472aee5647/src/NoteDataUtil.cpp#L123-L163
				var p:int = 0; #pointer... I guess
				var endLine:int = len(line)
				var isBadLine:bool=false
				
				var notes:Array=[]
				while p < endLine:
					var ch = line[p]
					var hasStepF2Annotation:bool=ch=="{"
					var sf2NoteAppearance
					var sf2FakeBit
					#char StepF2NoteAppearance, StepF2FakeBit;
					#signed char SF2UnknownBit;

					if hasStepF2Annotation:
						
							#const char* separator = p + 2;
							#const char* annotationEnd = p + 4;
							var separator = line[p+2]
							var annotationEnd = line[p+4]
		
							if p+4 < endLine && separator == '|' && annotationEnd == '}': #Check if this note is just {a|b}
								ch = line[p+1];
								sf2NoteAppearance = line[p+3];
								sf2FakeBit = '0';
								#SF2UnknownBit = '0';
								p = p+8; #Jump to end of this note
							else:
								#const char* separator2 = p + 4;
								#const char* separator3 = p + 6;
								#annotationEnd = p + 8;
								var separator2 = line[p+4]
								var separator3 = line[p+6]
								annotationEnd = line[p+8]
		
								if(p+8 < endLine && separator == '|' && separator2 == '|' && separator3 == '|' && annotationEnd == '}'):
								
									ch = line[p+1]
									sf2NoteAppearance = line[p + 3];
									sf2FakeBit = line[p+5];
									#SF2UnknownBit = *(p + 7);
									p = p+8; #Jump to end of this note
								
								else:
								
									hasStepF2Annotation = false;
									isBadLine = true;
					
					if isBadLine:
						print("The line "+line+" at measure "+String(curNotesMeasure)+" is unable to be parsed. Ignoring.")
						break
					elif hasStepF2Annotation:
						notes.append([ch,sf2NoteAppearance,sf2FakeBit,"0"])
					else:
						notes.append(ch)
					p+=1
				if isBadLine:
					sscData['steps'][curSteps]["NOTES"][curNotesMeasure].append(['0','0','0','0','0'])
				else:
					sscData['steps'][curSteps]["NOTES"][curNotesMeasure].append(notes)
			#pass
		else:
			if line.ends_with(";"):
				#print(line)
				var tagStr = line.substr(1,len(line)-2)
				var tagData=tagStr.split(":",true,1)
				#print(tagData)
				if len(tagData)==0:
					print("WTF????")
					print(line)
					line=""
					continue
				match tagData[0]:
					#floats
					"SAMPLESTART","SAMPLELENGTH","LASTSECONDHINT","VERSION":
						sscData['header'][tagData[0]]=float(tagData[1])
					"OFFSET","DISPLAYBPM": #Can be either global or per-steps
						insertIntoHeaderOrSteps(sscData,tagData[0],float(tagData[1]),curParse,curSteps)
					"BPMS","SCROLLS","SPEEDS","STOPS","DELAYS","FAKES","WARPS": #[float,*float,]. Speeds is [float,float,float,int] but I'm lazy.
						var timingData = []
						var bpms = tagData[1].split(",",false)
						for bpm in bpms:
							var tmp = Array(bpm.split("="))
							for i in range(tmp.size()):
								tmp[i]=float(tmp[i])
							timingData.append(tmp)
						insertIntoHeaderOrSteps(sscData,tagData[0],timingData,curParse,curSteps)
					"TICKCOUNTS","COMBOS": #[float,int]
						var timingData = []
						var bpms = tagData[1].split(",",true)
						for bpm in bpms:
							var tmp = bpm.split("=")
							timingData.append([float(tmp[0]),int(tmp[1])])
						insertIntoHeaderOrSteps(sscData,tagData[0],timingData,curParse,curSteps)
					"TIMESIGNATURES": #[float,int,int]
						var timingData = []
						var bpms = tagData[1].split(",",true)
						for bpm in bpms:
							var tmp = bpm.split("=")
							timingData.append([float(tmp[0]),int(tmp[1]),int(tmp[2])])
						insertIntoHeaderOrSteps(sscData,tagData[0],timingData,curParse,curSteps)
					"LABELS": #[float,string]
						var timingData = []
						var bpms = tagData[1].split(",",true)
						for bpm in bpms:
							var tmp = bpm.split("=")
							timingData.append([float(tmp[0]),String(tmp[1])])
						insertIntoHeaderOrSteps(sscData,tagData[0],timingData,curParse,curSteps)
					"NOTEDATA":
						print("==== Parsing per-chart info ====")
						curParse=CurrentlyParsing.PER_STEPS_DATA
						sscData['steps'].append({})
						curSteps=sscData['steps'].size()-1
					"METER": #In SM this is an unsigned int.
						if curParse==CurrentlyParsing.HEADER:
							print("Error! Encountered METER tag in header!")
						else:
							sscData['steps'][curSteps][tagData[0]]=int(tagData[1])
					_:
						insertIntoHeaderOrSteps(sscData,tagData[0],tagData[1],curParse,curSteps)

				#clear buffer
				line=""
			#elif line.begins_with("//"):
			#	continue
			else:
				var tmp_line = f.get_line().strip_escapes()
				if tmp_line=="#NOTES:": #This is where the fun begins
					print("==== Parsing notes! ====")
					sscData['steps'][curSteps]["NOTES"]=[[]]
					curNotesMeasure=0
					curParse=CurrentlyParsing.NOTEDATA
				elif not tmp_line.begins_with("//"): #This should be changed so it cuts off past //
					line += tmp_line
	
	f.close()

	if OS.is_debug_build():
		var debugOutput = File.new()
		var dir = Globals.get_save_directory('piured-ssc-debug')
		var ok = debugOutput.open(dir,File.WRITE)
		if ok==OK:
			debugOutput.store_line(to_json(sscData))
			print("Saved parsed ssc to "+dir)
		debugOutput.close()

	return sscData


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
	return 'res://Stages_Reina/Clear_And_Fail/Songs/Breaking The Habit/song.ogg'

#Godot doesn't support this
func setNewPlayBackSpeed ( newPlayBackSpeed ):
	#self.source.playbackRate.value = newPlayBackSpeed ;
	#self.playBackSpeed = newPlayBackSpeed ;
	# self.requiresResync = true ;
	pass


var startTime:float=0.0;
func startPlayBack(startDate:int):

	var currentDate:int = OS.get_ticks_msec()

	##           convert to secs
	self.delay = (startDate - currentDate) / 1000.0 ;


	#self.startTime = self.context.currentTime;

	self.startTime = 0.0;
	## console.log('start time: ' + self.startTime ) ;
	print('computed delay: ' + String(self.delay)) ;
	#self.source.start(self.startTime + self.delay) ;
	play(self.startTime + self.delay)
	self.readyToStart = true ;
	pass


#This looks really stupid but SSCs have individual offsets
func getCurrentAudioTime( level )->float:
	# return self.context.currentTime ;
	# console.log('Outside start time: ' + self.startTime) ;
	# self.steps[level].meta['OFFSET'] ;
	if ( self.readyToStart == false ):
		return -1.0 ;
	return self.get_playback_position() - self.delay + self.getOffset(level)  - self.startTime - self.globalOffset;
	# return self.startTime - self.audio.context.currentTime + parseFloat(self.meta['OFFSET']);
	#return self.audio.context.currentTime + self.startTime + parseFloat(self.meta['OFFSET']);

func getTotalOffset(level):
	return - self.delay + self.getOffset(level) - self.startTime;
