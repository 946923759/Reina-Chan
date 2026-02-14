extends "res://Screens/ScreenWithMenuElements.gd"

export(Color) var text_bg_color
export(String) var bossToLoad

onready var seq = [
	[0.0, $ZTextWalk_NoM16],
	[03.723, $ZText2],
	[07.432, $Ouroboros],
	[11.130, $Scarecrow],
	[14.800, $Alchemist],
	[18.450, $Architect],
	#[20.330, ],
	[23.100, $LogoFade],
	[INF]
]
var step = 0
onready var size = seq.size()
var tw:SceneTreeTween
onready var top:ColorRect = $top
onready var bottom:ColorRect = $bottom

#var total:float = 0.0

func _ready():
	Globals.previous_screen=self.name
	
	if Globals.eventMode:
		NextScreen="ScreenTitleJoin"
		
	for o in seq:
		if len(o)>1:
			o[1].visible=false
			
	$AudioStreamPlayer.connect("finished",self,"OffCommandNextScreen")
	
	tw = create_tween()
	tw.set_parallel()
	#fuck you
	VisualServer.canvas_item_set_z_index(top.get_canvas_item(),998)
	VisualServer.canvas_item_set_z_index(bottom.get_canvas_item(),999)
	top.visible=true
	bottom.visible=true
	
	var SCREEN_SIZE := get_viewport().get_visible_rect().size
	var SCREEN_CENTER := SCREEN_SIZE/2.0
	
	for i in range(size):
		#var startTime:float = seq[i][0]+.1
		#tw.tween_property(top,"rect_scale:y",0.0,.3).from(2.0).set_delay(startTime).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		#tw.tween_property(bottom,"rect_scale:y",0.0,.3).from(2.0).set_delay(startTime).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		
		#Scroll the black bars in
		if i < size-1:
			var endTime:float = seq[i+1][0] - .3
			tw.tween_property(top,"rect_scale:y",1.05,.3).from(0.0).set_delay(endTime).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
			tw.tween_property(bottom,"rect_scale:y",1.0,.3).from(0.0).set_delay(endTime).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
			#tw.tween_property(bottom,"rect_position:y",SCREEN_CENTER.y,1.0).from(SCREEN_SIZE.y).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func _process(delta):
	# Sync to playback position here
	var total = $AudioStreamPlayer.get_playback_position()
	if total>=seq[step][0]:
		assert(seq[step][1])
		#seq[step][1].OnCommand()
		seq[step][1].OnCommand()
		#var startTime:float = seq[step][0]
		
		if step<size-1:
			var SCREEN_SIZE := get_viewport().get_visible_rect().size
			var SCREEN_CENTER := SCREEN_SIZE/2.0
			var newTw = create_tween()
			newTw.set_parallel()
			newTw.tween_property(top,"rect_scale:y",0.0,.3).from(1.05).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			newTw.tween_property(bottom,"rect_scale:y",0.0,.3).from(1.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			#newTw.tween_property(bottom,"rect_position:y",SCREEN_SIZE.y,.3).from(SCREEN_CENTER.y).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

		if step>0:
			seq[step-1][1].queue_free()
		step+=1
