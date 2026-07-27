extends Control

func _ready():
	event_bus.updateUI.connect(updateUI)

func updateUI():
	$HBoxContainer/LevelText.text = "Level: " + str(global.level)
	$HBoxContainer/LivesText.text = "Lives: " + str(global.lives)
	$HBoxContainer/ScoreText.text = "Score: " + str(global.score)
