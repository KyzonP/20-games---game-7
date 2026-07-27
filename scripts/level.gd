extends Node2D

# So, for this it'll have code to check the enemy count when prompted (if an enemy is defeated)
# if one remains, emit the flee signal - if none, then do the end of level
# also maybe check the y pos and give score accordingly at this stage

#232 is roughly centre X position
#280 is y position

var player : Area2D
var horizontalTween
var verticalTween

var levelEnded : bool = false

func _ready():
	event_bus.enemyDefeated.connect(checkEnemies)
	event_bus.enemyFled.connect(endLevel)
	event_bus.playerDefeated.connect(playerDefeated)
	
	player = get_tree().get_nodes_in_group("Player")[0]
	
	horizontalMove()
	event_bus.emit_signal("updateUI")
	
func horizontalMove():
	if horizontalTween:
		horizontalTween.kill()
	
	horizontalTween = create_tween()
	horizontalTween.tween_property(player, "position", Vector2(232, player.global_position.y), player.global_position.distance_to(Vector2(232, self.global_position.y))/player.speed)
	horizontalTween.finished.connect(verticalMove)
	
func verticalMove():
	if verticalTween:
		verticalTween.kill()
	
	verticalTween = create_tween()
	verticalTween.tween_property(player, "position", Vector2(player.global_position.x, 280), player.global_position.distance_to(Vector2(player.global_position.x, 280))/player.speed)
	verticalTween.finished.connect(startLevel)
	
func startLevel():
	event_bus.emit_signal("startLevel")
	
func checkEnemies(yPos):
	print(yPos)
	if yPos > 392:
		adjustScore(40)
	elif yPos > 280:
		adjustScore(30)
	elif yPos > 168:
		adjustScore(20)
	else:
		adjustScore(10)
	
	var enemyCount = get_tree().get_nodes_in_group("Enemy").size()-1
	if enemyCount == 1:
		event_bus.emit_signal("flee")
	elif enemyCount <= 0:
		endLevel()
		
func adjustScore(amount):
	global.score += amount
	event_bus.emit_signal("updateUI")
	
func playerDefeated():
	if not levelEnded:
		levelEnded = true
		global.lives = global.lives - 1
		if global.lives == 0:
			gameOver()
		else:
			restartLevel()
	
func restartLevel():
	get_tree().reload_current_scene.call_deferred()
		
func endLevel():
	if not levelEnded:
		levelEnded = true
		global.level = global.level + 1
		restartLevel()
		
func gameOver():
	pass
