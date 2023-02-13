extends Node

#Godot's VisualScript makes a 4 line function way way more complex than
#it needs to be

var skorp = preload("res://Character Sprites/skorp/NPC_T5000.tscn")

export(NodePath) var bossNode

func execute():
	var parent = get_parent()
	var e = skorp.instance()
	e.spawnType=0
	e.position = get_node(bossNode).position
	if e.position.x < 300: #Safeguard against spawning on the breakable blocks
		e.velocity.x=1000
	get_parent().add_child(e)
	
	e.connect("cutscene_finished",parent.get_node("Door"),"unlock_door")
	e.connect("cutscene_finished",self,"unlock_lol")

#This is the wrongest way to write an unlock but whatever
func unlock_lol():
	Globals.playerData.specialAbilities[Globals.SpecialAbilities.Grenade]=true
