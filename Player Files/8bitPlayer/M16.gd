extends "res://Player Files/8bitPlayer/8bitPlayer.gd"


onready var a1 = get_node("Sprite/AfterImage1")
onready var a2 = get_node("Sprite/AfterImage2")
onready var a3 = get_node("Sprite/AfterImage3")
var oldPositions:PoolVector2Array = PoolVector2Array()


var playerChargeShot = preload("res://Player Files/8bitPlayer/PlayerChargeShot.tscn")
onready var chargingAnim:AnimatedSprite = $Charging
onready var chargeStart:AudioStreamPlayer2D = $ChargeStartSound
onready var chargeLoop:AudioStreamPlayer2D = $ChargeLoopSound
onready var chargeShotS:AudioStreamPlayer2D = $ChargeShotFireSound

func _ready():
	#oldPositions = PoolVector2Array()
	oldPositions.resize(6)
	a1.visible=false
	a2.visible=false
	a3.visible=false
	#a1.offset=Vector2(0,0)
	#a2.offset=Vector2(0,0)
	#a3.offset=Vector2(0,0)
	
	#I DON'T UNDERSTAND WHY THIS WILL OVERRIDE THE BASE
	#SCENES IF YOU CHANGE IT IN THE EDITOR WHO THE FUCK
	#DESIGNED THIS
	#sprite.get_material().set_shader_param("colorToSwap1", Color("#c2c2c2"))
	#sprite.get_material().set_shader_param("colorToSwap2", Color("#f0f0f0"))

	#chargeStart.connect("finished",chargeLoop,"play")


#TODO: dude lmao
var chargeShotTime:float=0.0
var startedCharging:bool=false
func get_input(delta):
	if canThrowGrenade==false and Globals.playerData.specialAbilities[Globals.SpecialAbilities.Grenade]:
		canThrowGrenade=true
	#print("lmao 2")
	var right = Input.is_action_pressed('ui_right')
	var left = Input.is_action_pressed('ui_left')
	var up = Input.is_action_pressed('ui_up')
	var down = Input.is_action_pressed('ui_down')
	var jump = Input.is_action_just_pressed('ui_select')
	var shoot = Input.is_action_just_pressed("ui_cancel")
	var chargeShot = Input.is_action_pressed("ui_cancel") and currentWeapon==Globals.Weapons.Buster
	if rapidFire and shoot_time > .1:
		shoot = Input.is_action_pressed("ui_cancel")
		chargeShot=false #no charge shots when rapidFire!
	
	if Globals.flipButtons:
		jump = Input.is_action_just_pressed('ui_cancel')
		shoot = Input.is_action_just_pressed("ui_select") or rapidFire and (shoot_time > .1 and Input.is_action_pressed("ui_select"))

	var grenade_input = (shoot and up) or (
		Input.is_action_just_pressed("gameplay_btn3") and
		state!=State.DASH
	)
		#Can't throw grenades if using other weapons because it will
	#conflict with the alchemist rockets.
	#...Even though square will also shoot it.
	grenade_input = grenade_input and currentWeapon==Globals.Weapons.Buster

	if dash_time>0:
		jump=false
	if Input.is_action_just_pressed("R1") or (
		Input.is_action_pressed("ui_down") and jump
	):
		if is_on_floor() and dash_time<=0:
			#print("Dash")
			state = State.DASH
			dash_time=.5
			sprite.set_animation("Dash")
			for i in range(oldPositions.size()):
				oldPositions[i] = position
			return
	
	#Cancel it here instead of accounting for it anywhere else
	#you can move in the split second between Zero falling though the ladder top and grabbing onto
	#the ladder, so cancel it here so they actually snap on correctly
	if (left and right) or movementLocked or grabbingLadder:
		left = false;
		right = false;
	
	
	if chargeShot:
		chargeShotTime+=delta
		if startedCharging:
			if chargeStart.playing and chargeStart.get_playback_position() >= 1.00:
				#TODO: stop() runs before play() so there's a gap in the audio
				chargeStart.stop()
				chargeLoop.play()
				var tmp_f:int = chargingAnim.frame
				chargingAnim.play("full")
				chargingAnim.frame=tmp_f
			#pass
		elif chargeShotTime>.5:
			chargingAnim.visible=true
			chargingAnim.play("default")
			chargeStart.play()
			startedCharging=true
	elif chargeShotTime>0.0 and chargeShot==false:
		if chargeShotTime > 1.1:
			chargeShotS.play()
			print("Charge shot fired!")
			
			var bi = playerChargeShot.instance()
			var ss
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
			
			bi.position = pos
			#get_parent().add_child(bi)
			bulletHolder.add_child(bi)
			#No need to use bulletHolder for charge shots.
			#stageRoot.add_child(bi)
			#KinematicBody2D only
			#bi.linear_velocity = Vector2(800.0 * ss, 0)
			#RigidBody2D only
			bi.init(int(ss))
			
			#add_collision_exception_with(bi) # Make bullet and this not collide
			
	#		if Globals.playerData.gameDifficulty > Globals.Difficulty.EASY:
	#			bulletManager.push_bullet(bi)
	#		else:
	#			for child in bulletHolder.get_children():
	#				if is_instance_valid(child) and child.get_class()=="KinematicBody2D":
	#					#print(child.get_class())
	#					#child.add_collision_exception_with(bi)
	#					bi.add_collision_exception_with(child)
	#			pass
			if sprite.animation=="IdleShoot":
				sprite.frame = 0
			shoot_sprite_time = 0.3
			shoot_time = -.2
			#$ShootSound.play()
		elif chargeShotTime > .5: #Not fully charged
			shoot=true
		chargingAnim.visible=false
		chargeShotTime=0
		startedCharging=false
		chargeStart.stop()
		chargeLoop.stop()
	
	
	if grenade_input and canThrowGrenade:
		if (Globals.playerData.gameDifficulty <= Globals.Difficulty.EASY or bulletManager.get_num_bullets() < 3):
			
			#print("Throw!")
			var inst = grenade.instance()
			var ss:float
			if sprite.flip_h:
				ss = -1.0
			else:
				ss = 1.0
			var pos = position + Vector2(20*ss, 10)
			if state == State.ON_LADDER:
				pos = position + Vector2(20*ss, -20)
			inst.position=pos
			bulletHolder.add_child(inst)
			inst.init(ss)
			shoot_time = 0
			if Globals.playerData.gameDifficulty > Globals.Difficulty.EASY:
				bulletManager.push_bullet(inst)
	#All this shit is copypasted from the example platformer so I have no idea how it works
	# A good idea when implementing characters of all kinds,
	# compensates for physics imprecision, as well as human reaction delay.
	elif shoot:
		if shoot_time>0:
			shoot_time = 0
			if (Globals.playerData.gameDifficulty <= Globals.Difficulty.EASY or bulletManager.get_num_bullets() < 3) and weaponMeters[currentWeapon]>=Globals.weaponEnergyCost[currentWeapon]:
				
				var bi
				var ss
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
				if currentWeapon==Globals.Weapons.Buster:
					bi = bullet.instance()
					
					
					bi.position = pos
					#get_parent().add_child(bi)
					bulletHolder.add_child(bi)
					#KinematicBody2D only
					#bi.linear_velocity = Vector2(800.0 * ss, 0)
					#RigidBody2D only
					bi.init(Vector2(13*ss,0))
				elif currentWeapon==Globals.Weapons.Architect:
					bi = archiRocket.instance()
					bi.position = pos
					#get_parent().add_child(bi)
					bulletHolder.add_child(bi)
					bi.init(int(ss))
				
				add_collision_exception_with(bi) # Make bullet and this not collide
				
				if Globals.playerData.gameDifficulty > Globals.Difficulty.EASY:
					bulletManager.push_bullet(bi)
				else:
					for child in bulletHolder.get_children():
						if is_instance_valid(child) and child.get_class()=="KinematicBody2D":
							#print(child.get_class())
							#child.add_collision_exception_with(bi)
							bi.add_collision_exception_with(child)
					pass
				if sprite.animation=="IdleShoot":
					sprite.frame = 0
				shoot_sprite_time = 0.3
				$ShootSound.play()
	else:
		shoot_time += delta
		
	if jump and is_on_floor():
		#print("Jumped")
		#$FootstepSound.play()
		#state = State.JUMPING
		#if shotTimer.is_stopped():
		#	sprite.set_animation("JumpStart")
		#else:
		#	sprite.set_animation("JumpShoot")
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
				dash_time=0
				sprite.set_animation("LadderBegin")
				#get position of cell then multiply to get actual character position then offset by half of cell width multiplied by scale
				position.x = pos2cell(position).x*16*4+8*4;
				velocity=Vector2(0,-1)
				#position = Vector2(round(floor(position.x)/16/4)*16*4+8*4, position.y)
				state = State.ON_LADDER
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
		if state == State.JUMPING:
			#Cancel upward momentium if jump button is let go
			#I'm pretty sure this can be simplified into one if statement
			if !Globals.flipButtons:
				if velocity.y < 0 and !Input.is_action_pressed("ui_select"):
					velocity.y = 0
					state=State.FALLING
			else:
				if velocity.y < 0 and !Input.is_action_pressed("ui_cancel"):
					velocity.y = 0
					state=State.FALLING

#Return true if processing should stop
func dash_handler()->bool:
	if !is_on_floor():
		dash_time=0.0
	a1.visible = dash_time>0
	a2.visible = dash_time>0
	a3.visible = dash_time>0
	if dash_time>0:
		var ss = -1.0 if sprite.flip_h else 1.0
		velocity=Vector2(ss*run_speed*dash_multiplier,5)
		
		var t = sprite.frames.get_frame(sprite.get_animation(), sprite.frame)
		var f = sprite.flip_h
		#var p = 1 if f else -1
		#var i = 0
		oldPositions[5] = position
		for i in range(5):
			oldPositions[i] = oldPositions[i+1]
			#i+=1
		a1.texture = t
		a2.texture = t
		a3.texture = t
		
		a1.flip_h = f
		a2.flip_h = f
		a3.flip_h = f
		
		a1.position=oldPositions[4]-position
		a2.position=oldPositions[3]-position
		a3.position=oldPositions[2]-position
		#a3.offset = oldPositions[4] - position
		#a2.offset = oldPositions[2] - position
		#a1.offset = oldPositions[0] - position
		#$Sprite/Label.text = "offset: "+String(oldPositions[4]-position)
		return true
	else:
		return false

#Currently we decided m16 can't obtain weapons,
#so the item get screen is disabled for her.
func finishStage_2():
	$CanvasLayer/Fadeout.fadeOut()
	yield($CanvasLayer/Fadeout/Fadeout_Tween,"tween_completed")
	var nextScene = "ScreenSelectStage"
	CheckpointPlayerStats.lastPlayedStage = stageRoot.weapon_to_unlock
	#if Globals.playerData.availableWeapons[stageRoot.weapon_to_unlock]: #If this stage is already completed
	#	nextScene="ScreenSelectStage"
	
	print("Marking stage/item "+String(stageRoot.weapon_to_unlock)+" as cleared.")
	Globals.playerData.availableWeapons[stageRoot.weapon_to_unlock]=true
	Globals.save_player_game()
	
	var weapons = Globals.playerData.availableWeapons
	if weapons[1] and weapons[2] and weapons[4]:
		Globals.change_screen(get_tree(),"CutsceneDemoEnd")
	else:
		Globals.change_screen(get_tree(),nextScene)
