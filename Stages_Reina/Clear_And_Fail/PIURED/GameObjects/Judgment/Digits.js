/*
 * # Copyright (C) Pedro G. Bascoy
 # This file is part of piured-engine <https://github.com/piulin/piured-engine>.
 #
 # piured-engine is free software: you can redistribute it and/or modify
 # it under the terms of the GNU General Public License as published by
 # the Free Software Foundation, either version 3 of the License, or
 # (at your option) any later version.
 #
 # piured-engine is distributed in the hope that it will be useful,
 # but WITHOUT ANY WARRANTY; without even the implied warranty of
 # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 # GNU General Public License for more details.
 #
 # You should have received a copy of the GNU General Public License
 # along with piured-engine.If not, see <http://www.gnu.org/licenses/>.
 *
 */
"use strict"; // good practice - see https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Strict_mode

class Digits extends GameObject {

    _whiteDigits ;

    _whiteDigitsObjects = [];

    _object ;


    constructor(resourceManager, maxNumDigits) {

        super( resourceManager );

        this.opacityFadeTween = null ;

        this.maxNumDigits = maxNumDigits ;

        this._whiteDigits = new THREE.Object3D() ;
        this._object = new THREE.Object3D() ;

        this.XscaleDigits = 0.85 ;
        this.XsizeDigits = 60/80 ;
        // Load <count> number of digits into the arrays; one for each color
        for ( var i = 0 ; i < this.maxNumDigits ; i++ ) {


            let normal = new Digit(this._resourceManager) ;

            // place them into position
            normal.object.scale.set( this.XscaleDigits , this.XscaleDigits ) ;
            normal.object.position.x = i*this.XsizeDigits*normal.object.scale.x ;
            this._whiteDigitsObjects.push(normal) ;
            this._whiteDigits.add(normal.object) ;



        }

        this._object.add(this._whiteDigits) ;

        this._whiteDigits.position.x -=  (this.maxNumDigits-1)*this.XsizeDigits*this.XscaleDigits/2 ;

    }

    ready() {


    }


    update(delta) {

    }

    animate() {

        const diffuseTimeWait = (30/60)*1000 ;
        const diffuseAnimation = (22/60)*1000;
        const time = (4.5/60)*1000     ;

        if ( this.opacityFadeTween !== null ) {
            TWEEN.remove(this.opacityFadeTween) ;
        }

        for ( let digit of this._whiteDigitsObjects ) {
            digit.animate() ;
        }
        this._object.scale.x = 1.05 ;
        this._object.scale.y = 1.05 ;
        this._whiteDigits.position.y = - 0.17;
        new TWEEN.Tween(this._whiteDigits.position).to({y: 0}, time).start();
        new TWEEN.Tween(this._object.scale).to({y: 1.0, x: 1.0}, time).start();
    }

    displayComboCount(currentCombo) {
        const digitsInCount = currentCombo.toString().length ;
        const neededDigits = digitsInCount > 3 ? digitsInCount : 3 ;
        const difference = this.maxNumDigits - neededDigits ;


        // update position of numbers
        this._whiteDigits.position.x = 0 ;
        this._whiteDigits.position.x -= (neededDigits-1)*this.XsizeDigits*this.XscaleDigits/2 + difference*this.XsizeDigits*this.XscaleDigits;

        for ( var i = 0 ; i < neededDigits ; i++ ) {
            const index = this._whiteDigitsObjects.length - i - 1 ;
            let digit = this._whiteDigitsObjects[index] ;
            // make sure we show this digits
            const digitValue = Math.floor((currentCombo / Math.pow(10,i)) % 10); // 2

            digit.displayDigit(digitValue) ;

        }

        // do not show the remainder digits, using an offset out of the range.
        for ( var i = neededDigits ; i < this._whiteDigitsObjects.length ; i++ ) {
            const index = this._whiteDigitsObjects.length - i - 1 ;
            let digit = this._whiteDigitsObjects[index] ;
            digit.hide() ;
        }
    }

    getCoordinatesForDigit(digit) {

        const col = digit % 4 ;
        const row = 3 - Math.floor( digit/4 ) ;

        return [row, col] ;

    }


    get object () {
        return this._object ;
    }
}