extends "res://Various Objects/BossWarning/WARNING_new.gd"

export(NodePath) var boss_node

func run_event(sender):
	if disabled:
		return
	disabled=true

	playerObj=sender

	if Globals.playCutscenes==false or CheckpointPlayerStats.watchedBossIntro or message_id.empty():
		get_node(boss_node).playIntro(false)
		showWarning(false)
	else:
		part1()

func playSound():
	$FinalRound.play()

func part1():
	playerObj.set_physics_process(false)
	var newCutscene = $DialoguePlayerInGame
	newCutscene.connect("cutscene_finished",self,"part2")
	
	print("Playing boss cutscene!")
	#New cutscene format
	#func init_(message_:PoolStringArray,delim="|",msgColumn_:int=1):
	newCutscene.init_(
		Globals.get_stage_cutscene(message_id),
		"\t",
		Globals.stage_cutscene_data['msgColumn'],
		self
	)


func part2():
	var callback = get_node(boss_node).playIntro();
	if callback.stream == null:
		printerr("[BossBase.IntroSound] There's no audio file assigned for this boss, idiot. Change IntroSound actor in the boss class.")
		showWarning()
		return
	callback.connect("finished",self,"showWarning")

func part5():
	CheckpointPlayerStats.watchedBossIntro=true
	get_node(boss_node).enabled=true
	playerObj.set_physics_process(true)
	sprite.set_process(false)
	sprite.visible=false
