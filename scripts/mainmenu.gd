extends Node2D

### Audio ###
var buttonSound = preload("res://audio/Button.wav")

func _ready():
	save_load.load_data()
	
	$CanvasLayer/UI/LevelText.text = "[center]Level:\n" + str(global.bestLevel)
	$CanvasLayer/UI/ScoreText.text = "[center]Score:\n" + str(global.bestScore)
	
	$CanvasLayer/UI/TextureButton.pressed.connect(startGame)
	
func startGame():
	AudioManager.play_sfx(buttonSound)
	
	global.score = 0
	global.level = 1
	global.lives = 3
	
	get_tree().change_scene_to_file("res://scenes/level.tscn")
