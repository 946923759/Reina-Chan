extends "res://Stages_Reina/Bosses/BossBase.gd"

"""
First, Alchemist starts off by shooting at you.
Then she dashes three times, left right left (or reversed)
If you're too close to her she'll jump a little and do a Shirouken.

In pinch mode:
	She shoots and dashes slightly faster, in the middle of her third dash she'll
	jump into the air.
	
	Instead of dashing she might randomly jump towards the wall and start throwing
	pumpkins.
	
	
 -AmWorks
"""

enum STATES {
	RANDOMPICK,
	SHOOTING,
	DASHING,
	JUMPING_TOWARDS_CENTER,
	JUMPING_AGAIN,
	JUMPING_TOWARDS_WALL,
	SHIROUYKEN,
	WALLHANG,
	WALLDASH,
}
var previous_state:int = STATES.RANDOMPICK
var current_state:int = STATES.RANDOMPICK

#YEP, HERE WE GO AGAIN
const bullet = preload("res://Stages_Reina/Enemies/EnemyChargeShot.tscn")
var pumpkin = preload("res://Stages_Reina/Bosses/Alchemist/PumpkinBomb.tscn")

#onready var nearestRoomCorner = get_room_position()/CAMERA_SCALE

func _ready():
	$NearestBlock.visible = OS.is_debug_build()
	

var stateProgress:int=0
var dashStartDirection:int=1
var cooldown:float=0.0
var dashTime:float=0.0
var tempVelocity:Vector2
var justShot:bool=false

#If not random enough, force it
#var randResults = [false,true,false]

func _physics_process(delta):
	if not enabled:
		return
	elif cooldown >=0:
		cooldown-=delta
		return
		
	sprite.playing=true
	sprite.flip_h = (facing == DIRECTION.RIGHT)
	$NearestBlock.text = String(get_room_position()/CAMERA_SCALE)
	
	match current_state:
		STATES.RANDOMPICK:
			stateProgress=0
			tempVelocity=Vector2(0,1000)
			var rand = randi()%3
			#var rand:bool = randi()%2==1
			#if randResults[0] and randResults[1] and rand:
			#	rand=false
			#elif !randResults[0] and !randResults[1] and !rand:
			#	rand=true
			#	
			#randResults[0]=randResults[1]
			#randResults[1]=randResults[2]
			#randResults[2]=rand
			#print(randResults)
			
			if rand==1 and previous_state==STATES.DASHING:
				rand=0
			print(rand)
			match rand:
				0:
					if health <= 14:
						#stateProgress=0
						current_state = STATES.JUMPING_TOWARDS_WALL
						if get_room_position().x/CAMERA_SCALE < 10:
							facing=-1
						else:
							facing=1
						tempVelocity=Vector2(facing*400,-1000)
						sprite.set_animation("jump")
						
					else:
						current_state = STATES.JUMPING_TOWARDS_CENTER
						tempVelocity=Vector2(facing*375,-1000)
						sprite.set_animation("jump")
				1:
					dashStartDirection=facing
					current_state=STATES.DASHING
				2:
					
					sprite.set_animation("twoShoot")
					sprite.frame=0
					current_state=STATES.SHOOTING
			move_and_slide(tempVelocity,Vector2(0, -1))
		STATES.SHOOTING:
			if (sprite.frame==2 or sprite.frame==5):
				if justShot:
					return
				if Globals.playerData.gameDifficulty > Globals.Difficulty.EASY or sprite.frame==5:
					var bi = bullet.instance()
					var pos = position + Vector2(30*facing, 0)
				
					bi.position = pos
					get_parent().add_child(bi)
					bi.init(facing)
				
				#self.add_collision_exception_with(bi)# Make bullet and this not collide
				justShot=true
			elif sprite.frame==7:
				justShot=false
				current_state=STATES.RANDOMPICK
				cooldown=.75
			else:
				justShot=false
		STATES.DASHING:
			#It was deemed too difficult, so now she's only invlunerable during this move
			#if the player is playing above easy mode.
			is_reflecting=Globals.playerData.gameDifficulty > Globals.Difficulty.EASY
			if stateProgress >=3:
				is_reflecting=false
				sprite.set_animation('idle')
				
				# Beginner = .4
				# Easy = .3
				# Medium = .2
				# Hard and above = .1
				cooldown = max(4 - Globals.playerData.gameDifficulty, 1)/10.0
				#print(cooldown)
				#print(randi()%2)
				#stateProgress = 0
				previous_state = current_state
				current_state = STATES.RANDOMPICK
			elif dashTime < .8 and (
					(get_room_position().x/CAMERA_SCALE < 17 and facing==DIRECTION.RIGHT)
					or
					(get_room_position().x/CAMERA_SCALE > 2 and facing==DIRECTION.LEFT)
				):
				sprite.set_animation("dash")
				# warning-ignore:return_value_discarded
				move_and_slide(Vector2(facing*900,500),Vector2(0, -1))
				dashTime+=delta
			else:
				sprite.set_animation("uppercut")
				cooldown=.2
				dashTime=0
				stateProgress+=1
				dashStartDirection*=-1
				facing=dashStartDirection
		#STATES.JUMPING_CENTER_START:
		#	tempVelocity=Vector2(facing*250,-900)
		#	current_state=STATES.JUMPING_TOWARDS_CENTER
		STATES.JUMPING_TOWARDS_WALL:
			tempVelocity.y+=1600*delta
			if is_on_wall():
				facing*=-1
				sprite.flip_h = (facing == DIRECTION.RIGHT)
				sprite.set_animation('wallhang')
				sprite.offset.x=4*facing #Make sure to change it back later...
				current_state=STATES.WALLHANG
				cooldown=.3
			elif is_on_floor():
				facing*=-1
				current_state=STATES.DASHING
			else:
				tempVelocity=move_and_slide(tempVelocity,Vector2(0,-1),true)
		STATES.WALLHANG:
			sprite.playing=true
			if sprite.frame==2:
				var bi = pumpkin.instance()
				var pos = position + Vector2(15*facing, -16)
				
				bi.position = pos
				get_parent().add_child(bi)
				bi.velocity=Vector2(10*facing,(randi()%5)-2)
				#bi.velocity=Vector2(5*facing,5)
				#bi.init(facing)
				
				self.add_collision_exception_with(bi)# Make bullet and this not collide
				stateProgress+=1
				current_state=STATES.WALLDASH
				tempVelocity=Vector2(0,0)
				if get_room_position().y/CAMERA_SCALE > 6.5:
					tempVelocity.y=-200
				cooldown=.5
		STATES.WALLDASH:
			sprite.set_animation("dash")
			if stateProgress==1:
				move_and_slide(Vector2(facing*900,tempVelocity.y),Vector2(0, -1))
			#elif stateProgress==2:
			#	move_and_slide(Vector2(facing*900,250),Vector2(0, -1))
			else:
				move_and_slide(Vector2(facing*900,300),Vector2(0, -1))
			#else:
			
			if false: #(global_position/64-nearestRoomCorner).x < 1 and (global_position/64-nearestRoomCorner).y > 7
				facing=1
				sprite.set_animation("jump")
				current_state=STATES.JUMPING_TOWARDS_CENTER
			elif is_on_wall():
				current_state=STATES.JUMPING_TOWARDS_WALL
				#cooldown=.3
			elif is_on_floor():
				if get_room_position().x/CAMERA_SCALE < 10:
					facing=1
				else:
					facing=-1
				#facing*=-1
				cooldown=.5
				sprite.set_animation('idle')
				current_state=STATES.RANDOMPICK
		STATES.JUMPING_TOWARDS_CENTER:
			if facing==DIRECTION.LEFT and get_room_position().x/CAMERA_SCALE < 10:
				tempVelocity.x=min(0,tempVelocity.x+delta*1000)
			elif facing==DIRECTION.RIGHT and get_room_position().x/CAMERA_SCALE > 9:
				tempVelocity.x=max(0,abs(tempVelocity.x)-delta*1000)
				
			tempVelocity=move_and_slide(tempVelocity,Vector2(0,-1),true)
			tempVelocity.y+=1600*delta
			if is_on_floor():
				current_state=STATES.JUMPING_AGAIN
				tempVelocity=Vector2(facing*375,-900)
		STATES.JUMPING_AGAIN:
			tempVelocity=move_and_slide(tempVelocity,Vector2(0,-1),true)
			tempVelocity.y+=1600*delta
			if is_on_floor():
				facing*=-1
				current_state=STATES.DASHING
