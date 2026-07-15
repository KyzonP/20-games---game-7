extends TileMapLayer

func TileReached(tile):
	erase_cell(local_to_map(tile))
	
func _ready():
	CreatePockets()
	
func CreatePockets():
	# Randomly generate pockets in the four quarters of the board, and expand those a random amount vertically and horizontally
	for i in 4:
		var randX
		var randY
		
		if i == 0:
			randX = randi_range(10,25) * 8
			randY = randi_range(11,30) * 8
		elif i == 1:
			randX = randi_range(35,47) * 8
			randY = randi_range(11,30) * 8
		elif i == 2:
			randX = randi_range(10,25) * 8
			randY = randi_range(40,63) * 8
		elif i == 3:
			randX = randi_range(35,47) * 8
			randY = randi_range(40,63) * 8
			
		erase_cell(local_to_map(Vector2i(randX, randY)))
		
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

func SpawnEnemy():
	pass
