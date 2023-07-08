### Global.gd

extends Node

#movement states
var is_attacking = false
var is_climbing = false
var is_jumping = false

#current scene
var current_scene_name

#bomb movement state
var is_bomb_moving = false

func _ready():
	# Sets the current scene's name
	current_scene_name = get_tree().get_current_scene().name
	
