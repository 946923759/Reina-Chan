tool
extends Node2D

enum PANEL {
	normal=0,
	cracked, #It breaks after you step off it
	broken,  #It's broken, it will repair itself after some time
	grass,   #fire does extra damage, I think?
	ice,     #You'll slide
	sand,    #You'll get stuck
	poison,  #You'll take poison damage (unless you're floating or have immunity)
	burner,
	thunder, 
	hole,    #This panel has a permanent hole in it
	none,    #This panel doesn't exist
}

var bright:bool=false #If there is an attack on top of this panel
"""
private const int poisonanimation = 10;
private const int bandtanimation = 3;
private const int thunderwait = 100;
private const int defaulttime = 180;
"""
var flashtime:int=0 #WHAT DOES IT DO???
var noRender:bool=false
var playAnimation:bool=false
var animeChange:bool=false
var curAnimationFrame:int = 0
var animReversed:bool=false #Poison tiles go 0,1,2
var counter:int=0; #NO IDEA what this does
"""
private Point position;
"""
var thunderCount:int=0 #No idea what it does
var oldState:int=PANEL.normal;
export (PANEL) var state = PANEL.normal
export (int,"Red","Blue") var playerSide= 0
"""
public Panel.COLOR colordefault;
public bool inviolability;
"""
var bashed:bool=false #WHAT DOES IT MEAN?
var colorFlashing:bool=false #Panels will flash if AreaGrab effect is wearing off
const BREAK_COOLDOWN_LEN:int = 600
var breakCooldown:int = 0;
# I don't have a better description for it but
# the game flashes between broken and the normal state when being repaired
var showingRepaired:bool=false; 
var flashing:bool=false; #WHAT DOES IT MEAN?


var panelPos:Vector2
var stage:Node2D
var characters:Node2D
	
func _ready():
	if Engine.editor_hint:
		#set_process(true)
		return
	stage = get_parent().get_parent()
	characters = stage.get_node("Characters")
	set_process(true)
func init(panelPos:Vector2):
	self.panelPos = panelPos

var s = preload("res://bntest/Panels.png")
func _draw():
	if state==PANEL.none:
		return
	if curAnimationFrame < 0: #In what context would this even be possible?
		curAnimationFrame=0
		
	var num = playerSide;
	if colorFlashing: #Pick reverse side
		match playerSide:
			0:
				num=1
			1:
				num=0
	
	if state != PANEL.poison && state != PANEL.burner && state != PANEL.thunder && curAnimationFrame>0:
		curAnimationFrame = 0;
	
	var destRect = Rect2(0,0,40,32);
	match state:
		PANEL.broken:
			if showingRepaired:
				draw_texture_rect(s,
					Rect2(40*num,0,40,32),
					false
				)
			else:
				draw_texture_rect(s,
					Rect2(40*num,state*32,40,32),
					false
				)
		PANEL.poison,PANEL.burner,PANEL.thunder:
			#this._rect = new Rectangle(40 * num + curAnimationFrame * 80, (int)this.state * 32, 40, 32);
			draw_texture_rect_region(s,
				destRect,
				Rect2(40*num+curAnimationFrame*80,state*32,40,32)
			)
		_:
			draw_texture_rect_region(s,
				destRect,
				Rect2(40*num,state*32,40,32)
			)
			#draw_texture_rect(s,
			#	Rect2(40*num,state*32,40,32),
			#	false
			#)
	if bright: #Draw highlight
		draw_texture_rect(s,
			Rect2(200,0,40,32),
			false
		)
	#tex, dest, source
	#Rect2 = x,y,width,height
	#draw_texture_rect_region(s,
	#	Rect2(i*35+xPosition,yPosition,31,24),
	#	Rect2(0,24*result[i],31,24)
	#)
func isCharacterOnTile()->bool:
	for c in characters.get_children():
		if c.charaPos==panelPos:
			return true
	return false
# I miss C# setters and getters
# Maybe using Mono isn't such a bad idea after all
func setState(st:int):
	match st:
		PANEL.cracked:
			Crack();
		PANEL.broken:
			Break();
		_:
			if getIsHole() or state == PANEL.none or state == st:
				return
			state = st
			
func getIsHole():
	return state==PANEL.broken or state == PANEL.hole or state == PANEL.none
	
func Crack():
	match state:
		PANEL.cracked:
			if isCharacterOnTile():
				return
			state = PANEL.broken
		PANEL.broken,PANEL.hole,PANEL.none:
			return
		_:
			state = PANEL.cracked
			
func Break():
	match state:
		PANEL.broken,PANEL.hole,PANEL.none:
			return
		_:
			if !isCharacterOnTile():
				state = PANEL.broken
			else:
				state = PANEL.cracked
				
func InitState():
	match state:
		PANEL.normal,PANEL.cracked,PANEL.grass,PANEL.ice,PANEL.sand:
			if counter > 0:
				counter = 0;
			if curAnimationFrame > 0:
				curAnimationFrame = 0;
			playAnimation=false

var framesElapsed:int=0
var frameTimer:float=0.0
#ABANDON ALL HOPE, YE WHO ENTER HERE
#Becuase who needs frame based timing right? Lmao
const oneFrame:float = 0.016666667
func _process(delta):
	frameTimer+=delta
	if frameTimer<=oneFrame:
		return
	frameTimer=0
	if Engine.editor_hint:
		if state==PANEL.poison:
			framesElapsed+=1
			if framesElapsed==10: #The poison panels go 0,1,2,1,0...
				framesElapsed = 0;
				curAnimationFrame += -1 if animReversed else 1
				if curAnimationFrame <= 0:
					animReversed = false;
				elif curAnimationFrame >= 2:
					animReversed = true;
		update();
		return
	#test
	#return
	
	
	
	if flashtime > 0:
		flashtime-=1;
		if flashtime % 8 == 0:
			flashing = !flashing;
	elif flashing:
		flashing = false;
	#No idea what this code does
	"""if (this.bashed && (this.parent.bashtime <= 0 && this.color != this.colordefault))
	{
		bool flag = false;
		if (this.colordefault == Panel.COLOR.blue && this.parent.redRight < this.position.X)
			flag = true;
		else if (this.colordefault == Panel.COLOR.red && this.parent.blueLeft > this.position.X)
			flag = true;
		if (flag)
		{
			this.flashtime = 180;
			this.color = this.colordefault;
			this.bashed = false;
		}
	}"""
	if state != oldState:
		oldState = state
		InitState()
	match state:
		PANEL.poison:
			#print("H")
			framesElapsed+=1
			if framesElapsed==10: #The poison panels go 0,1,2,1,0...
				framesElapsed = 0;
				curAnimationFrame += -1 if animReversed else 1
				if curAnimationFrame <= 0:
					animReversed = false;
				elif curAnimationFrame >= 2:
					animReversed = true;
				
		PANEL.burner,PANEL.thunder:
			#Not implemented lol!!!!!!!!!
			return
			
	#Doesn't work yet...
	update()
	return
	
	if breakCooldown > 0:
		if state == PANEL.broken: # && !this.parent.blackOut
			breakCooldown-=1;
			if breakCooldown < 180 && breakCooldown % 3 == 0:
				showingRepaired = !showingRepaired;
			if breakCooldown > 0:
				return;
			state = PANEL.normal;
		else:
			breakCooldown=0
	else:
		if state != PANEL.broken:
			return
		breakCooldown=BREAK_COOLDOWN_LEN
		showingRepaired = false;
	update()
