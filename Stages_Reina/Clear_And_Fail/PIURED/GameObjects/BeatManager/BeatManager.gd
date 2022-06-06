class_name BeatManager
# here's your funny comment
# https://www.youtube.com/watch?v=eLGn_dVA3ow
# Here's 1000 lines of I don't know what the heck this is,
# but I translated it and it works and that's all that matters


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

#Cannot use the existing Curve name
class PIURED_Curve:
	var _intervalList:Array = [] ;

	func addInterval(interval):
		_intervalList.append(interval)


	func scryY ( p:Vector2 )->Vector2:

		for i in range(_intervalList.size()):
			var interval = self._intervalList [ i ] ;

			if ( interval.isInIntervalX(p) ):
				p.y = interval.scryY(p.x) ;

				return p
		#THere does not appear to be any error checking...
		return Vector2()


	func scryX ( p:Vector2 )->Vector2:
		for i in range(_intervalList.size()):
			var interval = self._intervalList [ i ] ;

			if ( interval.isInIntervalY(p) ):

				p.x = interval.scryX(p.y) ;

				return p ;
		return Vector2()

	#This function is never used
#	findIntervalsBetweenX(x1, x2) {
#
#		var intervals = [] ;
#		var p1 = Vector2(x1,0) ;
#		var p2 = Vector2(x2,0) ;
#		var firstit = 0 ;
#
#		# find first interval
#		for i in range(_intervalList.size()):
#
#			var itvl = self._intervalList[i] ;
#
#			if ( itvl.isInIntervalX(p1) ) {
#				intervals.push(itvl) ;
#				firstit = i ;
#				break;
#			}
#
#		}
#
#		#add remainder
#		for (var i = firstit ; i < self._intervalList.length ; i++) {
#
#			var itvl = self._intervalList[i] ;
#
#			if (! intervals.includes(itvl)) {
#				intervals.push(itvl) ;
#			}
#
#			if ( itvl.isInIntervalX(p2) ) {
#				break;
#			}
#
#		}
#
#		return intervals ;
#
#	}

	func findIntervalsBetweenY(y1:float, y2:float)->Array:

		var intervals:Array = [] ;
		var p1 = Vector2(0,y1) ;
		var p2 = Vector2(0,y2) ;
		var firstit:int = 0 ;

		# find first interval
		for i in range(_intervalList.size()):

			var itvl = self._intervalList[i] ;

			if ( itvl.isInIntervalY(p1) ):
				intervals.append(itvl) ;
				firstit = i ;
				break;

		#add remainder
		for i in range(firstit,_intervalList.size()):

			var itvl = self._intervalList[i] ;

			if not intervals.has(itvl):
				intervals.append(itvl) ;

			if ( itvl.isInIntervalY(p2) ):
				break;
			

		return intervals ;

	func findIntervalAtY(y):
		var p1 = Vector2(0,y) ;

		# find first interval
		for i in range(_intervalList.size()):

			var itvl = self._intervalList[i] ;

			if ( itvl.isInIntervalY(p1) ):
				return itvl ;

	func findIntervalsFromY(y:float)->Array:

		var intervals = [] ;
		var p1 = Vector2(0,y) ;
		var firstit = 0 ;

		# find first interval
		for i in range(_intervalList.size()):

			var itvl = self._intervalList[i] ;

			if ( itvl.isInIntervalY(p1) ):
				intervals.append(itvl) ;
				firstit = i ;
				break;
			
		#add remainder
		for i in range(firstit + 1,_intervalList.size()):
			var itvl = self._intervalList[i] ;
			intervals.append(itvl) ;
		
		return intervals ;

	
	func splitIntervalAtY(interval:Interval, y):
		
		#findIndex() - Finds the first value that evaluates to true
		#var index = self._intervalList.findIndex( itvl => itvl == interval) ;
		var index:int = -1
		for i in range(_intervalList.size()):
			if _intervalList[i] == interval:
				index=i
				break


		if ( interval.sideOfInIntervalAtY(y) == 'right'):
			interval.p2 = Vector2(interval.scryX(y+1.0),y+1.0) ;
			self.splitIntervalAtY(interval,y) ;
			return ;
		elif interval.sideOfInIntervalAtY(y) == 'left':
			interval.p1 = Vector2(interval.scryX(y-1.0), y-1.0) ;
			self.splitIntervalAtY(interval,y) ;
			return ;
		

		if ( y == interval.p1.y || y == interval.p2.y ):
			return ;
		

		var point1 = Vector2(interval.scryX(y), y) ;
		var point2 = Vector2(interval.scryX(y), y) ;

		var chunk1 = Interval.new()
		chunk1.constructor(interval.p1, point1, interval._openLeft, false) ;
		var chunk2 = Interval.new()
		chunk2.constructor(point2, interval.p2, false, interval._openRight ) ;
		
		#var chunk1 = new Interval(interval.p1, point1, interval.openLeft, false) ;
		#var chunk2 = new Interval(point2, interval.p2, false, interval.openRight ) ;

		#Deletes the element at index, then appends chunk1 and chunk2
		#self._intervalList.splice(index, 1, chunk1, chunk2) ;
		
		#This is actually insanely slow
		_intervalList.remove(index)
		_intervalList.insert(index+1,chunk1)
		_intervalList.insert(index+1,chunk2)

		return index ;
	

	func addIntervalAtIndex(index:int, itvl):
		#self._intervalList.splice(index,0,itvl) ;
		_intervalList.insert(index,itvl)
	

	func getIntervalsFromIndex(index:int)->Array:
		#return self._intervalList.slice(index) ;
		return _intervalList.slice(index,_intervalList.size())
	


#I can't tell what this is for or why it's using Vector2
class Interval:

	var p1:Vector2 ;
	var p2:Vector2 ;
	var _openLeft:bool ;
	var _openRight:bool ;

	func _to_string():
		return "[p1="+String(p1)+", p2="+String(p2)+", openLeft="+String(_openLeft)+", openRight="+String(_openRight)+"]"

	func constructor( p1_:Vector2, p2_:Vector2, openLeft:bool, openRight:bool ):

		self.p1 = p1_ ;
		self.p2 = p2_ ;

		self._openLeft = openLeft ;
		self._openRight = openRight ;


	func isInIntervalX( p:Vector2 )->bool:

		if ( self._openLeft && self._openRight ):
			return true ;
		elif self._openLeft:
			return p.x < p2.x;
		elif self._openRight:
			return p.x >= p1.x ;
		
		return p.x >= p1.x && p.x < p2.x;

	func isInIntervalY( p:Vector2 )->bool:

		if ( self._openLeft && self._openRight ):
			return true ;
		elif self._openLeft:
			return p.y < p2.y;
		elif self._openRight:
			return p.y >= p1.y ;
		
		return p.y >= p1.y && p.y < p2.y;

	

	func scryY( x ):

		var m = (p2.y - p1.y) / (p2.x - p1.x) ;

		var y = m*(x-p1.x) + p1.y ;

		return y ;

	func scryX( y ):

		var m = (p2.x - p1.x) / (p2.y - p1.y) ;

		var x = m*(y-p1.y) + p1.x ;

		return x ;


	enum IntervalSide {
		LEFT,
		RIGHT,
		IN
	}

	#What's en enum anyways?
	func sideOfInIntervalAtY(y)->String:

		var leftBoundary = self.scryY(p1.x) ;
		var rightBoundary = self.scryY(p2.x) ;

		if ( y < leftBoundary ):
			return 'left' ;
		elif y > rightBoundary:
			return 'right' ;
		return 'in' ;


class Second2Beat:


	var _curve:PIURED_Curve ;
	var _bpms:Array ;
	func constructor(bpms:Array):

		var longFloat:float = 100000.0 ;

		#Original code used array copy...
		self._bpms = bpms
		self._curve = PIURED_Curve.new() ;


		#What? What the heck is this doing?
		#var l = self._bpms[self._bpms.length -1]) ;
		var l = _bpms[_bpms.size()-1].duplicate()
		l[0] += longFloat ;
		self._bpms.append(l)
		var prevPoint = Vector2(0.0,0.0) ;

		for i in range(_bpms.size()-1):

			var beat1 = self._bpms[ i ][0] ;
			var bpm1 = self._bpms[ i ] [1] ;
			var beat2 = self._bpms[ i+1 ][0] ;
			var bpm2 = self._bpms[ i+1 ] [1] ;


			var x = self.secondsPerBeat(bpm1) * (beat2 - beat1) + prevPoint.x;
			var y = beat2 ;
			var p = Vector2(x,y) ;

			#var interval = new Interval(prevPoint, p , i == 0 ,i  == self._bpms.length -2) ;
			var interval = Interval.new()
			interval.constructor(prevPoint, p , i == 0 ,i  == self._bpms.size() -2) ;
	
			self._curve.addInterval(interval) ;

			prevPoint = Vector2(p.x, p.y) ;

	func scry(value)->Vector2:
		var p = Vector2(value, 0 ) ;
		return self._curve.scryY(p) ;

	func reverseScry(value:float)->Vector2:
		var p = Vector2(0.0, value ) ;
		return self._curve.scryX(p) ;


	func secondsPerBeat(bpm:float)->float:
		return 1.0 / (bpm / 60.0) ;
	
class Second2Displacement:


	var _scrolls:Array ;
	var _s2b:Second2Beat ;
	
	var _sdb2:Second2Beat #?????
	var _curve:PIURED_Curve ;

	func constructor(scrolls:Array, bpms:Array, s2b:Second2Beat):

		self._scrolls = scrolls.duplicate() ;
		self._s2b = s2b ;
		
		_sdb2 = Second2Beat.new()
		_sdb2.constructor(bpms)
		_curve=_sdb2._curve
		#self._curve = new Second2Beat(bpms)._curve ;


		var tolerance:float = 0.00001 ;


		for i in range(_scrolls.size()-1):

			var beat1:float = self._scrolls[ i ][0] ;
			var scroll1 = self._scrolls[ i ] [1] ;
			var beat2:float = self._scrolls[ i+1 ][0] ;
			var scroll2 = self._scrolls[ i+1 ] [1] ;

			print("Calculating interval between "+String(beat1)+" and "+String(beat2))


			var displacement1 = self._curve.scryY(self._s2b.reverseScry(beat1)).y ;
			var displacement2 = self._curve.scryY(self._s2b.reverseScry(beat2)).y ;


			var firstInterval = self._curve.findIntervalAtY(displacement1) ;
			self._curve.splitIntervalAtY(firstInterval, displacement1) ;

			var lastInterval = self._curve.findIntervalAtY(displacement2) ;
			self._curve.splitIntervalAtY(lastInterval, displacement2) ;


			var intervals = self._curve.findIntervalsBetweenY(displacement1,displacement2) ;

			print("Got intervals of size "+String(intervals))
			if abs(intervals[intervals.size() -1].p1.y - displacement2) < tolerance:
				print("Displacement 1 and displacement 2 are too close!")
				print(intervals[intervals.size() -1].p1.y)
				print(displacement2)
				intervals.pop_back() ;
			print("Result size is "+String(intervals.size()))

			var prevp1:Vector2 = intervals[0].p1 ;
			var prevdiff = 0.0 ;

			var remainderIntervals = self._curve.findIntervalsFromY(displacement2) ;

			#modify scroll sections
			for j in range(intervals.size()):

				var itvl1 = intervals[j] ;
				itvl1.p1 = prevp1 ;
				var oldy2 = itvl1.p2.y ;
				itvl1.p2.y = prevp1.y + (itvl1.p2.y - prevp1.y + prevdiff) * scroll1 ;

				prevp1 = Vector2(itvl1.p2.x, itvl1.p2.y) ;
				prevdiff = itvl1.p2.y - oldy2 ;


			for j in range(remainderIntervals.size()):
				var itvl = remainderIntervals[j] ;
				itvl.p1.y += prevdiff ;
				itvl.p2.y += prevdiff ;


		#last scroll

		var beat = self._scrolls[ self._scrolls.size() - 1 ][0] ;
		var scroll= self._scrolls[ self._scrolls.size() - 1 ] [1] ;
		var displacement = self._curve.scryY(self._s2b.reverseScry(beat)).y ;
		var interval = self._curve.findIntervalAtY(displacement) ;
		self._curve.splitIntervalAtY(interval, displacement) ;

		var intervals = self._curve.findIntervalsFromY(displacement) ;
		var prevp1:Vector2 = intervals[0].p1 ;
		var prevdiff = 0.0 ;

		#modify scroll sections
		for j in range(intervals.size()):

			var itvl1 = intervals[j] ;
			itvl1.p1 = prevp1 ;
			var oldy2 = itvl1.p2.y ;
			itvl1.p2.y = prevp1.y + (itvl1.p2.y - prevp1.y + prevdiff) * scroll ;

			prevp1 = Vector2(itvl1.p2.x, itvl1.p2.y) ;
			prevdiff = itvl1.p2.y - oldy2 ;

	func scry(value)->Vector2:
		var p = Vector2(value, 0 ) ;
		return self._curve.scryY(p) ;


class SongTime2Second:


	var _curve:PIURED_Curve ;
	var _stops:Array ;
	var _delays:Array ;
	var _warps:Array;
	var _s2b:Second2Beat ;
	var _eps:float = 0.000001 ;
	
	func constructor(stops, delays, warps, s2b):


		self._s2b = s2b ;
		var longFloat = 100000.0 ;

		self._stops = stops.duplicate() ;
		self._delays = delays.duplicate() ;
		self._warps = warps.duplicate() ;
		self._curve = PIURED_Curve.new()
		
		
		var i_ = Interval.new()
		i_.constructor(Vector2(0.0,0.0), Vector2(longFloat,longFloat), true, true)
		self._curve.addInterval(i_) ;



		# warps
		for i in range(_warps.size()):

			var b1 = self._warps[ i ] [0] ;
			var span = self._warps[ i ] [1] ;

			self.raise(b1, b1+span) ;


		# stops
		for i in range(_stops.size()):
			var beat = self._stops[ i ] [0] ;
			var span = self._stops[ i ] [1] ;

			self.flatten(beat, span, self._eps) ;


		#delays
		for i in range(_delays.size()):

			var beat = self._delays[ i ] [0] ;
			var span = self._delays[ i ] [1] ;

			self.flatten(beat, span, -self._eps) ;


	func flatten(beat, span, eps):

		var y1 = self._s2b.reverseScry(beat + eps).x ;
		var x1 = self._curve.scryX(Vector2(0.0,y1)).x ;
		var x2 = x1 + span ;
		# var y2 = self._curve.scryY(Vector2(x2,0.0)).y ;


		var i1 = self._curve.findIntervalAtY(y1) ;
		var itvlIndex = self._curve.splitIntervalAtY(i1, y1) ;

		#var flatItvl = new Interval(Vector2(x1,y1), Vector2(x2, y1), false, false) ;
		var flatItvl:Interval = Interval.new()
		flatItvl.constructor(Vector2(x1,y1), Vector2(x2, y1), false, false) ;

		self._curve.addIntervalAtIndex(itvlIndex+1, flatItvl) ;

		var remainderIntervals = self._curve.getIntervalsFromIndex(itvlIndex+2) ;

		var diff = x2 - x1 ;

		for j in range(remainderIntervals.size()):
			var itvl = remainderIntervals[j] ;
			itvl.p1.x += diff ;
			itvl.p2.x += diff ;

	func raise (b1:float, b2:float):
		var y1 = self._s2b.reverseScry(b1).x ;
		var y2 = self._s2b.reverseScry(b2).x ;

		#print(y1,y2)
		#console.log(y1,y2) ;

		# var x1 = self._curve.scryX(Vector2(0.0,y1)).x ;
		# var x2 = self._curve.scryX(Vector2(0.0,y2)).x ;


		var i1 = self._curve.findIntervalAtY(y1) ;
		self._curve.splitIntervalAtY(i1, y1) ;

		var i2 = self._curve.findIntervalAtY(y2) ;
		self._curve.splitIntervalAtY(i2, y2) ;


		var intervals = self._curve.findIntervalsBetweenY(y1,y2) ;
		intervals.pop() ;

		var remainderIntervals = self._curve.findIntervalsFromY(y2) ;


		var diff = intervals[0].p2.x - intervals[0].p1.x ;
		intervals[0].p2.x = intervals[0].p1.x ;

		for j in range(remainderIntervals.size()):
			var itvl = remainderIntervals[j] ;
			itvl.p1.x -= diff ;
			itvl.p2.x -= diff ;
	
	#STOP COPY PASTING THIS -AmWorks
	func scry(value)->Vector2:

		var p = Vector2(value, 0 ) ;
		return self._curve.scryY(p) ;


	func reverseScry(value)->Vector2:

		var p = Vector2(0.0, value ) ;
		return self._curve.scryX(p) ;

class Beat2Speed:


	var _curve:PIURED_Curve ;
	var _speeds:Array ;
	var _beat2s:Array = [] ;
	var _s2b:Second2Beat ;

	func constructor( speedsList:Array, s2b:Second2Beat ):

		self._s2b = s2b ;
		self._speeds = speedsList.duplicate()
		_curve = PIURED_Curve.new()
		#self._curve = new Curve() ;

		self.cleanUp() ;

		var longFloat:float = 1000000.0 ;


		var prevPoint = Vector2(-longFloat,self._speeds[ 0 ][1]) ;


		for i in range(_speeds.size()):

			#var [ beat, speed, span, mode ] = self._speeds[ i ] ;
			var tmp = self._speeds[i];
			var beat =  tmp[0]
			var speed = tmp[1]
			var span =  tmp[2]
			var timedInSeconds:bool =  int(tmp[3])==1

			#flat interval

			var f1 = Vector2(prevPoint.x, prevPoint.y) ;
			var f2 = Vector2(beat, prevPoint.y ) ;

			#var fInterval = new Interval(f1, f2 , i == 0 ,false) ;
			var fInterval = Interval.new()
			fInterval.constructor(f1, f2 , i == 0 ,false) ;
			self._curve.addInterval(fInterval) ;




			var beat2 ;
			# convert span in seconds into beats if mode is 1.
			if timedInSeconds:
				var sec = s2b.reverseScry(beat).x ;
				sec = sec + span ;
				beat2 = s2b.scry(sec).y ;
			else:
				beat2 = beat + span ;
			

			#slope (change of speed) interval

			var p1 = Vector2(beat,prevPoint.y) ;
			var p2 = Vector2(beat2,speed) ;

			#var interval = new Interval(p1, p2 , false,false) ;
			var interval = Interval.new()
			interval.constructor(p1, p2 , false,false) ;
			self._curve.addInterval(interval) ;

			prevPoint = p2


		
		#flat area
		var f1 = Vector2(prevPoint.x, prevPoint.y) ;
		var f2 = Vector2(longFloat, prevPoint.y ) ;

		#var fInterval = new Interval(f1, f2 , false ,true) ;
		#self._curve.addInterval(fInterval) ;
		
		var fInterval = Interval.new()
		fInterval.constructor(f1, f2 , false ,true) ;
		self._curve.addInterval(fInterval) ;

	

	func cleanUp():

		for i in range(_speeds.size()-1):

			#var [ beat, speed, span, mode ] = self._speeds[ i ] ;
			var tmp1 = self._speeds[ i ] ;
			var beat = tmp1[0]
			#var speed = tmp1[1]
			var span = tmp1[2]
			var timedInSeconds = int(tmp1[3])==1
			
			#var [ nbeat, nspeed, nspan, nmode ] = self._speeds[ i+1 ] ;
			var tmp2 = _speeds[i+1];
			var nbeat = tmp2[0]

			var beat2 = self.getBeat2(timedInSeconds, beat, span) ;

			if ( beat2 > nbeat ):
				self._speeds[i][2] = nbeat - beat ;
				self._speeds[i][3] = 0 ;
			

			self._beat2s.append(self._speeds[i][2]) ;

	func getBeat2(timedInSeconds:bool, beat, span):
		if timedInSeconds:
			var sec = self._s2b.reverseScry(beat).x ;
			sec = sec + span ;
			return self._s2b.scry(sec).y ;
		else:
			return beat + span ;
		
	

	#STOP COPY PASTING THIS ALREADYIHROHU#(#I$J)#$IKO@JO(I@$O)
	func scry(beat)->Vector2:
		var p = Vector2(beat, 0 ) ;
		return self._curve.scryY(p) ;



#And now, the BeatManager class... After 9999 years....

var playBackSpeed
var bpmList:Array
var scrollList:Array
var stopsList:Array
var delaysList:Array
var warpsList:Array
var speedsList:Array
var song
var level
var keyboardLag
var customOffset:float=0.0
var requiresResync:bool=false

var _currentAudioTime:float=0.0
var _currentAudioTimeReal:float=0.0
var _currentChartAudioTime:float=0.0
var _currentChartAudioTimeReal:float=0.0
var currentBPM:float=0.0
#Not sure if float or int but it doesn't matter
var currentYDisplacement:float=-100
var currentBeat:float=0
var currentTickCount:float=1

var second2beat:Second2Beat
var second2displacement:Second2Displacement
var songtime2second:SongTime2Second
var beat2speed:Beat2Speed

var _speed


func constructor(song, level, speed, keyBoardLag, playBackSpeed):

	self.playBackSpeed = playBackSpeed ;

	self.bpmList = song.getBPMs(level) ;
	self.scrollList = song.getScrolls(level) ;
	self.stopsList = song.getStops(level) ;
	self.delaysList = song.getDelays(level) ;
	self.warpsList = song.getWARPS(level) ;
	self.speedsList = song.getSpeeds(level) ;
	self.song = song ;
	self.level = level ;
	self.keyboardLag = keyBoardLag ;
	#self.customOffset = 0 ;
	#self.requiresResync = false ;


	# new beatmanager

	#self.second2beat = new Second2Beat(self.bpmList) ;
	#self.second2displacement = new Second2Displacement(self.scrollList,self.bpmList,self.second2beat) ;
	#self.songTime2Second = new SongTime2Second(self.stopsList, self.delaysList, self.warpsList, self.second2beat) ;
	#self.beat2speed = new Beat2Speed(self.speedsList, self.second2beat) ;
	self._speed = speed;
	second2beat = Second2Beat.new()
	second2beat.constructor(bpmList)
	second2displacement = Second2Displacement.new()
	second2displacement.constructor(self.scrollList,self.bpmList,self.second2beat) ;
	songtime2second = SongTime2Second.new()
	songtime2second.constructor(self.stopsList, self.delaysList, self.warpsList, self.second2beat) ;
	beat2speed = Beat2Speed.new()
	beat2speed.constructor(self.speedsList, self.second2beat) ;

	#set_process(true)
# ready() {

# 	self._currentAudioTime = 0 ;
# 	self._currentAudioTimeReal = 0 ;
# 	self._currentChartAudioTime = 0 ;
# 	self._currentChartAudioTimeReal = 0
# 	self.currentBPM = 0 ;
# 	self.currentYDisplacement = -100 ;
# 	self.currentBeat = 0 ;
# 	self.currentTickCount = 1 ;


# }

func setNewPlayBackSpeed ( newPlayBackSpeed ):
	self.playBackSpeed = newPlayBackSpeed ;

func updateOffset(offset):
	self.customOffset += offset ;
	self.requiresResync = true ;


#This script is not a node, so we have to process it manually from the parent.
func process(delta):

	var songAudioTime = self.song.getCurrentAudioTime(self.level) - self.customOffset ;

	if ( songAudioTime <= 0.0 || self.requiresResync):
	## if ( true ) {
		self.requiresResync = false ;
		self._currentAudioTime = songAudioTime - self.keyBoardLag;
		self._currentAudioTimeReal = songAudioTime;
	else:
		self._currentAudioTime += delta * self.playBackSpeed ;
		self._currentAudioTimeReal += delta * self.playBackSpeed;

	self._currentChartAudioTime = self.songTime2Second.scry(self._currentAudioTime).y ;
	self._currentChartAudioTimeReal = self.songTime2Second.scry(self._currentAudioTimeReal).y ;


	self.currentYDisplacement = self.second2displacement.scry(self._currentChartAudioTime).y ;

	self.currentBeat = self.second2beat.scry(self._currentChartAudioTime).y ;



	# console.log('time: '+ self.currentAudioTime +'\n dis: ' + self.currentYDisplacement + ' beat: '  + self.currentBeat +
	# '\n rds: ' + realDisp + ' rbet: ' + realBeat) ;

	self.updateCurrentBPM() ;

	self.currentTickCount = self.song.getTickCountAtBeat(self.level, self.currentBeat) ;


func updateCurrentBPM ():

	var tickCounts = self.bpmList ;
	var last = tickCounts[0][1];
	for tickCount in tickCounts:
		var beatInTick = tickCount[0] ;
		var tick = tickCount[1] ;
		if ( self.currentBeat >= beatInTick ):
			last = tick ;
		else:
			break ;
	self.currentBPM = last ;

func getScrollAtBeat(beat):
	var tickCounts = self.scrollList ;
	var last = tickCounts[0];
	for tickCount in tickCounts:
		var beatInTick = tickCount[0] ;
		var tick = tickCount[1] ;
		if ( beat >= beatInTick ):
			last = tickCount ;
		else:
			return last ;
		
	
	return last ;

func isNoteInWarp(beat)->bool:
	for warp in warpsList:
		var b1 = warp[0] ;
		var b2 = b1 + warp[1] ;
		if ( beat >= b1 && beat < b2 ):
			return true ;
		

		if ( beat < b1 ):
			return false ;
	return false ;

func getCurrentSpeed():
	return self.beat2speed.scry(self.currentBeat).y ;


func getYShiftAndCurrentTimeInSongAtBeat( beat )->Array:

	var second = self.second2beat.reverseScry(beat).x ;
	var yShift = -self.second2displacement.scry(second).y * self._speed;


	return [yShift, second] ;
