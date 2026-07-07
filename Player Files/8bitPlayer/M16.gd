extends "res://Player Files/8bitPlayer/8bitPlayer.gd"


onready var a1 = get_node("Sprite/AfterImage1")
onready var a2 = get_node("Sprite/AfterImage2")
onready var a3 = get_node("Sprite/AfterImage3")
var oldPositions:PoolVector2Array = PoolVector2Array()
var oldFrameTextures:Array = []
var oldFrameFlips:Array = []


var playerChargeShot = preload("res://Player Files/Weapons/PlayerChargeShot.tscn")
onready var chargingAnim:AnimatedSprite = $Charging
onready var chargeStart:AudioStreamPlayer2D = $ChargeStartSound
onready var chargeLoop:AudioStreamPlayer2D = $ChargeLoopSound
onready var chargeShotS:AudioStreamPlayer2D = $ChargeShotFireSound

var dustCloudAnim = preload("res://Animations/dustCloud.tscn")

##TODO: dude lmao
#const CHARGE_MIN_TIME = .5
#const CHARGE_FULL_TIME = 1.5
#var chargeShotTime:float=0.0
##var startedCharging:bool=false

const DASH_MINIMUM_TIME = .2
const DASH_MAXIMUM_TIME = 1.0
const WALL_JUMP_INPUT_LOCK_TIME = 0.08
const WALL_JUMP_X_CURVE_ACCEL = 1400.0
# In Mega Man Zero, Zero will dash as long as he's in the air.
# On the ground he dashes for a minimum of .2 seconds
# or a maximum of 1 second. 
var dashing:bool = false
var wall_jump_input_lock_timer:float = 0.0
var wall_jump_x_recovery_active:bool = false
#This is used to spawn the dust clouds every 5 frames
var wall_slide_frame_timer:float = 0.0

func _ready():
	oldPositions.resize(6)
	oldFrameTextures.resize(6)
	oldFrameFlips.resize(6)

	var current_texture = sprite.frames.get_frame(sprite.get_animation(), sprite.frame)
	for i in range(oldPositions.size()):
		oldPositions[i] = position
		oldFrameTextures[i] = current_texture
		oldFrameFlips[i] = sprite.flip_h

	#If this is left on the afterimages will be offset incorrectly.
	#So always turn it off.
	for after_image in [a1, a2, a3]:
		after_image.centered = sprite.centered
		after_image.offset = sprite.offset
		after_image.region_enabled = false
	a1.visible=false
	a2.visible=false
	a3.visible=false

	#I DON'T UNDERSTAND WHY THIS WILL OVERRIDE THE BASE
	#SCENES IF YOU CHANGE IT IN THE EDITOR WHO THE FUCK
	#DESIGNED THIS
	switchWeapon(false)
	#chargeStart.connect("finished",chargeLoop,"play")

func switchWeapon(showIcon:bool=true):
	if showIcon:
		emit_signal("switched_weapon",currentWeapon)
	if currentWeapon==0: #lmao
		sprite.get_material().set_shader_param("clr1", Color(.749,.749,.749))
		sprite.get_material().set_shader_param("clr2", Color(.957,.957,.957))
	else:
		sprite.get_material().set_shader_param("clr1", Globals.weaponColorSwaps[currentWeapon][0])
		sprite.get_material().set_shader_param("clr2", Globals.weaponColorSwaps[currentWeapon][1])
	#print(weaponMeters[currentWeapon]/144.0)
	HPBar.show_weapon(currentWeapon!=0 or hasGrenadeAbility,weaponMeters[currentWeapon]/144.0)
	if currentWeapon!=0 or hasGrenadeAbility:
		HPBar.get_material().set_shader_param("clr1", Globals.weaponColorSwaps[currentWeapon][0])
		HPBar.get_material().set_shader_param("clr2", Globals.weaponColorSwaps[currentWeapon][1])
		

func get_input(delta):
	if hasGrenadeAbility==false and Globals.playerData.specialAbilities[Globals.SpecialAbilities.Grenade]:
		hasGrenadeAbility=true

	var left = Input.is_action_pressed(INPUT.LEFT[controller_index])
	var right = Input.is_action_pressed(INPUT.RIGHT[controller_index])
	var up = Input.is_action_pressed(INPUT.UP[controller_index])
	var down = Input.is_action_pressed(INPUT.DOWN[controller_index])
	var jump = Input.is_action_just_pressed(INPUT.JUMP[controller_index])
	var shoot = Input.is_action_just_pressed(INPUT.SHOOT[controller_index])
	var dash = (down and jump) or Input.is_action_just_pressed(INPUT.R1[controller_index])
	var dash_hold = dash or Input.is_action_pressed(INPUT.R1[controller_index])

	if wall_jump_input_lock_timer > 0:
		wall_jump_input_lock_timer = max(0.0, wall_jump_input_lock_timer - delta)

	if is_on_floor() or state == State.ON_LADDER:
		wall_jump_x_recovery_active = false
		wall_jump_input_lock_timer = 0.0

	#var chargeShot = Input.is_action_pressed(INPUT.SHOOT[controller_index]) and currentWeapon==Globals.Weapons.Buster

	if rapidFire and shoot_time > .1:
		shoot = Input.is_action_pressed(INPUT.SHOOT[controller_index])
		#chargeShot=false #no charge shots when rapidFire!

	#TODO: This is so stupid. Why isn't this handled in the input class?
	if Globals.flipButtons:
		jump = Input.is_action_just_pressed(INPUT.SHOOT[controller_index])
		shoot = Input.is_action_just_pressed(INPUT.JUMP[controller_index]) or rapidFire and (shoot_time > .1 and Input.is_action_pressed(INPUT.SHOOT[controller_index]))

	var grenade_input = (shoot and up) or (
		Input.is_action_just_pressed(INPUT.GRENADE[controller_index]) and
		state!=State.DASH
	)
	#Can't throw grenades if using other weapons because it will
	#conflict with the alchemist rockets.
	#...Even though square will also shoot it.
	grenade_input = grenade_input and currentWeapon==Globals.Weapons.Buster

	if is_on_floor() and dash and dash_time <= 0:
		jump = false
		dashing = true
		dash_time= DASH_MAXIMUM_TIME
		sprite.set_animation("Dash")
		for i in range(oldPositions.size()):
			oldPositions[i] = position
	elif is_on_floor() and dash_hold == false and dash_time < DASH_MAXIMUM_TIME-DASH_MINIMUM_TIME:
		dash_time = 0

	#Cancel it here instead of accounting for it anywhere else
	#you can move in the split second between Zero falling though the ladder top and grabbing onto
	#the ladder, so cancel it here so they actually snap on correctly
	if (left and right) or movementLocked or grabbingLadder:
		left = false;
		right = false;


	#chargeShotTime+=delta
	if grenadeThrower.getCooldownPercent() >= 1.0 and shoot:
		chargeShotS.play()
		#print("Charge shot fired!")

		var bi = playerChargeShot.instance()
		var ss
		if sprite.flip_h:
			ss = -1.0
		else:
			ss = 1.0
		if state == State.WALL_SLIDE:
			ss *= -1.0
		#Note: $ is shorthand for get_node()
		#Right here it's doing get_node("bullet_shoot")
		#ternary: var p = 1 if f else -1
		var pos = position + Vector2(73*ss, 10)
		if state == State.ON_LADDER:
			pos = position + Vector2(95*ss, -20)

		bi.position = pos
		bulletHolder.add_child(bi)
		bi.init(int(ss))

		if sprite.animation=="IdleShoot":
			sprite.frame = 0
		shoot_sprite_time = 0.3
		shoot_time = -.2
		grenadeThrower.currentCooldownTimer = 0.0
		#chargeShotTime = -.2
#	elif chargeShotTime > CHARGE_FULL_TIME:
#		#shoot=true
#		var tmp_f:int = chargingAnim.frame
#		chargingAnim.play("full")
#		chargingAnim.frame=tmp_f
#
#
#	elif chargeShotTime > CHARGE_MIN_TIME:
#		chargingAnim.visible=true
#		chargingAnim.play("default")
#	else:
#		chargingAnim.visible = false
	
#	if chargeShot:
#
#		if startedCharging:
#			if chargeStart.playing and chargeStart.get_playback_position() >= 1.00:
#				#TODO: stop() runs before play() so there's a gap in the audio
#				chargeStart.stop()
#				chargeLoop.play()
#				var tmp_f:int = chargingAnim.frame
#				chargingAnim.play("full")
#				chargingAnim.frame=tmp_f
#			#pass
#		elif chargeShotTime>.5:
#			chargingAnim.visible=true
#			chargingAnim.play("default")
#			chargeStart.play()
#			startedCharging=true
#	elif chargeShotTime>0.0 and chargeShot==false:
#		if chargeShotTime > 1.1:
#			chargeShotS.play()
#			print("Charge shot fired!")
#
#			var bi = playerChargeShot.instance()
#			var ss
#			if sprite.flip_h:
#				ss = -1.0
#			else:
#				ss = 1.0
#			#Note: $ is shorthand for get_node()
#			#Right here it's doing get_node("bullet_shoot")
#			#ternary: var p = 1 if f else -1
#			var pos = position + Vector2(73*ss, 10)
#			if state == State.ON_LADDER:
#				pos = position + Vector2(95*ss, -20)
#
#			bi.position = pos
#			bulletHolder.add_child(bi)
#			bi.init(int(ss))
#
#			if sprite.animation=="IdleShoot":
#				sprite.frame = 0
#			shoot_sprite_time = 0.3
#			shoot_time = -.2
#			#$ShootSound.play()
#		elif chargeShotTime > .5: #Not fully charged
#			shoot=true
#		chargingAnim.visible=false
#		chargeShotTime=0
#		startedCharging=false
#		chargeStart.stop()
#		chargeLoop.stop()


	if grenade_input and hasGrenadeAbility:
		if (Globals.playerData.gameDifficulty <= Globals.Difficulty.EASY or bulletManager.get_num_bullets() < 3):
			throwGrenade()
	#All this shit is copypasted from the example platformer so I have no idea how it works
	# A good idea when implementing characters of all kinds,
	# compensates for physics imprecision, as well as human reaction delay.
	elif shoot:
		if shoot_time>0:
			shoot_time = 0
			#chargeShotTime = 0.0
			if (Globals.playerData.gameDifficulty <= Globals.Difficulty.EASY or bulletManager.get_num_bullets() < 3) and weaponMeters[currentWeapon]>=Globals.weaponEnergyCost[currentWeapon]:

				var bi
				var ss
				if sprite.flip_h:
					ss = -1.0
				else:
					ss = 1.0
				if state == State.WALL_SLIDE:
					ss *= -1.0
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
		velocity.y = jump_speed
		state = State.JUMPING
	elif jump and state == State.WALL_SLIDE:
		velocity.y = jump_speed
		state = State.JUMPING
		
		var inst = dustCloudAnim.instance()
		inst.scale = Vector2(4,4)
		stageRoot.add_child(inst)
		var vec = get_collision_vector_from_wall()
		inst.global_position = global_position + Vector2(32*vec.x, 32)
		
		velocity.x = vec.x * -100
		wall_jump_x_recovery_active = true
		wall_jump_input_lock_timer = WALL_JUMP_INPUT_LOCK_TIME
		#Dashing and jumping is kinda broken so I'm just going to disable it
		dash_time = 0
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
		if wall_jump_x_recovery_active and !is_on_floor() and state != State.ON_LADDER:
			var target_x = 0.0
			if right and position.x < $Camera2D.destPositions[2]-40:
				target_x = run_speed
				sprite.flip_h = false
			elif left and position.x > $Camera2D.destPositions[0]+40:
				target_x = -run_speed
				sprite.flip_h = true

			if wall_jump_input_lock_timer <= 0.0:
				velocity.x = move_toward(velocity.x, target_x, WALL_JUMP_X_CURVE_ACCEL * delta)
		else:
			if right and position.x < $Camera2D.destPositions[2]-40:
				velocity.x = run_speed
				sprite.flip_h = false
			elif left and position.x > $Camera2D.destPositions[0]+40:
				velocity.x = -run_speed
				sprite.flip_h = true
			elif !movementLocked: #If movement locked, assume velocity should be preserved
				velocity.x=0
			
		
		if position.x < $Camera2D.destPositions[0]+40 or position.x > $Camera2D.destPositions[2]-40:
			dash_time = 0.0
			
		#While dashing and on the floor the velocity MUST be preserved
		if dash_time > 0:
			if is_on_floor():
				#left
				if sprite.flip_h:
					velocity.x = dash_multiplier * run_speed * -1
				else: # right
					velocity.x = dash_multiplier * run_speed
			else:
				velocity.x *= dash_multiplier
			
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
				if velocity.y < 0 and !Input.is_action_pressed("ui_accept"):
					velocity.y = 0
					state=State.FALLING
			else:
				if velocity.y < 0 and !Input.is_action_pressed("ui_cancel"):
					velocity.y = 0
					state=State.FALLING


#delta: time between frames (duh)
#tile: current tile the player is on (passed in from physics_process)
func process_normal_movement(delta, tile):
	
	if state==State.FLYING_BACKWARDS:
		velocity.y=0
		if is_on_wall():
			invincibleTime=0
			$Camera2D.shakeCamera(10.0)
			clearLockedMovement()
			velocity.y = 200
			if sprite.flip_h:
				velocity.x = -300
			else:
				velocity.x = 300
			lockMovement(.25,velocity,false)
			state=State.FALLING
	# M16 doesn't have these...
#	elif state==State.DASH_ATTACK:
#		$ChargeDash.monitoring=(dash_time>=0)
#		if $ChargeDash.touchedEnemy or is_on_wall():
#			$ChargeDash.monitoring=false
#			dash_time=0.0
#			var ss = -1.0 if sprite.flip_h else 1.0
#			lockMovement(.1,Vector2(ss*-600,-400),true)
#			#velocity.y=-121771837874
#			$ChargeDash.touchedEnemy=false
#			state = State.FALLING
#			sprite.set_animation("Falling")
#		if dash_time>0:
#			var ss = -1.0 if sprite.flip_h else 1.0
#			$ChargeDash.position.x=60*ss
#			velocity=Vector2(ss*run_speed*dash_multiplier,0)
#			return
#		else:
#			velocity.y=1
#	elif state==State.DASH:
#		if invincible: #Still need to process invincibility frames
#			processInvincible(delta)
#		if dash_handler():
#			if (position.x < $Camera2D.destPositions[2]-40 and position.x > $Camera2D.destPositions[0]+40):
#				return
#			#Cancel dash if player is outside camera bounds.
#			else: 
#				dash_time=0

	

	

	if is_on_floor() and velocity.y >= 0:
		if state == State.FALLING:
			footstep.play()
			sprite.playing=true #If sprite was paused at any point
		state = State.NORMAL
			
		if velocity.x > 125.0 or velocity.x < -125.0:
			if shoot_sprite_time <= 0:
				if sprite.animation == "WalkLoopShoot":
					var prevFrame = sprite.get_frame()
					sprite.set_animation("WalkLoop")
					sprite.set_frame(prevFrame)
				elif dash_time > 0:
					sprite.set_animation("Dash")
				else:
					sprite.set_animation("WalkLoop")
			else:
				if sprite.get_animation() == "WalkLoop":
					var prevFrame = sprite.get_frame()
					sprite.set_animation("WalkLoopShoot")
					sprite.set_frame(prevFrame)
				elif sprite.get_animation() != "WalkLoopShoot":
					sprite.set_animation("WalkLoopShoot")
			
			#if sprite.frame == 3 or sprite.frame == 8:
			#	if !$FootstepSound.playing:
			#		$FootstepSound.play()
		else:
			if !overrideSprite:
				if shoot_sprite_time <= 0:
					sprite.set_animation("Idle")
				elif sprite.animation != "IdleShoot":
					sprite.set_animation("IdleShoot");
	elif state == State.GRABBING_LADDER:
		if tile == LADDER_TILE_ID or tile == LADDER_TOP_TILE_ID:
			state = State.ON_LADDER
	elif state == State.ON_LADDER:
		#jumping = false
		#ez modo way of playing the ladder animation
		#Wait for begin animation to be done
		if sprite.get_animation() == "LadderBegin":
			if sprite.frame == sprite.frames.get_frame_count("LadderBegin")-1:
				sprite.set_animation("LadderLoop")
			
		elif shoot_sprite_time > 0:
				#TODO: Change to shot animation while keeping the frame
				#var prevFrame = sprite.frame
				sprite.set_animation("LadderShoot")
				#elif sprite.animation == "IdleShoot":
				#	sprite.frame=0
		else:
			sprite.set_animation("LadderLoop")
		
		if sprite.get_animation() == "LadderLoop":
			# TODO: This isn't correct. Her animation should
			# be tied to her y position.
			if abs(velocity.y) > .1:
				sprite.play()
			else:
				sprite.stop()
			
		if tile != LADDER_TILE_ID and tile != LADDER_TOP_TILE_ID:
			state = State.FALLING
			if tile != LADDER_TOP_TILE_ID and velocity.y < 0:
				#TODO: So..... This doesn't work if you move the collision box 
				lockMovement(.2,Vector2(velocity.x,-350),true)
				sprite.set_animation("LadderFinish")
				sprite.play()
			else:
				#state = State.FALLING
				sprite.set_animation("Falling")
	elif is_on_wall() and velocity.y > 0 and get_collision_vector_from_wall() != Vector2.ZERO:
		sprite.set_animation("WallSlide")
		velocity.y = 100
		state = State.WALL_SLIDE
		wall_slide_frame_timer += delta
		if wall_slide_frame_timer > .2:
			wall_slide_frame_timer -= .2
			var inst = dustCloudAnim.instance()
			inst.scale = Vector2(4,4)
			stageRoot.add_child(inst)
			var vec = get_collision_vector_from_wall()
			inst.global_position = global_position + Vector2(32*vec.x,-24)
			
	elif velocity.y > 0.5 and not movementLocked:
		state = State.FALLING
		
	if !is_on_floor() and not movementLocked and state != State.ON_LADDER and state != State.WALL_SLIDE:
	
		if shoot_sprite_time <= 0:
			if velocity.y<=0:
				sprite.set_animation("JumpStart")
			elif true: #velocity.y>.5
				sprite.set_animation("Falling")
		else:
			sprite.set_animation("FallingShoot")
	dash_handler()

# Returns the vector for the direction you're pressing on if you're sliding on a wall.
func get_collision_vector_from_wall() -> Vector2:
	var pressing_left = Input.is_action_pressed(INPUT.LEFT[controller_index])
	var pressing_right = Input.is_action_pressed(INPUT.RIGHT[controller_index])

	if pressing_left == pressing_right:
		return Vector2.ZERO

	for i in range(get_slide_count()):
		var collision = get_slide_collision(i)
		if collision == null:
			continue

		if collision.normal.x > 0.7 and pressing_left:
			return Vector2.LEFT
		elif collision.normal.x < -0.7 and pressing_right:
			return Vector2.RIGHT
	return Vector2.ZERO

#Return false if processing should stop
func dash_handler() -> bool:
	#"or true" for debugging purposes
	var should_process = dash_time > 0 # or true

	a1.visible = should_process
	a2.visible = should_process
	a3.visible = should_process
	if should_process:

		var t = sprite.frames.get_frame(sprite.get_animation(), sprite.frame)
		var f = sprite.flip_h

		for i in range(oldPositions.size()-1):
			oldPositions[i] = oldPositions[i+1]
			oldFrameTextures[i] = oldFrameTextures[i+1]
			oldFrameFlips[i] = oldFrameFlips[i+1]

		oldPositions[oldPositions.size()-1] = position
		oldFrameTextures[oldFrameTextures.size()-1] = t
		oldFrameFlips[oldFrameFlips.size()-1] = f

		a1.texture = oldFrameTextures[4]
		a2.texture = oldFrameTextures[3]
		a3.texture = oldFrameTextures[2]

		a1.flip_h = oldFrameFlips[4]
		a2.flip_h = oldFrameFlips[3]
		a3.flip_h = oldFrameFlips[2]

		a1.position=oldPositions[4]-position
		a2.position=oldPositions[3]-position
		a3.position=oldPositions[2]-position
	
	return should_process;

#Currently we decided m16 can't obtain weapons,
#so the item get screen is disabled for her.
func finishStage_2():
	var nextScene = "ScreenSelectStage"
	CheckpointPlayerStats.lastPlayedStage = stageRoot.weapon_to_unlock
	
	var tween:SceneTreeTween
	if stageRoot.wily_stage_num >= 4:
		Globals.previous_screen = "StageSangvis"
		nextScene="ScreenCredits"
		tween = $CanvasLayer/Fadeout.fadeOut()
	elif stageRoot.wily_stage_num>0:
		Globals.previous_screen = "StageSangvis"
		nextScene="ScreenSangvisIntro"
		#CheckpointPlayerStats.lastPlayedStage = Globals.Weapons.LENGTH_WEAPONS+stageRoot.wily_stage_num
		Globals.playerData.wilyStageNum = stageRoot.wily_stage_num+1
		tween = $CanvasLayer/Fadeout.fadeOut()
		
	elif false: #If this stage is already completed
		nextScene="ScreenSelectStage"
		tween = $CanvasLayer/TransitionOut.OnCommand()
	else:
		tween = $CanvasLayer/Fadeout.fadeOut()
	
		Globals.playerData.availableWeapons[stageRoot.weapon_to_unlock]=true
		print("Marking stage/item "+String(stageRoot.weapon_to_unlock)+" as cleared.")
	
	Globals.save_player_game()
	
	tween.tween_callback(Globals,"change_screen",[get_tree(),nextScene])
	#Globals.change_screen(get_tree(),nextScene)
