extends Area2D

@export var level : Node2D
@export var maze : TileMapLayer

enum Direction {UP, DOWN, LEFT, RIGHT, VOID}
var moveDir : Direction = Direction.VOID

var speed : float = 100.0

func _ready():
	area_entered.connect(collision)

func _physics_process(delta):
	var cell = maze.local_to_map(global_position)
	var centre = maze.map_to_local(cell)
	
	if global_position.distance_to(centre) < (speed * delta):
		if not maze.is_tile_free(moveDir, global_position):
			destroy()
	
	match moveDir:
		Direction.UP: global_position.y -= speed * delta
		Direction.DOWN: global_position.y += speed * delta
		Direction.LEFT: global_position.x -= speed * delta
		Direction.RIGHT: global_position.x += speed * delta

func collision(area):
	if area.is_in_group("Rock") or area.is_in_group("Enemy"):
		destroy()

func destroy():
	self.queue_free()
	
