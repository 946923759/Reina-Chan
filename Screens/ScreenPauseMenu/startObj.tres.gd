extends Node2D
#tool

#Because Globals.stagesToString doesn't work in tool mode
var stagesToString = [
	"Buster",
	"Architect",
	"Alchemist",
	"Ouroboros",
	"Scarecrow",
	"???",
	"???",
	"???",
	"???",
	"Glorylight"
]

export(Globals.Weapons) var weapon = 0 setget set_weapon
export(bool) var focused = false setget set_focus

func set_focus(f):
	if f:
		GainFocus()
	else:
		LoseFocus()
	focused=f
	

func set_weapon(w):
	if Engine.editor_hint:
		$Label.text=stagesToString[w]
	#else:
		
		#print("Set!")
	$Sprite.weapon=w
	weapon=w
	
func set_ammo(percent:float):
	$Sprite.set_ammo(percent)

#func init(sprite,toDraw,itemName):
#	$Label.text=itemName
#	$Sprite.init(sprite,toDraw)

func GainFocus():
	$Label.modulate=Color(0.21,0.63,1,1)
	$Sprite.use_parent_material=true
	$Sprite.update()
	
func LoseFocus():
	$Label.modulate=Color(1,1,1,1)
	$Sprite.use_parent_material=false
	$Sprite.update()

func _ready():
	set_weapon(weapon)
	if !Engine.editor_hint:
		if weapon==0 or weapon==9:
			$Label.text=INITrans.GetString("Weapons",Globals.stagesToString[weapon]+Globals.characterToString(Globals.playerData.currentCharacter))
		else:
			$Label.text=INITrans.GetString("Weapons",Globals.stagesToString[weapon])
	pass
#func _ready():
#	$Label.text=INITrans.GetString("Weapons",Globals.stagesToString[weapon])
