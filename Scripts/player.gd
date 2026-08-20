extends Area2D

@export var level : Node2D
@export var maze : TileMapLayer

enum Direction {UP, DOWN, LEFT, RIGHT, VOID}
var lastDir : Direction = Direction.RIGHT
var faceDir : Direction = Direction.DOWN
var moveDir : Direction = Direction.RIGHT
var moveUp : bool = false
var moveLeft : bool = false
var moveRight : bool = false
var moveDown : bool = false
var lock : bool = true
var dead : bool = false
var shootTimer : float = 2.0
var shootTimerMax : float = 2.0
var shotReady : bool = true

var projectile = load("res://scenes/projectile.tscn")

var speed : float = 80.0

const SNAP_DISTANCE = 4

func _ready():
	var cell = maze.local_to_map(global_position)
	var centre = maze.map_to_local(cell)
	
	area_entered.connect(killCollide)
	event_bus.startLevel.connect(unlock)
	event_bus.mobileShoot.connect(SpawnProjectile)
	event_bus.joystickMoved.connect(joystickMovement)
	event_bus.joystickReleased.connect(joystickReleased)
	
	maze.TileReached(centre)

func _input(event):
	if event.is_action_pressed("move_up"):
		lastDir = Direction.UP
		faceDir = Direction.UP
		moveUp = true
	elif event.is_action_released("move_up"):
		moveUp = false
	if event.is_action_pressed("move_down"):
		lastDir = Direction.DOWN
		faceDir = Direction.DOWN
		moveDown = true
	elif event.is_action_released("move_down"):
		moveDown = false
	if event.is_action_pressed("move_left"):
		lastDir = Direction.LEFT
		faceDir = Direction.LEFT
		moveLeft = true
	elif event.is_action_released("move_left"):
		moveLeft = false
	if event.is_action_pressed("move_right"):
		lastDir = Direction.RIGHT
		faceDir = Direction.RIGHT
		moveRight = true
	elif event.is_action_released("move_right"):
		moveRight = false
		
	if not lock:
		if event.is_action_pressed("shoot"):
			SpawnProjectile()
			
func joystickMovement(direction):
	# so 20 in each direction - x as -20 for left, +20 for right
	# y as -20 for up, +20 for down
	if abs(direction[0]) > abs(direction[1]):
		# horizontal
		if direction[0] < 0:
			lastDir = Direction.LEFT
			faceDir = Direction.LEFT
			moveLeft = true
		else:
			lastDir = Direction.RIGHT
			faceDir = Direction.RIGHT
			moveRight = true
	else:
		# vertical
		if direction[1] < 0:
			lastDir = Direction.UP
			faceDir = Direction.UP
			moveUp = true
		else:
			lastDir = Direction.DOWN
			faceDir = Direction.DOWN
			moveDown = true
			
func joystickReleased():
	moveLeft = false
	moveRight = false
	moveUp = false
	moveDown = false
		
func _physics_process(delta):
	var cell = maze.local_to_map(global_position)
	var centre = maze.map_to_local(cell)
	if not lock:
		updateAnim()
		
		shootTimer += delta
		if shootTimer >= shootTimerMax and not shotReady:
			shotReady = true
			event_bus.shotReady.emit()
		
		if not moveUp and not moveLeft and not moveDown and not moveRight:
			lastDir = Direction.VOID
		
		if lastDir != moveDir:
			if global_position.distance_to(centre) < SNAP_DISTANCE:
				global_position = centre
				moveDir = lastDir
				
		if global_position.distance_to(centre) < (speed * delta):
			maze.TileReached(centre)
			
			# If leaving map boundaries
			if not maze.is_tile_free(moveDir, global_position, true):
				
				global_position = centre
				moveDir = Direction.VOID
				
		match moveDir:
			Direction.UP: global_position.y -= speed * delta
			Direction.DOWN: global_position.y += speed * delta
			Direction.LEFT: global_position.x -= speed * delta
			Direction.RIGHT: global_position.x += speed * delta
			
		if global_position.y <= 56:
			global_position = centre
			moveDir = Direction.VOID
	else:
		if global_position.distance_to(centre) < (speed * delta):
			maze.TileReached(centre)
			
	
			
func updateAnim():
	match moveDir:
		Direction.VOID:
			if $AnimatedSprite2D.is_playing():
				$AnimatedSprite2D.stop()
		Direction.UP:
			if $AnimatedSprite2D.animation != "up":
				$AnimatedSprite2D.play("up")
		Direction.DOWN:
			if $AnimatedSprite2D.animation != "down":
				$AnimatedSprite2D.play("down")
		Direction.LEFT:
			if $AnimatedSprite2D.animation != "left":
				$AnimatedSprite2D.play("left")
		Direction.RIGHT:
			if $AnimatedSprite2D.animation != "right":
				$AnimatedSprite2D.play("right")
			
func SpawnProjectile():
	if shootTimer >= shootTimerMax and shotReady and not lock:
		shootTimer = 0
		shotReady = false
		
		var newProjectile = projectile.instantiate()
		get_parent().add_child(newProjectile)
		newProjectile.global_position = self.global_position
		newProjectile.maze = maze
		newProjectile.moveDir = faceDir
		
		event_bus.shotFired.emit()
			
func unlock():
	lock = false

func killCollide(area):
	if area.is_in_group("Rock"):
		if area.state == area.States.FALLING:
			defeat()
	if area.is_in_group("Enemy"):
		defeat()
			
func defeat():
	if not dead:
		dead = true
		event_bus.emit_signal("playerDefeated")
		print("Game Over!")
