extends Node2D
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

# A Judgment graphic implementation needs just one function:
# animate(grade:String, comboCount:int)


onready var _banner = $Banner
onready var _combo = $Combo
onready var _whiteDigits = $Digits


func constructor():
	self.judgmentZDepth = 0.00002;
	self.maxNumDigits = 5 ;

func ready():
	self._banner.setGrade('p') ;
	self._whiteDigits.displayComboCount(0) ;

#func _process(delta):
#    pass

func animate(grade:String, comboCount:int):

	self._banner.animate() ;
	self._banner.setGrade(grade)

	if ( comboCount > 3 ):
		self._whiteDigits.displayComboCount(comboCount) ;
		self._combo.animate() ;
		self._whiteDigits.animate() ;
