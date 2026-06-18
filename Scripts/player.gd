extends Area2D

@export var terrainPolygon : Polygon2D

var lastDir : Direction = Direction.VOID
var moveDir : Direction = Direction.VOID
var speed : float = 80.0
var moving : bool = false
var moveUp : bool = false
var moveDown : bool = false
var moveLeft : bool = false
var moveRight : bool = false

const SNAP_DISTANCE = 4

enum Direction {UP,DOWN,LEFT,RIGHT,VOID}

func _ready():
	pass

func _physics_process(delta):
	var roundPos = Vector2(floor(global_position.x/8)*8,floor(global_position.y/8)*8)
	
	if lastDir != moveDir and global_position.distance_to(roundPos) < SNAP_DISTANCE:
		global_position = roundPos
		moveDir = lastDir
	
	# Move in current move direction
	match moveDir:
		Direction.UP: global_position.y -= speed * delta
		Direction.DOWN: global_position.y += speed * delta
		Direction.LEFT: global_position.x -= speed * delta
		Direction.RIGHT: global_position.x += speed * delta
	
	# If moving, cut into terrain
	if lastDir != Direction.VOID:
		cut_terrain()
	
func _input(event):
	if event.is_action_pressed("move_up"):
		lastDir = Direction.UP
		moveUp = true
		moving = true
	if event.is_action_pressed("move_down"):
		lastDir = Direction.DOWN
		moveDown = true
		moving = true
	if event.is_action_pressed("move_left"):
		lastDir = Direction.LEFT
		moveLeft = true
		moving = true
	if event.is_action_pressed("move_right"):
		lastDir = Direction.RIGHT
		moveRight = true
		moving = true
		
	if event.is_action_released("move_up"):
		moveUp = false
	if event.is_action_released("move_down"):
		moveDown = false
	if event.is_action_released("move_left"):
		moveLeft = false
	if event.is_action_released("move_right"):
		moveRight = false
		
	if not moveUp and not moveDown and not moveLeft and not moveRight:
		moving = false
		
		lastDir = Direction.VOID
		moveDir = Direction.VOID
		
func cut_terrain():
	var offset = $Polygon2D.global_position - terrainPolygon.global_position
	var adjusted_points = []
	for point in $Polygon2D.polygon:
		adjusted_points.append(point + offset)
	
	var result = Geometry2D.clip_polygons(terrainPolygon.polygon, adjusted_points)
	
	if not result.is_empty():
		terrainPolygon.polygon = result[0]
	else:
		terrainPolygon.polygon = []
		
#func cut_terrain():
	#if $Polygon2D.polygon.is_empty():
		#return
	#
	#var offset = $Polygon2D.global_position - terrainPolygon.global_position
	#var adjusted_points = []
	#for point in $Polygon2D.polygon:
		#adjusted_points.append(point + offset)
		#
	#if Geometry2D.intersect_polygons(terrainPolygon.polygon, adjusted_points).is_empty():
		#return
#
	#var clean_terrain = Geometry2D.offset_polygon(terrainPolygon.polygon,0.0)
	#if clean_terrain.is_empty(): return
	#
	#var result = []
	#for sub_terrain in clean_terrain:
		#var clip_res = Geometry2D.clip_polygons(sub_terrain, adjusted_points)
		#result.append_array(clip_res)
	#
	#terrainPolygon.polygons = result
	#terrainPolygon.polygon = result[0] if not result.is_empty() else PackedVector2Array()
