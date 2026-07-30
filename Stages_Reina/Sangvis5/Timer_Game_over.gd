extends CanvasLayer
signal timer_expired()

var time_remain:float = 180.00

func _ready():
	#0 to 5, so medium would be 2
	var difficulty = Globals.playerData.gameDifficulty
	#Add more time if easier and subtract if harder
	time_remain -= (difficulty-2)*30
	set_process(false)

func _on_Boss_enabled():
	$Node2D.visible = true
	set_process(true)

func _process(delta):
	time_remain-=delta
	if time_remain <= 0.0:
		emit_signal("timer_expired")
		set_process(false)
	$Node2D/TimeRemaining.text = "%0.2f"%time_remain
