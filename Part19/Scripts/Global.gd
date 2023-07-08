### Global.gd

extends Node

#movement states
var is_attacking = false
var is_climbing = false
var is_jumping = false

# Indicates if box can be spawned
var can_spawn = true

#current scene
var current_scene_name

#bomb movement state
var is_bomb_moving = false

#pickups
enum Pickups {HEALTH, SCORE, ATTACK}

#can the player be damaged?
var can_hurt = true

#final level results
var final_score
var final_rating
var final_time

func _ready():
	# Sets the current scene's name
	current_scene_name = get_tree().get_current_scene().name

# Function to disable box spawning
func disable_spawning():
	can_spawn = false

# Function to enable box spawning
func enable_spawning():
	can_spawn = true

# Current level based on scene name
func get_current_level_number():
	if current_scene_name == "Main":
		return 1
	elif current_scene_name.begins_with("Main_"):
		# Extract the number after "Main_"
		var level_number = current_scene_name.get_slice("_", 1).to_int()
		return level_number
	else:
		return -1 # Indicate an unknown scene


