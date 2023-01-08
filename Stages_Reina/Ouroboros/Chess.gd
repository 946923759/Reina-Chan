extends Node2D
signal puzzle_completed()

enum PIECE {
	King=2,
	Queen,
	Bishop,
	Knight,
	Rook,
	Pawn
}

export(Vector2) var tilemap_grid_size = Vector2(6,6)

var b = preload("res://Various Objects/Special Blocks/breakableBlock.tscn")
#var b2 = preload("res://Various Objects/Special Blocks/BlockAsObject_2.tscn")

onready var breakableTiles = $BreakableTiles
onready var chessPieces = $ChessPieces
onready var sound = $Completed

var playfield:Array = []
#var chessPieces:Array = []

var completed:bool=false

func get_raw_pos_from_vector2(pos:Vector2)->int:
	if pos.y*tilemap_grid_size.x+pos.x >= tilemap_grid_size.x*tilemap_grid_size.y:
		print("ERROR: A position outside the grid was asked! "+String(pos))
		return -1
	return pos.y*tilemap_grid_size.x+pos.x
	
func get_tile_at(pos:Vector2)->int:
	return playfield[get_raw_pos_from_vector2(pos)]
func set_tile_at(pos:Vector2,type:int):
	playfield[get_raw_pos_from_vector2(pos)]=type


func init_tilemap(is_reset:bool=false):
	for i in range(tilemap_grid_size.x*tilemap_grid_size.y):
		playfield[i]=0
	for c in chessPieces.get_children():
		c.grid_position=c.starting_grid_position
		playfield[get_raw_pos_from_vector2(c.grid_position)]=c.piece_type+2
		if is_reset:
			c.position=c.grid_position*64+Vector2(32,32)
	
	if is_reset:
		for i in range(0, breakableTiles.get_child_count()):
			var n = breakableTiles.get_child(i)
			if n.is_class("StaticBody2D"):
				n.enable()
				
		var tiles = $TileMap
		for y in range(tilemap_grid_size.y):
			for x in range(tilemap_grid_size.x):
				var t = tiles.get_cell(x,y)
				if t != tiles.INVALID_CELL:
					playfield[y*tilemap_grid_size.x+x]=1
	else:
		var tiles = $TileMap
		for y in range(tilemap_grid_size.y):
			for x in range(tilemap_grid_size.x):
				var t = tiles.get_cell(x,y)
				if t != tiles.INVALID_CELL:
					var block = b.instance()
					if t==11:
						block.weaponCanBreak=0
						block.textureOverride=unbreakableBlockTexture
					else:
						#block.weaponCanBreak=1 #Buster only
						block.despawn_on_break=false
						block.maxHealth=1
						block.connect("block_broken",self,"block_broken_",[Vector2(x,y)])
					#e.init(true)
					#Breakable blocks are centered.
					block.position = Vector2(x,y)*64+Vector2(32,32)
					#e.position.y-=32
					breakableTiles.add_child(block)
					playfield[y*tilemap_grid_size.x+x]=1
					
		tiles.visible=false
	update_debug_disp()
	
func reset_tilemap(): #For compat with signals
	if completed:
		return
	init_tilemap(true)

var unbreakableBlockTexture:Texture
func _ready():
	playfield.resize(tilemap_grid_size.x*tilemap_grid_size.y)
	
	unbreakableBlockTexture=load("res://Stages_Reina/Alchemist/brick.png")
	
	init_tilemap()
	#update()
	
func update_debug_disp():
	if OS.is_debug_build():
	#	var s = ""
	#	for y in range(tilemap_grid_size.y):
	#		for x in range(tilemap_grid_size.x):
	#			s+=String(playfield[y*tilemap_grid_size.x+x])
	#		s+="\n"
	#	print(s)
		$DebugDisplay.playfield=playfield
		$DebugDisplay.tilemap_grid_size=tilemap_grid_size
		$DebugDisplay.update()

#func _process(delta):
func block_broken_(pos:Vector2):
	if completed:
		return
	#print("block broken")
	playfield[get_raw_pos_from_vector2(pos)]=0
	for p in chessPieces.get_children():
		for cond in p.alternate_win_conditions:
			var arr = cond.split(" ",true)
			var tmp = arr[0].split(',')
			var srcPoint:Vector2 = Vector2(int(tmp[0]),int(tmp[1]))
			tmp = arr[2].split(",")
			var dstPoint:Vector2 = Vector2(int(tmp[0]),int(tmp[1]))
			if cond[1]=='h':
				if is_path_towards_horizontal(srcPoint,dstPoint):
					p.grid_position=dstPoint
	move_pieces_down(pos.x)
	move_pieces_other()
	
	update_debug_disp()
	if scan_check_horizontal() or scan_check_diagonal() or scan_check_knight():
		#print("Checked!")
		sound.play()
		completed=true
		emit_signal("puzzle_completed")
		return
	pass

func move_pieces_down(col:int):
	for p in chessPieces.get_children():
		#print(p.grid_position)
		if p.grid_position.x==col:
			if p.piece_type+2==PIECE.Queen:
				#print("col match!")
				var emptySpacesBelow:int=0
				for y in range(p.grid_position.y+1,tilemap_grid_size.y,1):
					#print("Check "+String(Vector2(col,y)))
					var raw_pos:int=get_raw_pos_from_vector2(Vector2(col,y))
					if playfield[raw_pos]==0:
						emptySpacesBelow+=1
						
					else:
						break
				if emptySpacesBelow>0:
					set_tile_at(p.grid_position,0)
					p.grid_position.y+=emptySpacesBelow
					set_tile_at(p.grid_position,p.piece_type+2)
					#print("piece should move towards "+String(p.grid_position.y))
					p.begin_tweening()
			#else:
			#	print("Unknown chess piece "+String(p.piece_type)+" in column.")
				#var maxSpacesRight = 

func move_pieces_other():
	
	for p in chessPieces.get_children():
		if p.piece_type+2==PIECE.Queen:
			continue
		elif p.piece_type+2==PIECE.Bishop:
			var emptySpacesDownRight:int=0
			var x = p.grid_position.x
			for y in range(p.grid_position.y+1,tilemap_grid_size.y,1):
				x+=1
				if x > tilemap_grid_size.x:
					#print("Diagonal scan outside range")
					break
				var tmp_b = get_tile_at(Vector2(x,y))
				#print("Checked pos "+String(Vector2(x,y))+"... "+String(b))
				$DebugDisplay.debug_highlight_block(Vector2(x,y))
				if tmp_b==0:
					emptySpacesDownRight+=1
				else:
					break
			if emptySpacesDownRight>0:
				set_tile_at(p.grid_position,0)
				p.grid_position.y+=emptySpacesDownRight
				p.grid_position.x+=emptySpacesDownRight
				set_tile_at(p.grid_position,p.piece_type+2)
				#print("piece should move towards "+String(p.grid_position.y))
				p.begin_tweening()
		elif p.piece_type+2==PIECE.Knight:
			var pos = p.grid_position
			#Knights can jump over other pieces, so there
			#is no need to use a for loop to check if the blocks
			#are open. Simple math can determine it.
			for lr in [-1]:
				for posTocheck in [
					pos+Vector2(1*lr,-2),
					#pos+Vector2(1*lr,2),
					pos+Vector2(2*lr,-1),
					#pos+Vector2(2*lr,1),
				]:
					if posTocheck.x > tilemap_grid_size.x or posTocheck.y > tilemap_grid_size.y:
						continue
					elif posTocheck.x<0 or posTocheck.y<0:
						continue
					#print("Checking "+String(posTocheck))
					if get_tile_at(posTocheck)==0:
						$DebugDisplay.debug_highlight_block(posTocheck,Color.red)
						set_tile_at(p.grid_position,0)
						p.grid_position=posTocheck
						set_tile_at(p.grid_position,p.piece_type+2)
						p.begin_tweening()

func is_path_towards_horizontal(srcPos:Vector2,destPos:Vector2)->bool:
	if srcPos.x < destPos.x:
		for x in range(srcPos.x+1,destPos.x):
			var b = get_tile_at(Vector2(x,srcPos.y))
			if b!=0:
				return false
			$DebugDisplay.debug_highlight_block(Vector2(x,srcPos.y),Color.red)
		return true
	else:
		for x in range(srcPos.x-1,destPos.x,-1):
			var b = get_tile_at(Vector2(x,srcPos.y))
			if b!=0:
				return false
			$DebugDisplay.debug_highlight_block(Vector2(x,srcPos.y),Color.red)
		return true

func scan_check_horizontal()->bool:
	for p in chessPieces.get_children():
		match p.piece_type+2:
			PIECE.Queen,PIECE.Rook:
				for x in range(p.grid_position.x+1,tilemap_grid_size.x):
					var b = get_tile_at(Vector2(x,p.grid_position.y))
					$DebugDisplay.debug_highlight_block(Vector2(x,p.grid_position.y),Color.blue)
					#print(b)
					if b==PIECE.King:
						return true
					elif b==1:
						break
				for x in range(p.grid_position.x-1,0,-1):
					var b = get_tile_at(Vector2(x,p.grid_position.y))
					#print(b)
					if b==PIECE.King:
						return true
					elif b==1:
						break
	return false
	
func scan_check_diagonal()->bool:
	for p in chessPieces.get_children():
		var type = p.piece_type+2
		match type:
			PIECE.Queen,PIECE.Bishop:
				#TODO: Some better way of checking?
				var x = p.grid_position.x
				for y in range(p.grid_position.y+1,tilemap_grid_size.y,1):
					x+=1
					if x > tilemap_grid_size.x:
						break
					var b = get_tile_at(Vector2(x,y))
					$DebugDisplay.debug_highlight_block(Vector2(x,y),Color.blue)
					if b==PIECE.King:
						return true
					elif b==1:
						break
				
				x = p.grid_position.x
				for y in range(p.grid_position.y+1,tilemap_grid_size.y,1):
					x-=1
					if x < 0:
						break
					var b = get_tile_at(Vector2(x,y))
					$DebugDisplay.debug_highlight_block(Vector2(x,y),Color.blue)
					if b==PIECE.King:
						return true
					elif b==1:
						break
				
				x = p.grid_position.x
				for y in range(p.grid_position.y-1,0,-1):
					x+=1
					if x > tilemap_grid_size.x:
						break
					var b_obj = get_tile_at(Vector2(x,y))
					$DebugDisplay.debug_highlight_block(Vector2(x,y),Color.blue)
					if b_obj==PIECE.King:
						return true
					elif b_obj==1:
						break
			#_:
			#	continue
	return false

func scan_check_knight():
	for p in chessPieces.get_children():
		var type = p.piece_type+2
		match type:
			PIECE.Knight:
				var pos = p.grid_position
				
				#Knights can jump over other pieces, so there
				#is no need to use a for loop to check if the blocks
				#are open. Simple math can determine it.
				for lr in [-1,1]:
					for posTocheck in [
						pos+Vector2(1*lr,-2),
						pos+Vector2(1*lr,2),
						pos+Vector2(2*lr,-1),
						pos+Vector2(2*lr,1),
					]:
						if posTocheck.x > tilemap_grid_size.x or posTocheck.y >= tilemap_grid_size.y:
							continue
						elif posTocheck.x<0 or posTocheck.y<0:
							continue
						#print("Checking "+String(posTocheck)+ " | "+String(tilemap_grid_size))
						$DebugDisplay.debug_highlight_block(posTocheck,Color.blue)
						
						var b_obj = get_tile_at(posTocheck)
						if b_obj==PIECE.King:
							return true
	return false

func is_empty_space_at(pos:Vector2)->bool:
	return get_tile_at(pos)==0
