extends Control

# 5 = level select
export(int,1,5) var sangvis_stage_num = 0
export(float,0,8) var delay_before_anim = 4.0
export(float,0,8) var delay_after_anim = 4.0
var go_to_stage:String = ""

var timeout:float = 6.0
var t1:SceneTreeTween

func _ready():
	if sangvis_stage_num <= 4:
		$AudioStreamPlayer.play()
	
	$Label.visible = $Label.visible and OS.is_debug_build()
	VisualServer.canvas_item_set_z_index($ColorRect.get_canvas_item(),50)
	VisualServer.canvas_item_set_z_index($Transition.get_canvas_item(),51)

	var fadeTw = create_tween()
	fadeTw.tween_property($ColorRect,"modulate:a",0.0,.25)
	
	CheckpointPlayerStats.clearEverything()
	
	#var player_stg_num = sangvis_stage
	if Globals.previous_screen != "":
		sangvis_stage_num = Globals.playerData.wilyStageNum
		print("[StageIntroSangvis] Not debugging screen")
	sangvis_stage_num = max(1,sangvis_stage_num)
	
	$Node2D/Cursor.visible = sangvis_stage_num > 4
	if sangvis_stage_num > 4:
		sangvis_stage_num = 1
		go_to_stage = get_stage_name_from_idx(sangvis_stage_num)
		_move_cursor_to_selected_icon()
		for stg_i in range(1,4):
			var actorFrame = get_node("Node2D/stg"+String(stg_i))
			actorFrame.visible = true
		timeout = 99999999.9
	else:
		$AudioStreamPlayer.play()
		print("[StageIntroSangvis] Got stg "+String(sangvis_stage_num)+"")
		go_to_stage = get_stage_name_from_idx(sangvis_stage_num)
		
		for stg_i in range(1,5):
			var actorFrame = get_node("Node2D/stg"+String(stg_i))
			actorFrame.visible= (stg_i <= sangvis_stage_num)
			if stg_i == sangvis_stage_num:
				#print("Animating stg ",stg_i)
				t1 = get_tree().create_tween()
				t1.set_parallel(false)
				
				# Surely a way to add a delay to the base tweener
				# would have made more sense
				var first:bool = true
				for n in actorFrame.get_children():
					n.visible=false
					var res = t1.tween_property(n,"visible",true,.1)
					if first:
						res.set_delay(4.0)
						first=false
					
					timeout+=.1

#var timeout:float = delay_before_anim+delay_after_anim+1
func _process(delta):
	$Label.text = String(timeout)
	timeout-=delta
	if timeout<=0:
		set_process(false)
		var t = $Transition.OnCommand()
		yield(t,"finished")
		get_tree().change_scene(go_to_stage)
	#Blink icon
	elif timeout <= 2.0:
		var n:Sprite = get_node("Node2D/stg"+String(sangvis_stage_num)+"icon")
		n.frame = int(timeout*6) % 2
	elif timeout >= 9999.9:
		var n = $Node2D/Cursor
		n.visible = int(timeout*6) % 2

func _input(_event:InputEvent):
	if _event.is_action_pressed("ui_pause"):
		timeout=0.0
		if is_instance_valid(t1):
			#Because if I don't kill it it spams the log
			t1.kill()
	elif timeout >= 9999.9:
		#We want to be able to position the cursor over the stg1/2/3/4icon 
		if _event.is_action_pressed("ui_up"):
			$select.play()
			_select_nearest_stage_icon(Vector2.UP)
		elif _event.is_action_pressed("ui_down"):
			$select.play()
			_select_nearest_stage_icon(Vector2.DOWN)
		elif _event.is_action_pressed("ui_left"):
			$select.play()
			_select_nearest_stage_icon(Vector2.LEFT)
		elif _event.is_action_pressed("ui_right"):
			$select.play()
			_select_nearest_stage_icon(Vector2.RIGHT)
		elif _event.is_action_pressed("ui_accept"):
			$Confirm.play()
			timeout = 0.0
		elif _event.is_action_pressed("ui_cancel"):
			if is_instance_valid(t1):
				t1.kill()
			Globals.change_screen(get_tree(),"ScreenSelectStage")


#Behold, the most overengineered garbage ever
func _move_cursor_to_selected_icon() -> void:
	var icon = get_node("Node2D/stg"+String(clamp(sangvis_stage_num,1,4))+"icon")
	$Node2D/Cursor.position = icon.position

func _select_nearest_stage_icon(direction:Vector2) -> void:
	var current_stage = int(clamp(sangvis_stage_num,1,4))
	var current_icon = get_node("Node2D/stg"+String(current_stage)+"icon")
	var current_pos = current_icon.position

	var found = false
	var best_stage = current_stage
	var best_perpendicular = INF
	var best_primary = INF

	for stage_i in range(1,5):
		if stage_i == current_stage:
			continue

		var icon = get_node("Node2D/stg"+String(stage_i)+"icon")
		var delta = icon.position - current_pos

		var primary = 0.0
		var perpendicular = 0.0
		if abs(direction.x) > 0.0:
			primary = delta.x * sign(direction.x)
			perpendicular = abs(delta.y)
		else:
			primary = delta.y * sign(direction.y)
			perpendicular = abs(delta.x)

		if primary <= 0.0:
			continue

		if perpendicular < best_perpendicular or (is_equal_approx(perpendicular,best_perpendicular) and primary < best_primary):
			best_perpendicular = perpendicular
			best_primary = primary
			best_stage = stage_i
			found = true

	if found:
		sangvis_stage_num = best_stage
		go_to_stage = get_stage_name_from_idx(sangvis_stage_num)
		_move_cursor_to_selected_icon()

func get_stage_name_from_idx(stage_num:int) -> String:
	var i = 0
	#To get idx from dict entry...
	for stg in Globals.STAGES_REINA:
		i+=1
		if i == stage_num+8:
			return Globals.STAGES_REINA[stg]
	#How did you get here...?
	return "ScreenTitleMenu"
