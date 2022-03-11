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
var curState:int = STATES.RANDOMPICK

#YEP, HERE WE GO AGAIN
const bullet = preload("res://Stages_Reina/Enemies/EnemyChargeShot.tscn")
var pumpkin = preload("res://Stages_Reina/Bosses/Alchemist/PumpkinBomb.tscn")

#So the boss knows where to jump towards
#This can probably be done automatically by rounding but fuck it
export(Vector2) var nearestRoomCorner

func _ready():
	$NearestBlock.visible = OS.is_debug_build()
	

var stateProgress:int=0
var dashStartDirection:int=1
var cooldown:float=0.0
var dashTime:float=0.0
var tempVelocity:Vector2
var justShot:bool=false

#If not random enough, force it
var randResults = [false,true,false]

func _physics_process(delta):
	if not enabled:
		return
	elif cooldown >=0:
		cooldown-=delta
		return
		
	sprite.playing=true
	sprite.flip_h = (facing == DIRECTION.RIGHT)
	$NearestBlock.text = (String(global_position/64-nearestRoomCorner))
	
	match curState:
		STATES.RANDOMPICK:
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
			print(rand)
			match rand:
				0:
					if curHP <= 14:
						stateProgress=0
						curState = STATES.JUMPING_TOWARDS_WALL
						if (global_position/64-nearestRoomCorner).x < 10:
							facing=-1
						else:
							facing=1
						tempVelocity=Vector2(facing*400,-1000)
						sprite.set_animation("jump")
						
					else:
						curState = STATES.JUMPING_TOWARDS_CENTER
						tempVelocity=Vector2(facing*375,-1000)
						sprite.set_animation("jump")
				1:
					dashStartDirection=facing
					curState=STATES.DASHING
				2:
					
					stateProgress=0
					sprite.set_animation("twoShoot")
					sprite.frame=0
					curState=STATES.SHOOTING
			move_and_slide(tempVelocity,Vector2(0, -1))
		STATES.SHOOTING:
			if (sprite.frame==2 or sprite.frame==5):
				if justShot:
					return
				var bi = bullet.instance()
				var pos = position + Vector2(30*facing, 0)
				
				bi.position = pos
				get_parent().add_child(bi)
				bi.init(facing)
				
				#self.add_collision_exception_with(bi)# Make bullet and this not collide
				justShot=true
			elif sprite.frame==7:
				justShot=false
				curState=STATES.RANDOMPICK
				cooldown=.75
			else:
				justShot=false
		STATES.DASHING:
			is_reflecting=true
			if stateProgress >=3:
				is_reflecting=false
				#print(randi()%2)
				curState = STATES.RANDOMPICK
			elif dashTime < .8 and (
					((global_position/64-nearestRoomCorner).x < 17 and facing==DIRECTION.RIGHT)
					or
					((global_position/64-nearestRoomCorner).x > 2 and facing==DIRECTION.LEFT)
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
		#	curState=STATES.JUMPING_TOWARDS_CENTER
		STATES.JUMPING_TOWARDS_WALL:
			tempVelocity.y+=1600*delta
			if is_on_wall():
				facing*=-1
				sprite.flip_h = (facing == DIRECTION.RIGHT)
				sprite.set_animation('wallhang')
				sprite.offset.x=4*facing #Make sure to change it back later...
				curState=STATES.WALLHANG
				cooldown=.3
			elif is_on_floor():
				facing*=-1
				curState=STATES.DASHING
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
				curState=STATES.WALLDASH
				tempVelocity=Vector2(0,0)
				if (global_position/64-nearestRoomCorner).y > 6.5:
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
				curState=STATES.JUMPING_TOWARDS_CENTER
			elif is_on_wall():
				curState=STATES.JUMPING_TOWARDS_WALL
				#cooldown=.3
			elif is_on_floor():
				if (global_position/64-nearestRoomCorner).x < 10:
					facing=1
				else:
					facing=-1
				#facing*=-1
				cooldown=.5
				sprite.set_animation('idle')
				curState=STATES.RANDOMPICK
		STATES.JUMPING_TOWARDS_CENTER:
			if facing==DIRECTION.LEFT and (global_position/64-nearestRoomCorner).x < 10:
				tempVelocity.x=min(0,tempVelocity.x+delta*1000)
			elif facing==DIRECTION.RIGHT and (global_position/64-nearestRoomCorner).x > 9:
				tempVelocity.x=max(0,abs(tempVelocity.x)-delta*1000)
				
			tempVelocity=move_and_slide(tempVelocity,Vector2(0,-1),true)
			tempVelocity.y+=1600*delta
			if is_on_floor():
				curState=STATES.JUMPING_AGAIN
				tempVelocity=Vector2(facing*375,-900)
		STATES.JUMPING_AGAIN:
			tempVelocity=move_and_slide(tempVelocity,Vector2(0,-1),true)
			tempVelocity.y+=1600*delta
			if is_on_floor():
				facing*=-1
				curState=STATES.DASHING
