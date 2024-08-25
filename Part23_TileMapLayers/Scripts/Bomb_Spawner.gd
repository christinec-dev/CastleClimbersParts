extends Node2D

var bomb = preload("res://Scenes/Bomb.tscn")

var current_scene_path
var bomb_path
var bomb_animation

#when it's loaded into the scene
func _ready():
	#flip the animation to be turned left
	$AnimatedSprite2D.flip_h = true
	#initiates path
	current_scene_path = "/root/" + str(Global,name)
	bomb_path = get_node(current_scene_path + "/BombPath/Path2D/PathFollow2D")
	bomb_animation = get_node(current_scene_path + "/BombPath/Path2D/AnimationPlayer")
	
#spawns bomb instance    
func shoot():
	var spawned_bomb = bomb.instantiate()#play cannon shoot animation on start
	$AnimatedSprite2D.play("default")
	return spawned_bomb

#shoot and spawn bomb onto path
func _on_timer_timeout():
	#if it has 0 or less, spawn. Eliminates duplicates
	if bomb_path.get_child_count() <= 0:
		bomb_path.add_child(shoot())
		

# called every physics frame
func _physics_process(delta):
	# Check if the bomb has reached the end of the path and should be respawned
	if bomb_path.get_child_count() > 0 and bomb_path.progress_ratio == 1:
		#clear all bombs
		for bombs in bomb_path.get_children():
			bomb_path.remove_child(bombs)
			bombs.queue_free()

		#reset the cannon animation
		bomb_path.progress_ratio = 0

		# spawn a new bomb immediately
		bomb_path.add_child(shoot())
		bomb_animation.play("bomb_movement")
