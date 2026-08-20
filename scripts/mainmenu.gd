extends Node2D

func _ready():
	checkScore()
	
	save_load.load_data()
	
	$CanvasLayer/UI/LevelText.text = "[center]Level:\n" + str(global.bestLevel)
	$CanvasLayer/UI/ScoreText.text = "[center]Score:\n" + str(global.bestScore)
	
	$CanvasLayer/UI/TextureButton.pressed.connect(startGame)

func checkScore():
	if global.score > global.bestScore:
		global.bestScore = global.score
		
		
	elif global.level > global.bestLevel:
		global.bestLevel = global.level
	
	global.score = 0
	global.level = 1
	
	save_load.save_game()
	
func startGame():
	get_tree().change_scene_to_file("res://scenes/level.tscn")
