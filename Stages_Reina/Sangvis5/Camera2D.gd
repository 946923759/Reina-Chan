extends Camera2D


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


#Lock to the frame rate with _physics_process
func _physics_process(_delta):
	if stress <= 0.0:
		set_physics_process(false)
		return
	
	_process_shake(Vector2(0,0), 0.0, _delta)
	pass

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
		

func shake_camera(howMuch:float=3.0):
	add_stress(howMuch)
	set_physics_process(true)
	#pass
