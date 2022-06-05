extends Node2D

#/*
# * # Copyright (C) Pedro G. Bascoy
# # This file is part of piured-engine <https://github.com/piulin/piured-engine>.
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
# # along with piured-engine.If not, see <http://www.gnu.org/licenses/>.
# *
# */

var playerStages:Array


func constructor(song):

	#super(resourceManager);
	self.animationRate = 30;
	self.song = song;

	#self._object = new THREE.Object3D();

	self.playerStages = [
		$PlayerStage
	] ;

	#for noteskin in noteskins:
	#	self.configureNoteTextures(noteskin)


# This function seems to get the scores?
#retrievePerformancePlayerStages() {
#	let performances = [] ;
#	for (let i = 0 ; i < self._playerStages.length ; i++) {
#		performances.push( self._playerStages[i].judgment.performance ) ;
#	}
#	return performances ;
#}

#configureNoteTextures(noteskin) {
#	new StepNoteTexture(self._resourceManager, 'dl', self.animationRate, noteskin) ;
#	new StepNoteTexture(self._resourceManager, 'ul', self.animationRate, noteskin) ;
#	new StepNoteTexture(self._resourceManager, 'c', self.animationRate, noteskin) ;
#	new StepNoteTexture(self._resourceManager, 'ur', self.animationRate, noteskin) ;
#	new StepNoteTexture(self._resourceManager, 'dr', self.animationRate, noteskin) ;
#
#	new HoldExtensibleTexture(self._resourceManager, 'dl', self.animationRate, noteskin) ;
#	new HoldExtensibleTexture(self._resourceManager, 'ul', self.animationRate, noteskin) ;
#	new HoldExtensibleTexture(self._resourceManager, 'c', self.animationRate, noteskin) ;
#	new HoldExtensibleTexture(self._resourceManager, 'ur', self.animationRate, noteskin) ;
#	new HoldExtensibleTexture(self._resourceManager, 'dr', self.animationRate, noteskin) ;
#}
#
#configureBG() {
#
#	self._bg = new Background(self._resourceManager, self._playerStages[0].beatManager) ;
#	self._bg.object.position.y = -3 ;
#	self._bg.object.position.z = -1 ;
#	self._object.add(self._bg.object) ;
#
#}


func addPlayerStage( playerConfig, playBackSpeed ):


	let lifebarOrientation ;

	if ( self._playerStages.length % 2 === 0 ) {
		lifebarOrientation = 'left2right' ;
	} else {
		lifebarOrientation = 'right2left' ;
	}


	let stage = new PlayerStage(self._resourceManager,
		self.song,
		playerConfig,
		playBackSpeed,
		self._playerStages.length,
		lifebarOrientation) ;

	stage.setScale(playerConfig.scale) ;

	self._object.add(stage.object) ;
	self._playerStages.push(stage) ;
	self.adjustPlayerStages() ;

	// We can only configure the background if we have at least one stage (beat manager) set up.
	if ( self._playerStages.length === 1 )  {
		self.configureBG() ;
	}

	// stageID
	return self._playerStages.length -1 ;


}

logFrame(playerStageId, json) {
	self._playerStages[playerStageId].logFrame(json) ;
}

adjustPlayerStages() {

	let no_stages = self._playerStages.length ;

	// if (no_stages === 1) {
	//     return ;
	// }


	let distance = 0 ;
	if (no_stages === 2 ) {
		distance = 7 ;
	} else  {
		distance = 5 ;
	}

	for (let i = 0 ; i < no_stages ; i++ ) {
		if (  self.song.getLevelStyle(self._playerStages[i]._level) === 'pump-double' || self.song.getLevelStyle(self._playerStages[i]._level) === 'pump-halfdouble' ) {
			distance = 9 ;
			break ;
		}
	}


	let Xpos = -(distance*no_stages)/2 + distance/2;

	for (let i = 0 ; i < no_stages ; i++ ) {
		self._playerStages[i].object.position.x = Xpos + self._playerStages[i].playerConfig.receptorX ;
		self._playerStages[i].object.position.y = self._playerStages[i].playerConfig.receptorY ;
		Xpos += distance ;
	}

}

setNewPlayBackSpeed ( newPlayBackSpeed ) {
	for (let i = 0 ; i < self._playerStages.length ; i++ ) {
		self._playerStages[i].setNewPlayBackSpeed ( newPlayBackSpeed ) ;
	}
}

updateOffset(stageId, newOffsetOffset) {
	self._playerStages[stageId].beatManager.updateOffset(newOffsetOffset) ;
}

ready() {


}

update(delta) {


}

get object () {
	return self._object ;
}
