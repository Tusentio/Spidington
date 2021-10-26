extends Resource
class_name PlayerData

const save_path := "user://save.res"

export (bool) var saved := false
export (Vector2) var global_position: Vector2
export (float) var rotation: float
export (Vector2) var linear_velocity: Vector2
export (float) var angular_velocity: float


func save(path = save_path):
	ResourceSaver.save(path, self, ResourceSaver.FLAG_COMPRESS)


static func read(path = save_path):
	if File.new().file_exists(path):
		return ResourceLoader.load(path, "", true)
	else:
		return load("res://Scenes/Player/PlayerData.gd").new()
