extends Control

func _ready():
	event_bus.updateUI.connect(updateUI)

func updateUI():
	$HBoxContainer/VBoxContainer/LevelText.text = "Level: " + str(global.level)
	$HBoxContainer/LivesText.text = "Lives: " + str(global.lives)
	$HBoxContainer/VBoxContainer/ScoreText.text = "Score: " + str(global.score)
