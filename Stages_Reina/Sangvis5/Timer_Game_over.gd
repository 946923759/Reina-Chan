extends CanvasLayer

func _ready():
	set_process(false)

func _on_Boss_enabled():
	$Node2D.visible = true
	set_process(true)

var time_remain:float = 200.00
func _process(delta):
	time_remain-=delta
	$Node2D/TimeRemaining.text = "%0.2f"%time_remain
