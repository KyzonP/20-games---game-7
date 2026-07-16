extends Area2D

@export var maze : TileMapLayer

var state : States = States.MOVE
var lastDir : Direction = Direction.VOID
var moveDir : Direction = Direction.VOID

enum States {MOVE, BURROW}
enum Direction {UP, DOWN, LEFT, RIGHT, VOID}

var speed : float = 40.0

const SNAP_DISTANCE = 4

func _physics_process(delta):
	var cell = maze.local_to_map(global_position)
	var centre = maze.map_to_local(cell)
	
	if lastDir != moveDir and maze.is_tile_free(lastDir, global_position):
		if global_position.distance_to(centre) < SNAP_DISTANCE:
			global_position = centre
			moveDir = lastDir
			
	if global_position.distance_to(centre) < (speed/1.5 * delta):
		checkIntersection(cell,centre)
		
	match moveDir:
		Direction.UP: global_position.y -= speed * delta
		Direction.DOWN: global_position.y += speed * delta
		Direction.LEFT: global_position.x -= speed * delta
		Direction.RIGHT: global_position.x += speed * delta
		
func checkIntersection(_cell, centre, turn : bool = false, spawn : bool = false):
	var possDir : Array[PotentialTiles] = []
	var _possibleDirections = 0
	
	var singleDir : Direction
	var singleDirConfirmed : bool = false
	
	
	
	if maze.is_tile_free(Direction.DOWN, centre + nextTile()):
		var newPoss = PotentialTiles.new(Direction.DOWN, maze.get_tile(Direction.DOWN, centre + nextTile()))
		possDir.append(newPoss)
		
		_possibleDirections += 1
		
		if not singleDirConfirmed:
			if moveDir == Direction.DOWN:
				singleDir = moveDir
				singleDirConfirmed = true
			
	if maze.is_tile_free(Direction.UP, centre + nextTile()):
		var newPoss = PotentialTiles.new(Direction.UP, maze.get_tile(Direction.UP, centre + nextTile()))
		possDir.append(newPoss)
		
		_possibleDirections += 1
		
		if not singleDirConfirmed:
			if moveDir == Direction.UP:
				singleDir = moveDir
				singleDirConfirmed = true
	
	if maze.is_tile_free(Direction.LEFT, centre + nextTile()):
		var newPoss = PotentialTiles.new(Direction.LEFT, maze.get_tile(Direction.LEFT, centre + nextTile()))
		possDir.append(newPoss)
		
		_possibleDirections += 1
		
		if not singleDirConfirmed:
			if moveDir == Direction.LEFT:
				singleDir = moveDir
				singleDirConfirmed = true
			
	if maze.is_tile_free(Direction.RIGHT, centre + nextTile()):
		var newPoss = PotentialTiles.new(Direction.RIGHT, maze.get_tile(Direction.RIGHT, centre + nextTile()))
		possDir.append(newPoss)
		
		_possibleDirections += 1
		
		if not singleDirConfirmed:
			if moveDir == Direction.RIGHT:
				singleDir = moveDir
				singleDirConfirmed = true
		
	if possDir.size() == 1:
		lastDir = possDir[0].dir
	elif singleDirConfirmed:
		lastDir = singleDir
	else:
		var randDir = randi_range(0,3)
		if randDir == 0:
			if maze.is_tile_free(Direction.UP, centre + nextTile()):
				lastDir = Direction.UP
				return
		elif randDir:
			if maze.is_tile_free(Direction.LEFT, centre + nextTile()):
				lastDir = Direction.LEFT
				return
		elif randDir:
			if maze.is_tile_free(Direction.RIGHT, centre + nextTile()):
				lastDir = Direction.RIGHT
				return
		elif randDir:
			if maze.is_tile_free(Direction.DOWN, centre + nextTile()):
				lastDir = Direction.DOWN
				return
	
func nextTile():
	if moveDir == Direction.UP:
		return Vector2(0,-16)
	if moveDir == Direction.DOWN:
		return Vector2(0,16)
	if moveDir == Direction.RIGHT:
		return Vector2(16,0)
	if moveDir == Direction.LEFT:
		return Vector2(-16,0)
	
	return Vector2.ZERO
	
class PotentialTiles:
	var dir : Direction
	var pos : Vector2
	
	func _init(_dir : Direction, _pos : Vector2):
		dir = _dir
		pos = _pos
