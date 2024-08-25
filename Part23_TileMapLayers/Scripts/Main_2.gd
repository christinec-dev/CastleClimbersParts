extends Node2D

var rng  = RandomNumberGenerator.new()

func _process(delta):
	var layer = $Level.get_used_cells(2)
	print(rng.randi() % layer)
