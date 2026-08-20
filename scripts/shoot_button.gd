extends TouchScreenButton

func _ready():
	pressed.connect(_on_press)
	
func _on_press():
	event_bus.mobileShoot.emit()
