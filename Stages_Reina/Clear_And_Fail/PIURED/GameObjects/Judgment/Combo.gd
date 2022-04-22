extends Sprite
# /*
#  * # Copyright (C) Pedro G. Bascoy
#  # This file is part of piured-engine <https://github.com/piulin/piured-engine>.
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
#  # along with piured-engine.If not, see <http://www.gnu.org/licenses/>.
#  *
#  */

onready var t:Tween = $Tween


const diffuseTimeWait = (30/60)*1000;
const diffuseAnimation = (22/60)*1000;
const time = (4.5/60)*1000;
func animate():
    var scale = 100.0 ;
    self.modulate.r=1.0
    self.modulate.g=1.0
    self.modulate.b=1.0


    #Clear any running tweens
    # if ( this.tweenOpacityEffect !== null ) {
    #     TWEEN.remove(this.scaleFadeTween) ;
    #     TWEEN.remove(this.opacityFadeTween) ;
    #     TWEEN.remove(this.burnTween) ;
    # }
    t.stop_all()
    self.modulate.a=1.0

    # similarly we update the tweens for the combo label
    #  self._mesh.material.opacity = 1.0;
    #  self._mesh.scale.set(0.37, 0.37);
    #  self.scaleFadeTween = new TWEEN.Tween( self._mesh.scale).to({
    #     x: 0.97,
    #     y: 0.0
    # }, diffuseAnimation).delay(diffuseTimeWait).start();
    t.interpolate_property(self,'scale',Vector2(1.2,1.2),Vector2(1.0,1.0),.3,Tween.TRANS_LINEAR)

    # new TWEEN.Tween(  self._mesh.material ).to( { opacity: 0.7 } , diffuseTimeWait ).start();
    #  self.burnTween = new TWEEN.Tween(  self._mesh.material.color ).to( { r:scale ,g:scale,b:scale } , 1 ).delay(diffuseTimeWait).start();

    #  self._mesh.material.opacity = 0.7 ;

    #  self.opacityFadeTween = new TWEEN.Tween( self._mesh.material).to({opacity: 0.0}, diffuseAnimation).delay(diffuseTimeWait).start();

    #  self._mesh.scale.set(0.58, 0.63);
    #  self._mesh.material.opacity = 1.0;
    # //  self._mesh.position.y = -  self._mesh.scale.y / 6;


    # new TWEEN.Tween( self._mesh.scale).to({x: 0.37, y: 0.37}, time).start();
    # new TWEEN.Tween( self._mesh.position).to({y: 0}, time).start();