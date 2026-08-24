extends TextureButton

### Audio ###
var buttonSound = preload("res://audio/Button.wav")

func _ready():
	pressed.connect(_pausePressed)
	
func _pausePressed():
	print("pressed")
	#AudioManager.play_sfx(buttonSound)
	event_bus.emit_signal("togglePause")
