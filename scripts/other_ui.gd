extends CanvasLayer

var projectileTween

func _ready():
	event_bus.shotFired.connect(fireProjectile)
	event_bus.shotReady.connect(reloadProjectile)
	
func fireProjectile():
	if projectileTween:
		projectileTween.kill()
	
	projectileTween = create_tween()
	#424, 552
	projectileTween.tween_property($Sprite2D, "position", Vector2(472, 552), 0.2)
	
func reloadProjectile():
	if projectileTween:
		projectileTween.kill()
	
	projectileTween = create_tween()
	#424, 552
	projectileTween.tween_property($Sprite2D, "position", Vector2(424, 552), 0.2)

	
