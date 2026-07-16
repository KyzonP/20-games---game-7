extends Area2D

@export var maze : TileMapLayer

enum Direction {UP, DOWN, LEFT, RIGHT, VOID}
var lastDir : Direction = Direction.RIGHT
var moveDir : Direction = Direction.RIGHT
var moveUp : bool = false
var moveLeft : bool = false
var moveRight : bool = false
var moveDown : bool = false

var speed : float = 80.0

const SNAP_DISTANCE = 4


func _input(event):
	if event.is_action_pressed("move_up"):
		lastDir = Direction.UP
		moveUp = true
	elif event.is_action_released("move_up"):
		moveUp = false
	if event.is_action_pressed("move_down"):
		lastDir = Direction.DOWN
		moveDown = true
	elif event.is_action_released("move_down"):
		moveDown = false
	if event.is_action_pressed("move_left"):
		lastDir = Direction.LEFT
		moveLeft = true
	elif event.is_action_released("move_left"):
		moveLeft = false
	if event.is_action_pressed("move_right"):
		lastDir = Direction.RIGHT
		moveRight = true
	elif event.is_action_released("move_right"):
		moveRight = false
	
func _physics_process(delta):
	var cell = maze.local_to_map(global_position)
	var centre = maze.map_to_local(cell)
	
	if not moveUp and not moveLeft and not moveDown and not moveRight:
		lastDir = Direction.VOID
	
	if lastDir != moveDir:
		if global_position.distance_to(centre) < SNAP_DISTANCE:
			global_position = centre
			moveDir = lastDir
			
	if global_position.distance_to(centre) < (speed * delta):
		maze.TileReached(centre)
		
		# If leaving map boundaries
		if 1 != 1:
			global_position = centre
			moveDir = Direction.VOID
			
	match moveDir:
		Direction.UP: global_position.y -= speed * delta
		Direction.DOWN: global_position.y += speed * delta
		Direction.LEFT: global_position.x -= speed * delta
		Direction.RIGHT: global_position.x += speed * delta
			
	
	pass
