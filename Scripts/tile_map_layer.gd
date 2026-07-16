extends TileMapLayer

@export var x_min : int = 10
@export var x_max : int = 47
@export var y_min : int = 12
@export var y_max : int = 63

var enemy = load("res://Scenes/enemy.tscn")
var enemyPositions = []
var rockPositions = []

enum Direction {UP,DOWN,LEFT,RIGHT}

func TileReached(tile):
	erase_cell(local_to_map(tile))
	
func _ready():
	startLevel()
	
func startLevel():
	createPockets(4,5)
	
# Randomly generate an amount of pockets a specific distance away from each other, checking to ensure there isn't overlap before adding it to the array
func createPockets(count: int, safe_distance : float):
	enemyPositions = []
	
	while enemyPositions.size() < count:
		var randX = randi_range(x_min, x_max) * 8
		var randY = randi_range(y_min,y_max) * 8
		
		randX = map_to_local(local_to_map(Vector2i(randX, randY)))[0]
		randY = map_to_local(local_to_map(Vector2i(randX, randY)))[1]
		
		var is_valid : bool = true
		
		for pos in enemyPositions.size():
			if abs(enemyPositions[pos][0] - randX) > safe_distance or abs(enemyPositions[pos][1] - randY) > safe_distance:
				# No overlap
				pass
			else:
				is_valid = false
				break
		
		if is_valid:
			enemyPositions.append(Vector2i(randX, randY))
			
		erase_cell(local_to_map(Vector2i(randX, randY)))
		
		expandPockets(3,5, randX, randY)
		
		SpawnEnemy(randX, randY)
			
func expandPockets(min, max, randX, randY):
	# 0 = horizontal, 1 = vertical
	var randDir = randi_range(0,1)
	var randSize = randi_range(3,5)
	
	print("rand Dir: " + str(randDir))
	print("rand Size: " + str(randSize))

	if randDir == 0:
		var randXForward = randX
		var randXReverse = randX
		for j in randSize:
			print(j)
			randXForward = randXForward + 8
			randXReverse = randXReverse-8
			erase_cell(local_to_map(Vector2i(randXForward, randY)))
			erase_cell(local_to_map(Vector2i(randXReverse, randY)))
	elif randDir == 1:
		var randYForward = randY
		var randYReverse = randY
		for j in randSize:
			randY = randYForward + 8
			randYReverse = randYReverse-8
			erase_cell(local_to_map(Vector2i(randX, randYForward)))
			erase_cell(local_to_map(Vector2i(randX, randYReverse)))

func SpawnEnemy(x, y):
	var newEnemy = enemy.instantiate()
	add_child(newEnemy)
	newEnemy.global_position = Vector2(x,y)
	newEnemy.maze = self
	pass

func is_tile_free(dir, pos) -> bool:
	# Get current cell
	var current_cell = local_to_map(pos)
	
	# Calculate next cell based on direction
	var next_cell = current_cell
	match dir:
		Direction.UP: next_cell.y -= 1
		Direction.DOWN: next_cell.y += 1
		Direction.LEFT: next_cell.x -= 1
		Direction.RIGHT: next_cell.x += 1
		
	# Check if it's free - if so, return true
	
	var tile_data = get_cell_tile_data(next_cell)
	
	if tile_data == null:
		return true
	else:
		return false
		
func get_tile(dir, pos):
	# Get current cell
	var current_cell = local_to_map(pos)
	
	# Calculate next cell based on direction
	var next_cell = current_cell
	match dir:
		Direction.UP: next_cell.y -= 1
		Direction.DOWN: next_cell.y += 1
		Direction.LEFT: next_cell.x -= 1
		Direction.RIGHT: next_cell.x += 1
	
	return map_to_local(next_cell)
