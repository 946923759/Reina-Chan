extends "res://Player Files/8bitPlayer/8bitPlayer.gd"

# PoolByteArrays are read only (assignment only, no modify within array)
# so this can only be used to store the data.
var frameData_stored:PoolByteArray = PoolByteArray()

#Here goes nothing!
var frameData_tmp = [
	
]

var recordingStartPosition:Vector2
var currentFrame:int = 0
enum RECORDING {
	INACTIVE, # Not recording
	READY,    # Start recording on any press
	RECORDING, # Recording right now
	PLAYBACK
}
var isRecording:int = RECORDING.INACTIVE

func stopRecording():
	isRecording = RECORDING.INACTIVE
	frameTimer=0
	currentFrame=0
	frameData_stored = PoolByteArray(frameData_tmp)

var prevFrameChecked=0
func getRecordedInputAtFrame(frame,input_idx,just_pressed:bool=false) -> bool:
	if just_pressed:
		if frame==prevFrameChecked:
			return false
		prevFrameChecked=frame
		return (frameData_stored[frame] & 1<<input_idx) > 0
	else:
		return frameData_stored[frame] & 1<<input_idx

#func startPlayback():
#	isRecording

func setDebugInfoText():
	var t = $CanvasLayer/DebugDisplay/FreeRoam
	var st = "RECORD STATE: "
	match isRecording:
		RECORDING.INACTIVE:
			st+=" INACTIVE"
		RECORDING.READY:
			st+=" READY (WAIT FOR INPUT)"
		RECORDING.RECORDING:
			st+=" ACTIVE :: FRAME="+String(currentFrame)
		RECORDING.PLAYBACK:
			st+=" PLAYBACK :: FRAME="+String(currentFrame)
	t.text = st

func get_menu_buttons_input(_delta):
	if Input.is_action_just_pressed('DebugButton1'):
		freeRoam = !freeRoam
		setDebugInfoText()
		CheckpointPlayerStats.usedDebugMode=true
		
	elif Input.is_action_just_pressed("DebugButton2"):
		if noClip:
			set_collision_mask_bit(0,true)
			set_collision_layer_bit(0,true)
			noClip = false
		else:
			set_collision_mask_bit(0,false)
			set_collision_layer_bit(0,false)
			noClip = true;
			freeRoam=true
		setDebugInfoText()
		CheckpointPlayerStats.usedDebugMode=true
		
	elif Input.is_action_just_pressed("DebugButton3"):
		if lastDebugWarped+1 < stageRoot.debug_warp_points.size():
			lastDebugWarped+=1
		else:
			lastDebugWarped=0
		#print(tile_scale)
		print("Warped player to "+String(stageRoot.debug_warp_points[lastDebugWarped]))
		position = stageRoot.debug_warp_points[lastDebugWarped]
		$Camera2D.adjustCamera([-10000000,-10000000,10000000,10000000],0)
	elif Input.is_action_just_pressed("DebugButton4"):
		if isRecording==RECORDING.INACTIVE:
			isRecording=RECORDING.READY
		elif isRecording==RECORDING.RECORDING or isRecording==RECORDING.READY:
			stopRecording()
		setDebugInfoText()
	elif Input.is_action_just_pressed("DebugButton5"):
		if frameData_stored.empty():
			var t = $CanvasLayer/DebugDisplay/FreeRoam
			t.text = "No recording saved!"
		else:
			global_position=recordingStartPosition
			currentFrame=0
			HP=MAX_HP
			isRecording=RECORDING.PLAYBACK
			setDebugInfoText()

# Because it is possible to miss the frame the player shoots on,
# store it until it gets recorded
var storedShootPressForRecord:bool=false

func get_input(delta):
	isOnFloor=is_on_floor()

	#I WANT REFERENCE VARIABLES REEEEEEEEE
	if canAirDash==false and isOnFloor and Globals.playerData.specialAbilities[Globals.SpecialAbilities.AirDash]:
		canAirDash=true
	if hasGrenadeAbility==false and Globals.playerData.specialAbilities[Globals.SpecialAbilities.Grenade]:
		hasGrenadeAbility=true
		#Refresh to show grenade meter after unlocking it
		switchWeapon(false)

#	var right = Input.is_action_pressed('ui_right')
#	var left = Input.is_action_pressed('ui_left')
#	var up = Input.is_action_pressed('ui_up')
#	var down = Input.is_action_pressed('ui_down')
#	var jump = Input.is_action_just_pressed('ui_accept')
#	var shoot = Input.is_action_just_pressed("ui_cancel")
	var left = Input.is_action_pressed(INPUT.LEFT[controller_index])
	var right = Input.is_action_pressed(INPUT.RIGHT[controller_index])
	var up = Input.is_action_pressed(INPUT.UP[controller_index])
	var down = Input.is_action_pressed(INPUT.DOWN[controller_index])

	var jump = Input.is_action_just_pressed(INPUT.FORWARD[controller_index])
	var shoot = Input.is_action_just_pressed(INPUT.BACK[controller_index])
	
	if isRecording==RECORDING.PLAYBACK:
		left  = getRecordedInputAtFrame(currentFrame,0)
		right = getRecordedInputAtFrame(currentFrame,1)
		up    = getRecordedInputAtFrame(currentFrame,2)
		down  = getRecordedInputAtFrame(currentFrame,3)
		jump  = getRecordedInputAtFrame(currentFrame,4)
		shoot = getRecordedInputAtFrame(currentFrame,5,true)

	if state==State.DASH: #No shooting while dashing
		shoot=false

	var grenade_input = (shoot and up) or (
		Input.is_action_just_pressed(INPUT.THIRD[controller_index]) and
		state!=State.DASH
	)
	#Can't throw grenades if using other weapons because it will
	#conflict with the alchemist rockets.
	#...Even though square will also shoot it.
	grenade_input = grenade_input and currentWeapon==Globals.Weapons.Buster
	
	#Cancel it here instead of accounting for it anywhere else
	#you can move in the split second between Zero falling though the ladder top and grabbing onto
	#the ladder, so cancel it here so they actually snap on correctly
	if (left and right) or movementLocked or grabbingLadder:
		left = false;
		right = false;
		
	idleTimer=0.0
	
	#All this shit is copypasted from the example platformer so I have no idea how it works
	# A good idea when implementing characters of all kinds,
	# compensates for physics imprecision, as well as human reaction delay.
	if grenade_input and hasGrenadeAbility:
		if (Globals.playerData.gameDifficulty <= Globals.Difficulty.EASY or bulletManager.get_num_bullets() < 3):
			throwGrenade();
	elif shoot:
		if currentWeapon == Globals.Weapons.Alchemist and weaponMeters[currentWeapon]>=Globals.weaponEnergyCost[currentWeapon]:
			if is_on_floor() and dash_time<=0:
				state = State.DASH_ATTACK
				dash_time=.5
				#var ss = -1.0 if sprite.flip_h else 1.0
# warning-ignore:narrowing_conversion
				weaponMeters[currentWeapon]=max(0,weaponMeters[currentWeapon]-Globals.weaponEnergyCost[currentWeapon])
				HPBar.updateAmmo(weaponMeters[currentWeapon]/144.0,false)
				sprite.set_animation("DashAttack")
			#else, do nothing
		elif currentWeapon == Globals.Weapons.Scarecrow and weaponMeters[currentWeapon]>=Globals.weaponEnergyCost[currentWeapon]:
			#var facing:int = -1 if sprite.flip_h else 1
			scarecrowArea.position.x = abs(scarecrowArea.position.x)*-1 if sprite.flip_h else abs(scarecrowArea.position.x)
			
			scarecrowSpin.set_flipped(sprite.flip_h)
			
			
			if scarecrowArea.start_thread(bullet, scarecrowSpin, .1):
# warning-ignore:narrowing_conversion
				weaponMeters[currentWeapon]=max(0,weaponMeters[currentWeapon]-Globals.weaponEnergyCost[currentWeapon])
				HPBar.updateAmmo(weaponMeters[currentWeapon]/144.0,false)
				
				
				scarecrowSpin.appear_quick()
				scarecrowSpin.disappear()
				
			#scarecrowArea.monitoring=false
			#var t:Tween = scarecrowSpin.t
			#t.
			#t.interpolate_callback(scarecrowSpin,0.0,"set_physics_process",false)
		else:
			shoot_time = 0
			if (Globals.playerData.gameDifficulty <= Globals.Difficulty.EASY or bulletManager.get_num_bullets() < 3) and weaponMeters[currentWeapon]>=Globals.weaponEnergyCost[currentWeapon]:
				
				var bi
				var ss:float
				if sprite.flip_h:
					ss = -1.0
				else:
					ss = 1.0
				#Note: $ is shorthand for get_node()
				#Right here it's doing get_node("bullet_shoot")
				#ternary: var p = 1 if f else -1
				var pos = position + Vector2(73*ss, 10)
				if state == State.ON_LADDER:
					pos = position + Vector2(95*ss, -20)
				
				if currentWeapon!=Globals.Weapons.Buster:
# warning-ignore:narrowing_conversion
					weaponMeters[currentWeapon]=max(0,weaponMeters[currentWeapon]-Globals.weaponEnergyCost[currentWeapon])
					#print(ceil(weaponMeters[currentWeapon]/128.0*32))
					HPBar.updateAmmo(weaponMeters[currentWeapon]/144.0,false)
				if currentWeapon==Globals.Weapons.Architect:
					bi = archiRocket.instance()
					bi.position = pos
					#get_parent().add_child(bi)
					bulletHolder.add_child(bi)
					bi.init(int(ss))
					
				#Same copypasted code as Architect
				elif currentWeapon==Globals.Weapons.Ouroboros:
					#print("Checked tile "+String(pos2cell(position)+Vector2(ss,0))+", got "+String(tile))
					
					# Check if the tile where the snake would spawn is a wall.
					# If it is, spawn the snake at the player's position instead.
					if tiles.get_cellv(pos2cell(position)+Vector2(ss,0)) >= 0:
						pos.x=position.x
					
					bi = wpnSnake.instance()
					bi.position = pos
					#get_parent().add_child(bi)
					bulletHolder.add_child(bi)
					bi.init(int(ss))
				else: #Should always fall back to bullet!
					bi = bullet.instance()
					
					
					bi.position = pos
					#get_parent().add_child(bi)
					bulletHolder.add_child(bi)
					#KinematicBody2D only
					#bi.linear_velocity = Vector2(800.0 * ss, 0)
					#RigidBody2D only
					bi.init(Vector2(13*ss,0))
				
				add_collision_exception_with(bi) # Make bullet and this not collide
				
				if Globals.playerData.gameDifficulty > Globals.Difficulty.EASY:
					bulletManager.push_bullet(bi)
				else:
#					for child in bulletHolder.get_children():
#						if is_instance_valid(child) and child.get_class()=="KinematicBody2D":
#							#print(child.get_class())
#							#child.add_collision_exception_with(bi)
#							bi.add_collision_exception_with(child)
					pass
				if sprite.animation=="IdleShoot":
					sprite.frame = 0
				shoot_sprite_time = 0.3
				$ShootSound.play()
	else:
		shoot_time += delta
		
	#TODO: This is causing input locks for 1 frame because for the frame
	#you jump, you aren't moving anymore...
	if jump and is_on_floor():
		velocity.y = jump_speed
		state = State.JUMPING
	elif state == State.ON_LADDER:
		#Maybe waste of CPU?
		velocity.y = 0
		#Don't allow moving while shooting
		if up and shoot_sprite_time <=0:
			velocity.y -= 100
		if down and shoot_sprite_time<=0: #and position.y > $Camera2D.limit_bottom+40
			velocity.y += 100
		#Don't allow pressing jump while climbing up the ladder because
		#it creates one frame of the jump animation
		if jump and !up: 
			state = State.FALLING
			sprite.play()
		#This may have been a bad idea
		if left:
			sprite.flip_h = true
		if right:
			sprite.flip_h = false
		
		velocity = velocity.normalized() * SPEED
	#Your normal movement processing
	else:
		
		if right and position.x < $Camera2D.destPositions[2]-40:
			velocity.x = run_speed
				
			sprite.flip_h = false
		elif left and position.x > $Camera2D.destPositions[0]+40:
			velocity.x = -run_speed
			
			sprite.flip_h = true
		elif !movementLocked and state!=State.DASH and state!=State.DASH_ATTACK: #If movement locked, assume velocity should be preserved
			velocity.x=0
		if up:
			var tile = tiles.get_cellv(pos2cell(position))
			if tile == LADDER_TILE_ID or tile == LADDER_TOP_TILE_ID:
				sprite.set_animation("LadderBegin")
				#get position of cell then multiply to get actual character position then offset by half of cell width multiplied by scale
				position.x = pos2cell(position).x*16*4+8*4;
				velocity=Vector2(0,-1)
				#position = Vector2(round(floor(position.x)/16/4)*16*4+8*4, position.y)
				state = State.ON_LADDER
				print("Ladder!")
		if down and !movementLocked:
			#print(String()))
			var tilePos = pos2cell(position)
			tilePos.y +=1
			#Get tile underneath you
			var tile = tiles.get_cellv(tilePos)
			var cameraBottom = pos2cell(Vector2(position.x,$Camera2D.limit_bottom))
			#print(String(tilePos.y)+" < "+String(cameraBottom.y)+"?")
			if tile == LADDER_TOP_TILE_ID and tilePos.y < cameraBottom.y: #Don't allow going down on ladders you can't see
				#print("attaching to ladder")
				sprite.set_animation("LadderBegin")
				position.x = pos2cell(position).x*16*4+8*4;
				set_collision_mask_bit(0,false)
				set_collision_layer_bit(0,false)
				#velocity = 
				lockMovement(.05,Vector2(0, 500),false)
				#position = Vector2(round(floor(position.x)/16/4)*16*4+8*4, position.y)
				#grabbingLadder = true
				state = State.GRABBING_LADDER
			#else:
			#	print("Can't go down ladder!")
			#	print(String(tilePos.y)+" < "+String(cameraBottom.y)+"?")
			#	print(String(tile)+"!="+String(LADDER_TILE_ID)+"?")
			#Example for one way platforms (I don't know if 7 is correct)
			#elif tile == 7:
			#	position.x = pos2cell(position).x*16*4+8*4;
			#	#Don't set x velocity since we want them to keep moving at the same rate
			#	velocity.y = 300
			#	set_collision_mask_bit(0,false)
			#	set_collision_layer_bit(0,false)
		if canAirDash:
			#Allowing dash on R2 was way too powerful
			if (down and jump): #or Input.is_action_pressed("gameplay_dash"):
				state = State.DASH
				dash_time=.5
				sprite.set_animation("Dash")
				canAirDash=false
		if state == State.JUMPING:
			var jumpHeld = Input.is_action_pressed(INPUT.FORWARD[controller_index])
			if isRecording==RECORDING.PLAYBACK:
				jumpHeld = getRecordedInputAtFrame(currentFrame,4)
			
			#Cancel upward momentium if jump button is let go
			#I'm pretty sure this can be simplified into one if statement
			if velocity.y < 0 and !jumpHeld:
				velocity.y = 0
				state=State.FALLING
				
	
	frameTimer+=delta
	if frameTimer > 5.0/60.0:
		frameTimer=0
		if isRecording==RECORDING.READY:
			if left or right or jump or shoot:
				recordingStartPosition = global_position
				isRecording=RECORDING.RECORDING
		#Not elif! Because the above will set it to recording on input!
		if isRecording==RECORDING.RECORDING:
			if currentFrame < 360:
				jump = Input.is_action_pressed(INPUT.FORWARD[controller_index])
				var thisFrameInput = Globals.bitArrayToInt32([
					left, right, up, down, jump, storedShootPressForRecord
				])
				frameData_tmp.push_back(thisFrameInput)
				currentFrame+=1
			else:
				stopRecording()
			storedShootPressForRecord=false
			
		elif isRecording==RECORDING.PLAYBACK:
			if currentFrame < frameData_stored.size()-1:
				currentFrame+=1
			else:
				isRecording=RECORDING.INACTIVE
		setDebugInfoText()
	else:
		storedShootPressForRecord = shoot or storedShootPressForRecord

func die():
	if isDead == false:
		isDead = true
		$CanvasLayer/Timer.set_process(false)
		set_physics_process(false)
		HP = 0
		HPBar.updateHP(HP)
		sprite.visible = false
		
		var sp = deathAnimation.instance()
		sp.position=position-Vector2(48,16)
		get_parent().add_child(sp)
		$DieSound.play()
		yield($DieSound,"finished")
		
		var t = $CanvasLayer/TransitionOut.OnCommand()
		yield(t,"finished")
		
		Globals.change_screen(get_tree(),"ScreenTitleMenu")
