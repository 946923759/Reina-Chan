extends Node2D

export(bool) var overwrite_pos = true
export(bool) var draw_afterimge = false
export(bool) var run_automatically = true
export(String) var bossToLoad

#What the fuck is this doing here
var bosses = {
	"StageArchitect_v2.tscn":"res://Stages_Reina/Bosses/Architect/BossArchitect_v2.tscn",
	"Alchemist_v2.tscn":"res://Stages_Reina/Bosses/Alchemist/BossAlchemist.tscn",
	"Scarecrow.tscn":"res://Stages_Reina/Bosses/Scarecrow/BossScarecrow.tscn",
	"StageOuroboros.tscn":"res://Stages_Reina/Bosses/Ouroboros/BossOuroboros.tscn"
}

var bi:KinematicBody2D
var afterimages = []
func _ready():
	set_process(false)
	if run_automatically:
		InitCommand()
		set_process(true)

func InitCommand():
	#var position = get_viewport().get_visible_rect().size/2
	var b
	if bossToLoad:
		if typeof(bossToLoad)==TYPE_STRING and bossToLoad in bosses:
			b = load(bosses[bossToLoad])
		else:
			b = bossToLoad
	elif Globals.nextStage:
		var stg:String = Globals.nextStage.rsplit("/",false,1)[1]
		if !(stg in bosses):
			return
		b = load(bosses[stg])
	else:
		b = load("res://Stages_Reina/Bosses/Architect/BossArchitect_v2.tscn")
	bi = b.instance()
	self.add_child(bi)
	print(bi.name)
	if bi.name == "BossScarecrow":
		bi.position = Vector2(0,-20)
	#else:
	bi.HPBar.visible=false
	bi.collision_layer=0
	
	if draw_afterimge:
		for i in range(4):
			afterimages.append(get_node("Afterimage"+String(i+1)))
			afterimages[i].scale = bi.sprite.scale
			print(ceil((i+1)/2.0))
		bi.z_index = 2
		#print(bi.sprite.position.y)

func OnCommand():
	set_process(true)
func OffCommand():
	set_process(false)

var time:float=0
var played:bool=false
func _process(delta):
	if overwrite_pos:
		position = get_viewport().get_visible_rect().size/2
	#$Label2.text=String(get_viewport().get_visible_rect().size)
	time+=delta
	if time > .3:
		if played==false:
			bi.playIntro(false,false)
			played=true
		
		if draw_afterimge:
			for i in range(afterimages.size()):
				var spr = afterimages[i];
				var tex = bi.sprite.frames.get_frame(bi.sprite.get_animation(), bi.sprite.frame)
				spr.texture = tex
				spr.flip_h = bi.sprite.flip_h
				# -1 or 1
				var offset = ((i+1)&1*2) - 1
				spr.position.x += offset*delta*40.0*ceil((i+1)/2.0)
				spr.position.y = bi.position.y + bi.sprite.position.y
		else:
			set_process(false)
		#print(afterimages[0].position.x)


func _on_Node_item_rect_changed():
	pass # Replace with function body.
