extends VisibilityNotifier2D

export(int,0,8) var bitToCheck = 0

func _ready():
	self.connect("screen_entered",self,"check_bit")

func check_bit():
	if CheckpointPlayerStats.temporaryStageStats & 1<<bitToCheck:
		get_parent().lock_door()
