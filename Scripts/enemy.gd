extends Area2D

@export var fake : bool = false

@export var maze : TileMapLayer

var state : States = States.WAIT
var lastDir : Direction = Direction.VOID
var moveDir : Direction = Direction.RIGHT
var player : Area2D
var speed : float = 40.0

var burrowTimer : float = 0.0
var burrowTimerMax : float = 100.0
var burrowTarget : Vector2 = Vector2.ZERO
var burrowComplete : bool = false
var burrowTween

var burrowMin : float = 7.0
var burrowMax : float = 20.0

var fleeTween

enum States {MOVE, BURROW, FLEE, WAIT}
enum Direction {UP, DOWN, LEFT, RIGHT, VOID}

const SNAP_DISTANCE = 4

# Audio
var hurtSound = preload("res://audio/EnemyHurt.wav")

func _ready():
	if not fake:
		player = get_tree().get_nodes_in_group("Player")[0]
	else:
		unlock()
	
	area_entered.connect(killCollide)
	event_bus.flee.connect(startFlee)
	event_bus.startLevel.connect(unlock)
	
	setStats()
	
	burrowTimerMax = randf_range(burrowMin,burrowMax)
	
func setStats():
	speed = speed  + ((4 * global.level)-4)
	
	burrowMin = burrowMin - global.level
	burrowMax = burrowMax - global.level

	if burrowMin <= 0:
		burrowMin = 1
	
	if burrowMax <= 5:
		burrowMax = 5

func _physics_process(delta):
	var cell = maze.local_to_map(global_position)
	var centre = maze.map_to_local(cell)
	
	if state == States.MOVE:
		if not burrowComplete and not fake:
			burrowTimer += delta
			if burrowTimer >= burrowTimerMax:
				startBurrow()

		# If at the centre of a tile, check the tile ahead. If it's not available, get an array of
		# all possible directions. If there's only one, go that way, otherwise go the way that is
		# closest to the player
		if global_position.distance_to(centre) < (speed/1.5 * delta):
			chooseDirection()
			
		match moveDir:
			Direction.UP: global_position.y -= speed * delta
			Direction.DOWN: global_position.y += speed * delta
			Direction.LEFT: global_position.x -= speed * delta
			Direction.RIGHT: global_position.x += speed * delta
			
	elif state == States.BURROW:
		pass
		
	elif state == States.FLEE:
		pass
	
	elif state == States.WAIT:
		pass
		
	updateAnim()
		
func unlock():
	state = States.MOVE
	
func updateAnim():
	match state:
		States.MOVE:
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
		States.BURROW:
			if $AnimatedSprite2D.animation != "eyes":
				$AnimatedSprite2D.play("eyes")
		States.FLEE:
			if $AnimatedSprite2D.animation != "eyes":
				$AnimatedSprite2D.play("eyes")
		
func startBurrow():
	# Audio
	if $SFXPlayer.playing == false:
		$SFXPlayer.playing = true
	
	# Particles
	$DigParticles.emitting = true
	
	if burrowTween:
		burrowTween.kill()
	
	burrowTween = create_tween()
	burrowTarget = player.global_position
	burrowTween.tween_property(self, "position", burrowTarget, self.position.distance_to(player.global_position)/speed)
	burrowTween.finished.connect(endBurrow)
	
	state = States.BURROW
	
func endBurrow():
	# Audio
	$SFXPlayer.playing = false
	
	# Particles
	$DigParticles.emitting = false
	
	burrowComplete = true
	state = States.MOVE
	chooseDirection(true)
	
	var cell = maze.local_to_map(global_position)
	var centre = maze.map_to_local(cell)
	global_position = centre
	
	if burrowTween:
		burrowTween.kill()
		
	#startFlee()
		
func startFlee():
	# Audio
	if $SFXPlayer.playing == false:
		$SFXPlayer.playing = true
		
	# Particles
	$DigParticles.emitting = true
	
	state = States.FLEE
	
	if burrowTween:
		burrowTween.kill()
	
	if fleeTween:
		fleeTween.kill()
	#56
	fleeTween = create_tween()
	fleeTween.tween_property(self, "position", Vector2(self.global_position.x, 56), self.global_position.distance_to(Vector2(self.global_position.x, 56))/speed)
	fleeTween.finished.connect(continueFlee)

func continueFlee():
	if fleeTween:
		fleeTween.kill()
	fleeTween = create_tween()
	fleeTween.tween_property(self, "position", Vector2(-8, self.global_position.y), self.global_position.distance_to(Vector2(-8, self.global_position.y))/speed)
	fleeTween.finished.connect(finishFlee)

func finishFlee():
	# Code for ending level
	event_bus.emit_signal("enemyFled")
	
func defeat():
	# Audio
	AudioManager.play_sfx(hurtSound)
	
	# code for enemy dying
	if burrowTween:
		burrowTween.kill()
	if fleeTween:
		fleeTween.kill()
		
	event_bus.emit_signal("enemyDefeated", global_position.y)
	self.queue_free()

func chooseDirection(noDir : bool = false):
	var possibleDirections = maze.check_valid_directions(global_position)
			
	if possibleDirections.size() == 1:
		moveDir = possibleDirections[0]
	else:
		var shortestDistance = 10000000
		var reverseDir
		if moveDir == Direction.UP:
			reverseDir = Direction.DOWN
		elif moveDir == Direction.LEFT:
			reverseDir = Direction.RIGHT
		elif moveDir == Direction.DOWN:
			reverseDir = Direction.UP
		elif moveDir == Direction.RIGHT:
			reverseDir = Direction.LEFT
			
		if noDir:
			reverseDir = Direction.VOID
		
		if not fake:
			for i in possibleDirections.size():
				if possibleDirections[i] != reverseDir:
					var distance = player.global_position.distance_to(maze.get_tile(possibleDirections[i], global_position))
					if distance < shortestDistance:
						shortestDistance = distance
						moveDir = possibleDirections[i]
		else:
			for i in possibleDirections.size():
				if possibleDirections[i] == reverseDir:
					possibleDirections.remove_at(i)
					break
			moveDir = possibleDirections.pick_random()
					
	if global_position.y <= 44:
		moveDir = Direction.DOWN

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
	
func killCollide(area):
	if area.is_in_group("Projectile"):
		defeat()
	if area.is_in_group("Rock"):
		if area.state == area.States.FALLING:
			defeat()
	
class PotentialTiles:
	var dir : Direction
	var pos : Vector2
	
	func _init(_dir : Direction, _pos : Vector2):
		dir = _dir
		pos = _pos
