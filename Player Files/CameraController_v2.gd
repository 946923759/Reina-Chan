extends Camera2D

var cam = self
var oldPosition;
var newPosition;

#In case we touch a checkpoint before the tweening is finished.
var destPositions:Array

#So we can't really use the game's resolution because
#it changes and during a stage we just set it to black
#bars on the side
#Having a global var for the resolution doesn't
#make any sense anyways because it can change
#every screen
const SCREEN_WIDTH:int = 1280
const SCREEN_HEIGHT:int = 720
const SCREEN_CENTER_X = SCREEN_WIDTH/2
const SCREEN_CENTER_Y = SCREEN_HEIGHT/2

func _ready():
	set_process(true)
	destPositions=[cam.limit_left, cam.limit_top, cam.limit_right, cam.limit_bottom]

var is_tweening:bool=false
#I no longer remember wtf write_destinations is for
func finish_tweening_camera(_write_destinations:bool=false):
	is_tweening=false
	cam.limit_left = destPositions[0]
	cam.limit_top = destPositions[1]
	cam.limit_right = destPositions[2]
	cam.limit_bottom = destPositions[3]
	#print("finish tweening, limit is "+String(destPositions))

func adjustCamera(np,secs):
	destPositions=np
	#if progress > 0:
	#	print("The camrea is already tweening! Bad things will happen...")
	#oldPosition = [cam.limit_left, cam.limit_top, cam.limit_right, cam.limit_bottom]
	#newPosition = np
	if secs > 0:
		
		#lock the camera to the current position so the tween works correctly
		var cPos = cam.get_camera_screen_center()
		cam.limit_left = cPos.x - SCREEN_CENTER_X
		cam.limit_right = cPos.x + SCREEN_CENTER_X
		cam.limit_top = cPos.y - SCREEN_CENTER_Y
		cam.limit_bottom = cPos.y + SCREEN_CENTER_Y
		
		#seq.set_pause_mode(SceneTreeTween.TWEEN_PAUSE_PROCESS)
		is_tweening=true
		var seq := get_tree().create_tween()
		seq.set_parallel(true)
		# Wondering WTF this is? The TRANS_QUAD tween does not work if
		# left+right is larger than the size of the screen. So we have to tween it one
		# screen over and then set it to the destination.
		if np[0] < limit_left: #Camera is moving left?
			seq.tween_property(           cam,'limit_left',  cam.limit_left-SCREEN_WIDTH,secs).set_trans(Tween.TRANS_QUAD)
			seq.tween_property(cam,'limit_right', np[2],secs).set_trans(Tween.TRANS_QUAD)
		elif np[0] > limit_left: #Camera is moving right?
			seq.tween_property(           cam,'limit_left',  np[0],secs).set_trans(Tween.TRANS_QUAD)
			seq.tween_property(cam,'limit_right', cam.limit_right+SCREEN_WIDTH,secs).set_trans(Tween.TRANS_QUAD)
		else: #Left border didn't change at all, just tween right border
			seq.tween_property(cam,'limit_right', np[2],secs).set_trans(Tween.TRANS_QUAD)
			#cam.limit_left = destPositions[0]
			#cam.limit_right = destPositions[2]
		
		if np[0] == limit_left and np[2]== limit_right: #If only top and bottom is being adjusted...
			if np[1] > limit_top: #Camera moving down?
				seq.tween_property(cam,'limit_top',   np[1],secs).set_trans(Tween.TRANS_QUAD)
				seq.tween_property(cam,'limit_bottom',limit_bottom+SCREEN_HEIGHT,secs).set_trans(Tween.TRANS_QUAD)
			else: #Camera moving up?
				seq.tween_property(cam,'limit_top',  limit_top-SCREEN_HEIGHT,secs).set_trans(Tween.TRANS_QUAD)
				seq.tween_property(cam,'limit_bottom',np[3],secs).set_trans(Tween.TRANS_QUAD)
		else:
			seq.tween_property(cam,'limit_top',   np[1],secs).set_trans(Tween.TRANS_QUAD)
			seq.tween_property(cam,'limit_bottom',np[3],secs).set_trans(Tween.TRANS_QUAD)
		seq.tween_callback(self,"finish_tweening_camera").set_delay(secs)

	else:
		cam.limit_left = np[0]
		cam.limit_top = np[1]
		cam.limit_right = np[2]
		cam.limit_bottom = np[3]


#So the original ShakeCamera2D script doesn't actually work correctly
#because it uses the completely wrong offset
#I just copypasted the code and fixed it

"""
MIT License

Copyright (c) 2020 Alex Nagel

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE. 
"""
export var max_offset : float =5.0
export var max_roll : float = 5.0
export var shakeReduction : float = 1.0

#Don't touch these unless you're testing it
var stress : float = 0.0
var shake : float = 0.0

var elapsed:float=0
func _process(_delta):
	if stress == 0.0:
		return
	
	elapsed+=_delta
	if elapsed>1/60: #Lock to the frame rate
		elapsed=0
		_process_shake(Vector2(0,0), 0.0, _delta)
	pass


#TODO: It's tied to the update rate which is extremely inconsistent between computers
func _process_shake(_center, _angle, delta) -> void:
	shake = stress * stress

	#rotation_degrees = angle + (max_roll * shake *  _get_noise(randi(), delta))
	
	#offset = Vector2()
	offset.x = (max_offset * shake * _get_noise(randi(), delta + 1.0))
	offset.y = (max_offset * shake * _get_noise(randi(), delta + 2.0))
	#print(offset)
	stress -= (shakeReduction / 100.0)
	
	stress = clamp(stress, 0.0, max_offset)
	
	
func _get_noise(noise_seed, time) -> float:
	var n = OpenSimplexNoise.new()
	
	n.seed = noise_seed
	n.octaves = 4
	n.period = 20.0
	n.persistence = 0.8
	
	return n.get_noise_1d(time)
	
	
func add_stress(amount : float) -> void:
	stress += amount
		

func shakeCamera(howMuch:float=3.0):
	add_stress(howMuch)
	#pass
