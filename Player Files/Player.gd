extends KinematicBody2D

const SPEED = 250;
const MAX_HP = 32
var HP

enum characters {DEFAULT, GRACE}
var characterSpritePaths = [
	"res://Character Sprites/ZeroSpriteAnim.tres",
	"res://Character Sprites/Grace/HXSpriteAnim.tres"
	]
var characterAttackSounds = [
	"res://Sounds/Buster - Shot.WAV",
	"res://Sounds/Saber - Slash.WAV"
	]
export (characters) var currentCharacter = 0

#var acc = Vector2()
export (int) var run_speed
export (int) var jump_speed
export (int) var dash_multiplier
export (int) var gravity = 0
#What the fuck does e20 mean
var shoot_time = 1e20
var velocity = Vector2()

#These should really be turned into enums or something...
var jumping = false
var dashing = false

var inWater = false

#if player pressed down and they need to grab a ladder from above
var grabbingLadder = false
#If currently attached to a ladder
var on_ladder = false

#Debug
var freeRoam = false
var noClip = false
var rapidFire = false

#player sprite
onready var sprite = self.get_node("Sprite");
onready var afterImage1 = self.get_node("Sprite/AfterImage1");
onready var afterImage2 = self.get_node("Sprite/AfterImage2");
onready var afterImage3 = self.get_node("Sprite/AfterImage3");
var oldPositions
#debug
var debugDisplay = true
onready var stateInfo = self.get_node("CanvasLayer/StateInfo");
onready var stateVelocity = self.get_node("CanvasLayer/StateVelocity");
onready var stateTile = self.get_node("CanvasLayer/StateTile");
onready var statePos = self.get_node("CanvasLayer/StatePosition")
onready var cameraInfo = $CanvasLayer/CameraInfo

#Camera
var stageRoot
var currentCam
#var oScreenPos
#onready var oScreenPosOld = Vector2(0,0)
#internals
onready var shotTimer = get_node("ShotTimer");
onready var collisionShape = $CollisionShape2D
onready var rayCast = $CeilingCheck
onready var groundCheck = $GroundCheck
onready var eventCheck = $EventCheck
onready var dashSound = $DashSound
#UI
onready var HPBar = $CanvasLayer/bar

#preload is for res:// objects apparently
var bullet = preload("res://Player Files/bullet.tscn")
var sword = preload("res://Player Files/SwordHitbox.tscn")

var tiles;
var LADDER_TILE_ID
var LADDER_TOP_TILE_ID
var SPIKES_TILE_ID


func _ready():
	#tiles = self.get_node("TileMap");
	tiles = self.get_node("/root/Node2D/TileMap");
	LADDER_TILE_ID = get_node("/root/Node2D/").LADDER_TILE_ID
	LADDER_TOP_TILE_ID = get_node("/root/Node2D/").LADDER_TOP_TILE_ID
	if "SPIKES_TILE_ID" in get_node("/root/Node2D/"):
		SPIKES_TILE_ID = get_node("/root/Node2D/").SPIKES_TILE_ID
	else:
		SPIKES_TILE_ID = -999
	stageRoot = get_node("/root/Node2D/")
	self.get_node("Sprite").play("Idle");
	get_node("CanvasLayer/FreeRoam").text = ""
	set_physics_process(true);
	HP = MAX_HP
	HPBar.updateHP(HP)
	oldPositions = PoolVector2Array()
	oldPositions.resize(6)
	
	stateInfo.visible = debugDisplay
	cameraInfo.visible = debugDisplay
	stateVelocity.visible = debugDisplay
	stateTile.visible = debugDisplay
	statePos.visible = debugDisplay
	
	var cc = $Camera2D
	var bounds = $CanvasLayer/CameraBounds
	var WIDTH = 1280/2
	var HEIGHT = 720/2
	bounds.polygon = PoolVector2Array([
		Vector2(WIDTH-WIDTH*cc.drag_margin_left,HEIGHT-HEIGHT*cc.drag_margin_top), #top left
		Vector2(WIDTH+WIDTH*cc.drag_margin_right,HEIGHT-HEIGHT*cc.drag_margin_top), #top right
		Vector2(WIDTH+WIDTH*cc.drag_margin_right,HEIGHT+HEIGHT*cc.drag_margin_bottom), #bottom right
		Vector2(WIDTH-WIDTH*cc.drag_margin_left,HEIGHT+HEIGHT*cc.drag_margin_bottom) #bottom left
	])
	#print(bounds.polygon[0])

#Setting this every frame is probably a wasteful operation...
#So the genius way to do it is only update when one of the variables is changed
func setDebugInfoText():
	var t = get_node("CanvasLayer/FreeRoam")
	var st = ""
	if noClip:
		st+="NoClip"
	if freeRoam:
		st = "Free Roam, "+st
	if rapidFire:
		st = "Rapidfire, "+st
	t.text = st	
func setNewCharacter():
	#print(currentCharacter)
	sprite.frames = load(characterSpritePaths[currentCharacter]);
	var s = characterAttackSounds[currentCharacter]
	#print(s);
	$ShootSound.stream = load(s);
	$ChangeCharacterSound.play();


#Aka "This will need to be rewritten at some point, I swear"
func handleEvents():
	if eventCheck.is_colliding():
		print("Event touched!")
		#This is SO going to crash when I turn the collision on for this by accident
		var event_ID = eventCheck.get_collider().event_ID
		#print(event_ID)
		match event_ID:
			Globals.EVENT_TILES.NO_EVENT:
				print("This event has not been assigned an ID!")
			Globals.EVENT_TILES.IN_WATER:
				#print("In water!")
				if !inWater:
					$SplashSound.play()
				inWater = true;
			Globals.EVENT_TILES.OUT_WATER:
				inWater = false;
			_:
				print("Unknown event ID: "+String(event_ID))

func get_input(delta):
	if (dashing and rayCast.is_colliding()):
		pass
	elif !movementLocked:
		velocity.x = 0
		
	if Input.is_action_just_pressed("DebugButton2"):
		if noClip:
			set_collision_mask_bit(0,true)
			set_collision_layer_bit(0,true)
			noClip = false
		else:
			set_collision_mask_bit(0,false)
			set_collision_layer_bit(0,false)
			noClip = true;
		setDebugInfoText()
	if Input.is_action_just_pressed("DebugButton4"):
		rapidFire = !rapidFire
		setDebugInfoText()
	
	if Input.is_action_just_pressed("DebugButton5"):
		HP = MAX_HP
		HPBar.updateHP(HP)
		
	if Input.is_action_just_pressed("DebugButton9"):
		debugDisplay = !debugDisplay
		stateInfo.visible = debugDisplay
		cameraInfo.visible = debugDisplay
		stateVelocity.visible = debugDisplay
		stateTile.visible = debugDisplay
		statePos.visible = debugDisplay
	
	if Input.is_action_just_pressed("DebugButton10"):
		die()
	
	if Input.is_action_just_pressed("ui_pause"):
		$PauseScreen.updateTimer(0,0)
		get_tree().paused = true
		$PauseScreen.OnCommand()
	
	if Input.is_action_just_pressed("R2"):
		if currentCharacter < characters.size()-1:
			currentCharacter+=1;
		else:
			currentCharacter = 0
		setNewCharacter()
	if Input.is_action_just_pressed("L2"):
		if currentCharacter >= 1:
			currentCharacter-=1;
		else:
			currentCharacter = characters.size()-1;
		setNewCharacter()
	if freeRoam:
		velocity.y = 0
		if Input.is_action_just_pressed('DebugButton1'):
			freeRoam = false
			setDebugInfoText()
		var m = 3 if Input.is_action_pressed('R1') else 1
		if Input.is_action_pressed('ui_right'):
			velocity.x += 500*m
		if Input.is_action_pressed('ui_left'):
			velocity.x -= 500*m
		if Input.is_action_pressed('ui_down'):
			velocity.y += 500*m
		if Input.is_action_pressed('ui_up'):
			velocity.y -= 500*m
		#velocity = velocity.normalized() * SPEED
	else:
		if Input.is_action_just_pressed("DebugButton1"):
			freeRoam = true;
			setDebugInfoText()
	
		var right = Input.is_action_pressed('ui_right')
		var left = Input.is_action_pressed('ui_left')
		var up = Input.is_action_pressed('ui_up')
		var down = Input.is_action_pressed('ui_down')
		var jump = Input.is_action_just_pressed('ui_select')
		var shoot = Input.is_action_just_pressed("ui_cancel")
		if rapidFire and shoot_time > .1:
			shoot = Input.is_action_pressed("ui_cancel")
		
		dashing = (Input.is_action_pressed('R1') and is_on_floor() and (left or right)) \
		or (dashing and !is_on_floor()) \
		or (dashing and rayCast.is_colliding())
		if Input.is_action_just_pressed('R1') and is_on_floor():
			dashSound.play()
			var i = 0;
			while i < 4:
				oldPositions[i] = position
				i+=1
			
		# Why check for all three?
		# If we only check jump and raycast, then
		# one way platforms will collide with raycast,
		# which means you can't jump off the top of a ladder.
		if jump and dashing and is_on_floor() and rayCast.is_colliding():
			jump = false
		
		#Cancel it here instead of accounting for it anywhere else
		#you can move in the split second between Zero falling though the ladder top and grabbing onto
		#the ladder, so cancel it here so they actually snap on correctly
		if (left and right) or movementLocked or grabbingLadder:
			left = false;
			right = false;
			
		#All this shit is copypasted from the example platformer so I have no idea how it works
		# A good idea when implementing characters of all kinds,
		# compensates for physics imprecision, as well as human reaction delay.
		if shoot:
			shoot_time = 0
			if currentCharacter == characters.DEFAULT:
				var bi = bullet.instance()
				var ss
				if sprite.flip_h:
					ss = -1.0
				else:
					ss = 1.0
				#Note: $ is shorthand for get_node()
				#Right here it's doing get_node("bullet_shoot")
				#ternary: var p = 1 if f else -1
				var pos = position + Vector2(55*ss, -2) if !dashing else position + Vector2(70*ss, 15)
				
				bi.position = pos
				get_parent().add_child(bi)
				#KinematicBody2D only
				#bi.linear_velocity = Vector2(800.0 * ss, 0)
				#RigidBody2D only
				bi.init(Vector2(10*ss,0))
				
				add_collision_exception_with(bi) # Make bullet and this not collide
				#TODO: Change to shot animation while keeping the frame
				#var prevFrame = sprite.frame
			elif currentCharacter == characters.GRACE:
				var sw = sword.instance()
				var ss
				if sprite.flip_h:
					ss = -1.0
				else:
					ss = 1.0
				var pos = position + Vector2(55*ss, -2) if !dashing else position + Vector2(70*ss, 15)
				sw.position = pos
				#TODO: Do not spawn more than one, instead restart the timer
				get_parent().add_child(sw)
				#add_collision_exception_with(sw) # Make bullet and this not collide
				#TODO: Change to shot animation while keeping the frame
				#var prevFrame = sprite.frame
			if on_ladder:
				sprite.set_animation("LadderShoot")
			sprite.frame = 0
			shotTimer.start();
			$ShootSound.play()
		else:
			shoot_time += delta
			
		if jump and is_on_floor():
			$FootstepSound.play()
			jumping = true
			if shotTimer.is_stopped():
				sprite.set_animation("JumpStart")
			else:
				sprite.set_animation("JumpShoot")
			velocity.y = jump_speed
		elif jump and is_on_wall():
			$FootstepSound.play()
			jumping = true
			velocity.y = jump_speed
			if left:
				velocity.x = 200
			elif right:
				velocity.x = -200
			lockMovement(.2)
			sprite.set_animation("WallKick")
			$WallJumpSound.play()
		elif on_ladder:
			#Maybe waste of CPU?
			velocity.y = 0
			if up:
				velocity.y -= 100
			if down:
				velocity.y += 100
			if jump:
				on_ladder = false
				sprite.play()
			#This may have been a bad idea
			if left:
				sprite.flip_h = true
			if right:
				sprite.flip_h = false
			velocity = velocity.normalized() * SPEED
		#Your normal movement processing
		else:
			if right:
				if dashing:
					velocity.x = run_speed * dash_multiplier
				else:
					velocity.x = run_speed
				sprite.flip_h = false
			if left:
				if dashing:
					velocity.x = -run_speed * dash_multiplier
				else:
					velocity.x = -run_speed
				sprite.flip_h = true
			if up:
				var tile = tiles.get_cellv(pos2cell(position))
				if tile == LADDER_TILE_ID or tile == LADDER_TOP_TILE_ID:
					sprite.set_animation("LadderBegin")
					#get position of cell then multiply to get actual character position then offset by half of cell width multiplied by scale
					position.x = pos2cell(position).x*16*4+8*4;
					velocity.x = 0
					#position = Vector2(round(floor(position.x)/16/4)*16*4+8*4, position.y)
					on_ladder = true
					dashing = false
			if down:
				var tilePos = pos2cell(position)
				tilePos.y +=1
				#Get tile underneath you
				var tile = tiles.get_cellv(tilePos)
				if tile == LADDER_TOP_TILE_ID:
					sprite.set_animation("LadderBegin")
					position.x = pos2cell(position).x*16*4+8*4;
					velocity = Vector2(0, 300)
					set_collision_mask_bit(0,false)
					set_collision_layer_bit(0,false)
					#position = Vector2(round(floor(position.x)/16/4)*16*4+8*4, position.y)
					grabbingLadder = true
					dashing = false
				#Example for one way platforms (I don't know if 7 is correct)
				#elif tile == 7:
				#	position.x = pos2cell(position).x*16*4+8*4;
				#	#Don't set x velocity since we want them to keep moving at the same rate
				#	velocity.y = 300
				#	set_collision_mask_bit(0,false)
				#	set_collision_layer_bit(0,false)
			if jumping:
				#Cancel upward momentium if jump button is let go
				if velocity.y < 0 and !Input.is_action_pressed("ui_select"):
					velocity.y = 0
		
	if Input.is_action_just_pressed("DebugButton3"):
		position = Vector2(0,-100)
		$Camera2D.adjustCamera([-10000000,-10000000,10000000,10000000],0)
		
	if Input.is_action_just_pressed("DebugButton4"):
		#position = Vector2(0,-100)
		$Camera2D.adjustCamera([-10000000,-10000000,10000000,10000000],0)
		

#The world_to_map function does NOT take into account the scale of the tilemap, so we have to calculate
#the tile's actual mapping ourselves.
onready var tile_scale = get_node("/root/Node2D/TileMap").scale
func pos2cell(pos):
	#TODO: Offset is wrong, fix it for real
	return Vector2(round((pos.x-30)/16/tile_scale.x), round((pos.y-30)/16/tile_scale.y));

func _physics_process(delta):
	get_input(delta)
	handleEvents()
	
	var tile = tiles.get_cellv(pos2cell(position))
	#I got tired of dying to spikes in free roam
	if tile == SPIKES_TILE_ID and (not noClip and not freeRoam):
		die()
	
	#Only process when moving or falling. Because otherwise the character slides down slopes and that's bad.
	if (not freeRoam) and (not on_ladder):
		if inWater:
			velocity.y += gravity/2 * delta
		else:
			velocity.y += gravity * delta
			
	if movementLocked:
		pass
	elif is_on_floor() and velocity.y >= 0:
		jumping = false
		if on_ladder:
			on_ladder = false
			
		if velocity.x != 0:
			if dashing:
				if shotTimer.is_stopped():
					sprite.set_animation("DashLoop")
				else:
					sprite.set_animation("DashShoot")
			else:
				if shotTimer.is_stopped():
					sprite.set_animation("WalkLoop")
				else:
					sprite.set_animation("WalkLoopShoot")
				
				if sprite.frame == 3 or sprite.frame == 8:
					if !$FootstepSound.playing:
						$FootstepSound.play()
		else:
			if shotTimer.is_stopped():
				sprite.set_animation("Idle")
			else:
				sprite.set_animation("IdleShoot");
	elif grabbingLadder:
		if tile == LADDER_TILE_ID or tile == LADDER_TOP_TILE_ID:
			grabbingLadder = false
			on_ladder = true
	elif on_ladder:
		jumping = false
		#ez modo way of playing the ladder animation
		#Wait for begin animation to be done
		if sprite.get_animation() == "LadderBegin":
			if sprite.frame == sprite.frames.get_frame_count("LadderBegin")-1:
				sprite.set_animation("LadderLoop")
			
		if !shotTimer.is_stopped() and abs(velocity.y) < .5:
			pass
		else:
			sprite.set_animation("LadderLoop")
		
		if sprite.get_animation() == "LadderLoop":
			if abs(velocity.y) > .5:
				sprite.play()
			else:
				sprite.stop()
			
		if tile != LADDER_TILE_ID and tile != LADDER_TOP_TILE_ID:
			on_ladder = false
			if tile != LADDER_TOP_TILE_ID and velocity.y < 0:
				velocity.y = -400
				lockMovement(.3)
				sprite.set_animation("LadderFinish")
				sprite.play()
			else:
				sprite.set_animation("Falling")
	#Only stick to walls if you're going down
	elif is_on_wall() and velocity.y > 0:
		jumping = false
		sprite.set_animation("WallSlide")
		velocity.y = 100
	elif velocity.y > 0.5 and not movementLocked and not grabbingLadder and not groundCheck.is_colliding():
		if shotTimer.is_stopped():
			sprite.set_animation("Falling")
		else:
			sprite.set_animation("FallingShoot")
	
	#Move this later
	#var oScreenPos = stageRoot.position + position + stageRoot.get_canvas_transform().origin
	#var bounds = Vector2(400,200)
	#if oScreenPos.x > (1280-bounds.x) and (velocity * delta).x > 0:
	#	#print(oScreenPos.x-1280);
	#	#WARNING: canvas transform is flipped, so you want bound-screenpos and not the other way!
	#	#also the first vector2s are always (1,0), (0,1), don't change them or the game will crash
	#	#get_viewport().set_canvas_transform(Transform2D(Vector2(1,0),Vector2(0,1),Vector2(1280/2-oScreenPos.x,0)));
	#	get_viewport().set_canvas_transform(get_canvas_transform().translated(Vector2((velocity * delta * -1).x,0)))
	#elif oScreenPos.x < bounds.x and (velocity * delta).x < 0:
	#	get_viewport().set_canvas_transform(get_canvas_transform().translated(Vector2((velocity * delta * -1).x,0)))
	#
	#if oScreenPos.y > (720-bounds.y) and (velocity * delta).y > 0:
	#	get_viewport().set_canvas_transform(get_canvas_transform().translated(Vector2(0,(velocity * delta * -1).y)))
	#elif oScreenPos.y < bounds.y and (velocity * delta).y < 0:
	#	get_viewport().set_canvas_transform(get_canvas_transform().translated(Vector2(0,(velocity * delta * -1).y)))
	#only update this if the display is showing
	if debugDisplay:
		stateVelocity.text = String(velocity * delta)
		stateInfo.text = "On floor? " + String(self.is_on_floor())
		#stateInfo.text = "Touching wall and NOT floor? " + String((is_on_wall() and !is_on_floor()))
		#stateInfo.text = "Floor: " + String(is_on_floor()) + " Wall: " + String(is_on_wall()) + " Ceiling: " + String(rayCast.is_colliding())
		#stateInfo.text = "Floor:" + String(is_on_floor()) +" ! "+ "Jumping: "+String(jumping)
		#stateInfo.text = sprite.get_animation() + " ! " + String(sprite.is_playing())
		#stateInfo.text = "InWater? "+ String(inWater)
		#stateInfo.text = String(invincible)
		var cell = pos2cell(position)
		
		statePos.text = String(stepify(position.x,.01)) + ", " + String(stepify(position.y,.01))
		stateTile.text = String(tile) + " ! "+String(pos2cell(position)) + " ! " + String(cell.x*16*4+8*4) +","+ String(cell.y*16*4+8*4)
		#jumping = true
		#stateTile.text = "Jumping? " + String(jumping)
		#stateTile.text = String(get_collision_mask_bit(0)) + " " + String(get_collision_mask_bit(0))
		if currentCam != null:
			var camPos = get_node(currentCam).get_camera_position()
			cameraInfo.text = currentCam + " ! " + String(camPos.x) + "," + String(camPos.y)
		else:
			cameraInfo.text = "Zoom"+String($Camera2D.zoom)+" ! "+ String($Camera2D.get_camera_screen_center().x) + "," + String($Camera2D.get_camera_screen_center().y)
		
		#cameraInfo.text = "Camera Offset: " + String(stageRoot.get_canvas_transform().origin) + " ! "+ String(stageRoot.get_canvas_transform().x) + " ! " + String(stageRoot.get_canvas_transform().y);
		$CanvasLayer/PositionOnScreen.text = "Onscreen pos: " + String(stageRoot.position + position + stageRoot.get_canvas_transform().origin)
		
		

	velocity = move_and_slide(velocity, Vector2(0, -1), true)
	#move_and_slide()
	#velocity = move_and_slide(velocity, Vector2(0, -1))
	
	if movementLocked:
		processLockMovement(delta)
		
	if invincible:
		processInvincible(delta)
		
	#If collision is turned off we've already processed the movement so now we can turn it back on
	#But don't turn it back on if noClip is on
	if !get_collision_mask_bit(0) and !noClip:
		set_collision_mask_bit(0,true)
		set_collision_layer_bit(0,true)
		
	afterImage1.visible = dashing
	afterImage2.visible = dashing
	afterImage3.visible = dashing
	if dashing:
		var t = sprite.frames.get_frame(sprite.get_animation(), sprite.frame)
		var f = sprite.flip_h
		#var p = 1 if f else -1
		var i = 0
		oldPositions[5] = position
		while i < 5:
			oldPositions[i] = oldPositions[i+1]
			i+=1
		afterImage1.texture = t
		afterImage2.texture = t
		afterImage3.texture = t
		
		afterImage1.flip_h = f
		afterImage2.flip_h = f
		afterImage3.flip_h = f
		
		afterImage3.offset = oldPositions[4] - position
		afterImage2.offset = oldPositions[2] - position
		afterImage1.offset = oldPositions[0] - position
	
	if dashing and is_on_floor():
		collisionShape.shape.extents = Vector2(44,30)
		collisionShape.position = Vector2(0,44-30)
	else:
		collisionShape.shape.extents = Vector2(30,44)
		collisionShape.position = Vector2(0,0)
	
	

var movementLocked = false
var timeElapsed = 0.0
var lockTime = 0.0
func lockMovement(time):
	lockTime = time
	movementLocked = true
func processLockMovement(delta):
	timeElapsed += delta
	if timeElapsed > lockTime:
		movementLocked = false
		timeElapsed = 0.0
		

#var noCollision
#var framesPassed = 0
#var frameTime = 0
#func noCollisionForFrames(frameCount):
#	frameTime = frameCount

var invincible = false
var invincibilityElapsed = 0.0
var invincibleTime = 0.0
func processInvincible(delta):
	invincibilityElapsed += delta
	if invincibilityElapsed > invincibleTime:
		invincible = false
		invincibilityElapsed = 0.0
		sprite.modulate.a = 1

func player_touched(_obj):
	if !invincible:
		if !on_ladder:
			if is_on_floor():
				velocity.y = -200
			else:
				velocity.y = 200
				
			if sprite.flip_h:
				velocity.x = 200
			else:
				velocity.x = -200
			lockMovement(.3)
		HP-=1;
		if HP > 0:
			HPBar.updateHP(HP)
			$HurtSound.play()
			sprite.set_animation("Hurt")
			sprite.modulate.a = .5
			
			invincibleTime = 1
			invincible = true
		else:
			die()
			
var isDead = false
func die():
	if isDead == false:
		isDead = true
		set_physics_process(false)
		HP = 0
		HPBar.updateHP(HP)
		sprite.visible = false
		$Explosion.emitting = true
		$DieSound.play()
		yield($DieSound,"finished")
		$CanvasLayer/Fadeout.visible = true
		$CanvasLayer/Fadeout_Tween.interpolate_property($CanvasLayer/Fadeout, "modulate", Color(0,0,0,0), Color(0,0,0,1), 1, Tween.TRANS_LINEAR, Tween.EASE_OUT)
		$CanvasLayer/Fadeout_Tween.start()
		yield($CanvasLayer/Fadeout_Tween,"tween_completed")
		get_tree().reload_current_scene()
	
func healPlayer(amount):
	var newHP = HP+amount
	if newHP > MAX_HP:
		HP = MAX_HP
	else:
		HP = newHP
	HPBar.updateHP(HP)
	$HealSound.play()
	$HealAnimation.frame = 0
	$HealAnimation.play()
	
func restorePlayer(amount):
	#var newHP = HP+amount
	#if newHP > MAX_HP:
	#	HP = MAX_HP
	#else:
	#	HP = newHP
	#HPBar.updateHP(HP)
	$HealSound.play()
	$MPRestoreAnimation.frame = 0
	$MPRestoreAnimation.play()
