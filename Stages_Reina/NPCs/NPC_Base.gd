extends KinematicBody2D


enum DIRECTION {LEFT = -1, TOWARDS_PLAYER = 0, RIGHT = 1}
export(DIRECTION) var facing = DIRECTION.LEFT

onready var sprite:AnimatedSprite = $AnimatedSprite



enum TWEEN_TYPE {
	LINEAR,
	DECELERATE,
	ACCELERATE,
	SLEEP
}
enum TWEEN_STATUS {
	NO_TWEEN,
	TWEEN_RUNNING,
	TWEEN_FINISHED
}

var tweening_state = TWEEN_STATUS.NO_TWEEN

func set_tween_finished():
	tweening_state = TWEEN_STATUS.TWEEN_FINISHED

func cmd(tweenString:String) -> float:
	var tw = create_tween()
	
	tw.set_parallel(true)
	tw.tween_property(self,"tweening_state",TWEEN_STATUS.TWEEN_RUNNING,0.0)
	tw.connect("finished",self.set_tween_finished)
	var cmnds = tweenString.split(";",false)
	
	var tweenBatch = 0
	var tweenLength:float = 0.0
	var timeToDelay:float = 0.0
#It's not unused so why is it a warning???
# warning-ignore:unused_variable
	var curTweenType = TWEEN_TYPE.SLEEP
		
	var lastKnownPosition:Vector2 = position
	
	for cmd in cmnds:
		var splitCmd = cmd.split(",")
		match splitCmd[0]:
			"linear":
				curTweenType = TWEEN_TYPE.LINEAR
				if tweenBatch>0:
					#Add previous tween length to delay
					timeToDelay+=tweenLength
				tweenBatch+=1
				tweenLength = float(splitCmd[1])
			"decelerate":
				curTweenType = TWEEN_TYPE.DECELERATE
				
				if tweenBatch>0:
					#Add previous tween length to delay
					timeToDelay+=tweenLength
				tweenBatch+=1
				
				tweenLength = float(splitCmd[1])
				tw.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			"accelerate":
				curTweenType = TWEEN_TYPE.ACCELERATE
				
				if tweenBatch>0:
					#Add previous tween length to delay
					timeToDelay+=tweenLength
				tweenBatch+=1
				
				tweenLength = float(splitCmd[1])
				tw.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
			"sleep":
				curTweenType = TWEEN_TYPE.SLEEP
				
				if tweenBatch>0:
					#Add previous tween length to delay
					timeToDelay+=tweenLength
				tweenBatch+=1
				
				tweenLength = 0.0
				timeToDelay += float(splitCmd[1])
			"x":
				tw.tween_property(self,"map_position:x",float(splitCmd[1]),tweenLength).set_delay(timeToDelay)
				# x is upLeft/downRight
				#tw.tween_callback(set_facing_by_world_angle.bind(Vector2(float(splitCmd[1]),lastKnownPosition.y)))
				
				#if float(splitCmd[1]) > lastKnownPosition.x:
				#	tw.tween_callback(set_facing_by_world_angle.bind(Vector2(float(splitCmd[1]),lastKnownPosition.y)))
				#	#tw.tween_callback(play.bind(""))
			"y":
				tw.tween_property(self,"map_position:y",float(splitCmd[1]),tweenLength).set_delay(timeToDelay)
				# y is downLeft/upRight
				#tw.tween_callback(set_facing_by_world_angle.bind(Vector2(lastKnownPosition.x,float(splitCmd[1]))))
			"addx", "addy":
				var toAdd = Vector2()
				if splitCmd[0]=="addx":
					print("Applying addx "+splitCmd[1]+" after "+str(timeToDelay)+" sec... "+str(lastKnownPosition.x)+"+"+splitCmd[1])
					toAdd.x=float(splitCmd[1])
				else:
					print("Applying addy "+splitCmd[1]+" after "+str(timeToDelay)+" sec... "+str(lastKnownPosition.y)+"+"+splitCmd[1])
					toAdd.y=float(splitCmd[1])
					
#				tw.tween_property(self,"map_position",lastKnownPosition+toAdd,tweenLength).from(lastKnownPosition).set_delay(timeToDelay)
#				tw.tween_callback(
#					set_facing_by_world_angle.bind(
#						lastKnownPosition+toAdd,
#						true
#					)
#				).set_delay(timeToDelay)
				#tw.tween_property(self,"")
				lastKnownPosition+=toAdd
				
#				tw.tween_callback(
#					set_facing_by_world_angle.bind(
#						lastKnownPosition,
#						false
#					)
#				).set_delay(timeToDelay+tweenLength)
			"zoom":
				var v2 = Vector2()
				if len(splitCmd) < 3:
					v2.x=float(splitCmd[1])
					v2.y=v2.x
				else:
					v2 = Vector2(float(splitCmd[1]),float(splitCmd[2]))
				tw.tween_property(self,"scale",v2,tweenLength).set_delay(timeToDelay)
			"zoomx":
				tw.tween_property(self,"scale:x",float(splitCmd[1]),tweenLength).set_delay(timeToDelay)
			"diffuse","modulate":
				tw.tween_property(self,"modulate",Color(splitCmd[1]),tweenLength).set_delay(timeToDelay)
			"diffusealpha":
				tw.tween_property(self,"modulate:a",float(splitCmd[1]),tweenLength).set_delay(timeToDelay)
#			"emote":
#				if "cur_expression" in objectToTween:
#					tw.tween_property(objectToTween,"cur_expression",splitCmd[1],0.0).set_delay(timeToDelay)
			_:
				print("Unregistered command "+str(splitCmd))
	return timeToDelay+tweenLength
