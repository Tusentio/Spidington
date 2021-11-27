extends Resource
class_name PlayerData

const save_path := "user://save.res"

export (String) var uid := generate_uid()

export (bool) var saved := false
export (Vector2) var global_position: Vector2
export (float) var rotation: float
export (Vector2) var linear_velocity: Vector2
export (float) var angular_velocity: float

export (int) var time_major: int
export (float) var time_minor: float


func save(path = save_path):
	ResourceSaver.save(path, self, ResourceSaver.FLAG_COMPRESS)


static func read(path = save_path):
	if File.new().file_exists(path):
		return ResourceLoader.load(path, "", true)
	else:
		return load("res://Scenes/Player/PlayerData.gd").new()


static func reset(path = save_path):
	var old_data = read(path)
	if old_data.saved:
		var new_data = load("res://Scenes/Player/PlayerData.gd").new()
		new_data.uid = old_data.uid
		new_data.save()


static func generate_uid() -> String:
	var nonce := ""
	for i in 10:
		nonce += String(randi())
	return nonce.sha256_text()
