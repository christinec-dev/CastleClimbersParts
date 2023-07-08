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

func _ready():
	# Sets the current scene's name
	current_scene_name = get_tree().get_current_scene().name
	
# Function to disable box spawning
func disable_spawning():
	can_spawn = false

# Function to enable box spawning
func enable_spawning():
	can_spawn = true
