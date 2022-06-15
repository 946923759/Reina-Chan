extends Sprite

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
# "use strict"; # good practice - see https:#developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Strict_mode



onready var t = $Tween
func _ready():
	#set_process(Engine.editor_hint)
	pass
##Testing only
#var testFloat:float=0.0
#var testNum:int=0
#func _process(delta):
#	testFloat+=delta
#	if testFloat>.5:
#		testNum+=1
#		if testNum>4:
#			testNum=0
#		setGradeAsInt(testNum)
#		testFloat=0
		
		
# func animate():

#     # remove scheduled tweens
#     if ( this.scaleFadeTween != null ):

#         TWEEN.remove(this.scaleFadeTween) ;
#         TWEEN.remove(this.opacityFadeTween) ;
#         TWEEN.remove(this.burnTween) ;



#     var diffuseTimeWait = (30/60)*1000 ;
#     var diffuseAnimation = (22/60)*1000;
#     var time = (4.5/60)*1000     ;

#     # schedule going out tweens for JUDGMENT
#     this._mesh.material.opacity = 1.0 ;
#     var scale = 100.0 ;

#     this._mesh.material.color.r = 1.0 ;
#     this._mesh.material.color.g = 1.0 ;
#     this._mesh.material.color.b = 1.0 ;
#     # this._mesh.material.combine = THREE.AddOperation ;
#     # this._mesh.material.lightMapIntensity = 5.0 ;
#     this._mesh.scale.set(0.6,0.6) ;

#     new TWEEN.Tween( this._mesh.material ).to( {opacity: 0.7 } , diffuseTimeWait ).start();

#     this._mesh.material.opacity = 0.7 ;
#     this.scaleFadeTween = new TWEEN.Tween( this._mesh.scale ).to( { x: 1.5 , y: 0.0 }, diffuseAnimation ).delay(diffuseTimeWait).start();
#     this.opacityFadeTween = new TWEEN.Tween( this._mesh.material ).to( { opacity: 0.0 } , diffuseAnimation ).delay(diffuseTimeWait).start();
#     this.burnTween = new TWEEN.Tween( this._mesh.material.color ).to( { r:10 ,g:10,b:2 } , 1 ).delay(diffuseTimeWait).start();


#     this._mesh.scale.set(0.87, 0.87) ;
#     this._mesh.material.opacity = 1.0 ;
#     this._mesh.position.y = this._mesh.scale.y / 5;

#     #
#     new TWEEN.Tween(this._mesh.scale).to({x: 0.6, y: 0.6}, time).start();
#     new TWEEN.Tween(this._mesh.position).to({y: 0}, time).start();

# You can tell godot is a great engine because it lacks basic
# features like vertical alignment, something StepMania had in
# 2001
func animate():
	t.stop_all()
	# Ah yes because this is SO much more readable than
	# stoptweening;diffusealpha,1;zoom,2;linear,.3;zoom,1;sleep,1;zoomx,2;diffusealpha,0
	# Godot's tween system is crap and I'm tired of pretending it's not
	modulate.a=1
	t.interpolate_property(self,"scale",Vector2(2,2),Vector2(1,1),.1)
	t.interpolate_property(self,"scale:x",1,2,1,0,2,1)
	t.interpolate_property(self,"scale:y",1,0,1,0,2,1)
	t.interpolate_property(self,"modulate:a",1,0,1,0,2,1)
	t.start()
#	pass

#This function is setting what judgment to display
func setGrade(grade:String):
	var yOffset:int = 0
	match grade:
		'p':
			yOffset=0
		'gr':
			yOffset=1
		'go':
			yOffset=3
		'b':
			yOffset=4
		'm':
			yOffset=5
	region_rect.position.y=yOffset*60

func setGradeAsInt(grade:int):
	if grade>=0 and grade < 5:
		if grade>1:
			grade+=1
		region_rect.position.y=grade*60
