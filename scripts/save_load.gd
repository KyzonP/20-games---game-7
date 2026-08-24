extends Node
		
##### SAVE FUNCTIONS #####
func save():
	var save_dict = {
		"bestScore": global.bestScore,
		"bestLevel": global.bestLevel
	}
	print(save_dict)
	return save_dict
	
func save_game():
	print("saving")
	var save_data= FileAccess.open("user://Kobold.save", FileAccess.WRITE)
	
	var json_string = JSON.stringify(save())
	
	save_data.store_line(json_string)
	
func load_data():
	if not FileAccess.file_exists("user://Kobold.save"):
		return
	
	var save_data = FileAccess.open("user://Kobold.save", FileAccess.READ)

	while save_data.get_position() < save_data.get_length():
		var json_string = save_data.get_line()
		var json=JSON.new()
		var _parse_result = json.parse(json_string)
		var node_data = json.get_data()
		
		print(node_data)
		
		for i in node_data.keys():
			if i=="bestScore":
				global.bestScore = node_data[i]
			elif i == "bestLevel":
				global.bestLevel = node_data[i]
