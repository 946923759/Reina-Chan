extends KinematicBody2D

const MAX_HP = 24 #Originally 32

var HP = 24 setget set_hp
var controller_index = 0
#Cooldown between shots
var shoot_time = 1e20
var invincible:bool = true
var invincible_time:float = 0.0
var locked_movement_time:float = 0.0

onready var stage = get_parent()
onready var INPUT = $INPUTMAN
onready var sprite = $Sprite
onready var bulletManager=$BulletManager
export(Rect2) var playfield_limit = Rect2(0,0,640,360)
export(NodePath) var player_hp_node
export(NodePath) var pause_screen
export(NodePath) var options_screen
onready var HPBar = get_node_or_null(player_hp_node)
onready var hitbox_sprite = $Hitbox
var hitbox_modulate:float = 0.0

var shotObj = preload('res://Screens/ScreenDanmaku/PlayerShotObj_2.tscn')
var deathAnimation = preload("res://Animations/deathAnimation.tscn")
#func _draw():
#	draw_rect(Rect2(playfield_limit.position-position,playfield_limit.size), Color.red, false)

var rapidFire:bool = (Globals.playerData.gameDifficulty==Globals.Difficulty.BEGINNER)
var noClip:bool = false

func _ready():
	update()
	sprite.animation = "FallingShoot"
	hitbox_sprite.modulate.a = 0.0

#This runs on parent ready
func _on_GameplayLayer_ready():
	bulletManager.init(get_parent())
	pass # Replace with function body.

func _process(delta):
	#update()
	pass

func _physics_process(delta):

	if invincible_time > 0.0:
		invincible_time -= delta
		if invincible_time <= 0:
			sprite.modulate.a = 1.0

	if locked_movement_time > 0.0:
		locked_movement_time -= delta
		
		#If this is true then this only runs once
		if locked_movement_time <= 0.0:
			#sprite.animation = "FallingShoot"
			pass
		return


	if Input.is_action_just_pressed("ui_options"):
		if options_screen:
			#get_node(options_screen).updateTimer(timer,timerWithDeath)
			get_tree().paused = true
			get_node(options_screen).OnCommand()
	elif Input.is_action_just_pressed("ui_pause"):
		if pause_screen:
			#PauseScreen.updateTimer(timer,timerWithDeath)
			#get_node(pause_screen).UpdateAmmo(weaponMeters)
			get_tree().paused = true
			#print("CurrentWeapon is "+String(currentWeapon))
			get_node(pause_screen).OnCommand(0)
	elif Input.is_action_just_pressed("DebugButton1"):
		if invincible_time > 1000:
			invincible_time = 0
		else:
			invincible_time = INF
		pass
	elif Input.is_action_just_pressed("DebugButton2"):
		if noClip:
			set_collision_mask_bit(0,true)
			set_collision_layer_bit(0,true)
			noClip = false
		else:
			set_collision_mask_bit(0,false)
			set_collision_layer_bit(0,false)
			noClip = true;
		CheckpointPlayerStats.usedDebugMode=true
	elif Input.is_action_just_pressed("DebugButton4"):
		rapidFire = !rapidFire
		#setDebugInfoText()
		CheckpointPlayerStats.usedDebugMode=true
	elif Input.is_action_just_pressed("DebugButton9"):
		$CanvasLayer/DebugButtonHelp.visible = !$CanvasLayer/DebugButtonHelp.visible
#		if debugDisplay.visible and $CanvasLayer/DebugButtonHelp.visible:
#			debugDisplay.visible=false
#			$CanvasLayer/DebugButtonHelp.visible=false
#			emit_signal("toggled_debug_disp",0)
#		elif debugDisplay.visible:
#			$CanvasLayer/DebugButtonHelp.visible = true
#			emit_signal("toggled_debug_disp",2)
#		else:
#			debugDisplay.visible=true
#			emit_signal("toggled_debug_disp",1)
		pass
			
	elif Input.is_action_just_pressed("DebugButton10"):
		die()

	#TODO: This is incorrect. shmups drop previous inputs instead of setting to 0.
	var directional_input = Vector2(
		Input.get_axis(INPUT.LEFT[controller_index], INPUT.RIGHT[controller_index]),
		Input.get_axis(INPUT.UP[controller_index], INPUT.DOWN[controller_index])
	)
	var spd:float = 500
	var shoot = false
	var focus = false

	if Input.is_action_just_pressed(INPUT.SHOOT[controller_index]):
		shoot = true
	elif rapidFire and shoot_time > .1:
		#This is action_pressed, not action_just_pressed
		#shoot = Input.is_action_pressed("ui_cancel")
		shoot = Input.is_action_pressed(INPUT.SHOOT[controller_index])
		shoot_time = 0
		
	if Input.is_action_pressed(INPUT.JUMP[controller_index]) or Input.is_action_pressed(INPUT.R1[controller_index]):
		focus = true
		spd /= 2.0
	
	if focus:
		hitbox_modulate = max(0.0, hitbox_modulate+delta*32.0)
	else:
		hitbox_modulate = min(1.0, hitbox_modulate-delta*2.0)
	hitbox_sprite.modulate.a = clamp(hitbox_modulate, 0.0, 1.0)
	
	self.position.x = min(
		max(playfield_limit.position.x, position.x+directional_input.x*delta*spd),
		playfield_limit.position.x+playfield_limit.size.x
	)
	self.position.y = min(
		max(playfield_limit.position.y, position.y+directional_input.y*delta*spd),
		playfield_limit.position.y+playfield_limit.size.y
	)
	#self.position.x += directional_input.x * delta * 100.0
	#self.position.y += directional_input.y * delta * 100.0
	#if Input.is_action_pressed():
	#	self.position.x -= 10
	
	if shoot and (
		Globals.playerData.gameDifficulty <= Globals.Difficulty.EASY or 
		bulletManager.get_num_bullets() < 3
	):
		spawn_shot(position, focus)
		
	shoot_time += delta
	
	

func spawn_shot(p:Vector2, focus:bool = false):
	
	var newShot = shotObj.instance()
	newShot.position = p + Vector2(20,0)
	newShot.linear_velocity = Vector2(800,0)
	newShot.get_node("VisibilityNotifier2D").connect("screen_exited",newShot,"queue_free")
	#This is just forcing it to zero before it gets added to the scene and overwritten
	newShot.scale = Vector2.ZERO;
	stage.add_child(newShot)
	$ShootSound.play()
	
	if Globals.playerData.gameDifficulty > Globals.Difficulty.EASY:
		bulletManager.push_bullet(newShot)
	return
	# old
#	var y_range = 50.0
#	if focus:
#		y_range = 25.0
#	for y in range(-1,2):
#		var newShot = shotObj.instance()
#		newShot.position = p + Vector2(20,0)
#		newShot.linear_velocity = Vector2(800,y * y_range)
#		newShot.get_node("VisibilityNotifier2D").connect("screen_exited",newShot,"queue_free")
#		newShot.get_node("AnimatedSprite").playing = true
#		newShot.scale = Vector2.ZERO;
#		stage.add_child(newShot)

func set_hp(i):
	HP = i
	var n = get_node_or_null(player_hp_node)
	if not n:
		return
	n.set_hp(HP)
	
func player_touched(obj:Node2D, damage_amount:int):
	if invincible_time>0:
		return
	HP-=damage_amount;
	if HP > 0:
		if HPBar:
			HPBar.current_hp = HP
		$HurtSound.play()
		#sprite.set_animation("Hurt")
		sprite.modulate.a = .5

		#device, weak magnitude, strong magnitude, duration
		INPUT.vibrate_device(
			0,
			min(.2+.1*damage_amount,1.0),
			min(.4+.1*damage_amount,1.0),
			.1
		)
		
		invincible_time = 1.0
		locked_movement_time = .25
	else:
		die()
	
var isDead = false
func die():
	if isDead == false:
		isDead = true
		#$CanvasLayer/Timer.set_process(false)
		#CheckpointPlayerStats.setDeathTimer(timerWithDeath)
		set_physics_process(false)
		HP = 0
		HPBar.current_hp = HP
		CheckpointPlayerStats.playerLivesLeft-=1
		self.visible = false
		
		#device, weak magnitude, strong magnitude, duration
		INPUT.vibrate_device(0,.5,.5,.3)
		
		var sp = deathAnimation.instance()
		sp.position=position
		get_parent().add_child(sp)
		$DieSound.play()
		yield($DieSound,"finished")
		
		var t = create_tween()
		var quad = get_node("%FadeIn/ColorRect")
		t.tween_property(get_node("%FadeIn"), "visible",true, 0.0)
		t.tween_property(quad,"visible",true,0.0)
		t.tween_property(quad,"color:a",1.0,.5)
		yield(t,"finished")
		#return
		
		if Globals.playerData.gameDifficulty < Globals.Difficulty.MEDIUM or CheckpointPlayerStats.playerLivesLeft >= 0:
# warning-ignore:return_value_discarded
			get_tree().reload_current_scene()
		else:
# warning-ignore:return_value_discarded
			Globals.change_screen(get_tree(),"ScreenTitleMenu")
