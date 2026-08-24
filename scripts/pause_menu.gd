extends CanvasLayer

### Audio ###
var buttonSound = preload("res://audio/Button.wav")

func _ready():
	hide() #Hide pause menu
	$Button.pressed.connect(toggle_pause)
	
	event_bus.togglePause.connect(toggle_pause)
	
func _input(event):
	if event.is_action_pressed("pause"):
		toggle_pause()
	
func toggle_pause():
	AudioManager.play_sfx(buttonSound)
	get_tree().paused = not get_tree().paused
	visible = get_tree().paused
	
	print("pause")
