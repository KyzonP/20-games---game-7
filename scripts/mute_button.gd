extends TextureButton

### Audio ###
var buttonSound = preload("res://audio/Button.wav")

func _ready():
	pressed.connect(_mutePressed)
	
func _mutePressed():
	AudioManager.play_sfx(buttonSound)
	event_bus.emit_signal("toggleMute")
