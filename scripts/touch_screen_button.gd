extends TouchScreenButton

var radiusJoyStick
var radiusJoyBase
var maxLength
var doubleLength

var touchInsideJoyStick : bool = false

var held : bool = false
var posOffset = Vector2.ZERO
var lastMousePos = Vector2.ZERO

var releaseToggle : bool = false

func _ready():
	pressed.connect(_on_pressed)
	released.connect(_on_released)
	
	radiusJoyStick = 38
	radiusJoyBase = 60
	
	maxLength = radiusJoyBase - radiusJoyStick
	doubleLength = maxLength * 2
	
	posOffset = get_parent().position + Vector2(-60,-60)
	
func _physics_process(_delta):
	if held:
		if releaseToggle:
			releaseToggle = false
		
		var relative = get_global_mouse_position() - lastMousePos
		lastMousePos = get_global_mouse_position()
		
		position.x = position.x + relative.x
		position.y = position.y + relative.y
		if position.length() > maxLength:
			var angle = position.angle()
			position.x = (cos(angle) * maxLength)
			position.y = (sin(angle) * maxLength)
		event_bus.joystickMoved.emit(position)

	else:
		position.x = 0
		position.y = 0
		lastMousePos = posOffset
		if not releaseToggle:
			releaseToggle = true
			event_bus.joystickReleased.emit()
		

func _on_pressed():
	held = true

func _on_released():
	held = false
