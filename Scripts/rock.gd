extends Area2D

@export var maze : TileMapLayer
var state = States.STABLE
var shakeTween
var fallTween

var speed : float = 40.0

enum States {STABLE, SHAKING, FALLING}
enum Direction {UP, DOWN, LEFT, RIGHT, VOID}

func _physics_process(delta):
	if state == States.STABLE:
		if checkBeneath():
			startShake()

func checkBeneath():
	return maze.is_tile_free(Direction.DOWN, global_position)

func startShake():
	state = States.SHAKING
	
	if shakeTween:
		shakeTween.kill()
	
	shakeTween = create_tween()
	var shake = 2
	var shake_duration = 1.0
	var shake_count = 10
	for i in shake_count:
		shakeTween.tween_property($AnimatedSprite2D, "position", Vector2(randf_range(-shake, shake), randf_range(-shake, shake)), shake_duration / shake_count)
		shakeTween.finished.connect(startFall)

func startFall():
	state = States.FALLING
	
	if fallTween:
		fallTween.kill()
		
	if shakeTween:
		var cell = maze.local_to_map(global_position)
		var centre = maze.map_to_local(cell)
		global_position = centre
		
		shakeTween.kill()
		
	fallTween = create_tween()
	fallTween.tween_property(self, "position", Vector2(self.global_position.x, self.global_position.y + 16), self.global_position.distance_to(Vector2(self.global_position.x, self.global_position.y + 16))/speed)
	fallTween.finished.connect(checkEndFall)

func checkEndFall():
	if checkBeneath():
		startFall()
	else:
		endFall()

func endFall():
	state = States.STABLE
