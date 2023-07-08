### BoxSpawner.gd

extends Node2D

#Box scene reference
var box = preload("res://Scenes/Box.tscn")

#references to our scene, PathFollow2D path, and AnimationPlayer path
var box_path
var box_animation

#allows us to flip our pigs around in the editor
@export var flip_h = false
@export var flip_v = false

# unique identifier for the spawner
var spawner_id

#when it's loaded into the scene
func _ready():
	#default animation on load
	$AnimatedSprite2D.play("pig_throw")   
	#initiates paths
	box_path = $BoxPath/Path2D/PathFollow2D
	box_animation = $BoxPath/Path2D/AnimationPlayer
	box_animation.play("box_movement")	
	
	spawner_id = get_instance_id()
	
func _process(delta):
	if flip_h == true:
		$AnimatedSprite2D.flip_h = true
	if flip_v == true:
		$AnimatedSprite2D.flip_v = true
	
#spawns box instance    
func spawn_box():
	var spawned_box = box.instantiate()
	
	# set the spawner_id on the spawned box
	spawned_box.spawner_id = spawner_id
	
	Global.is_box_moving = true
	return spawned_box

#shoot and spawn box onto path
func _on_timer_timeout():
	#if not throwing box, revert to idle anims
	$AnimatedSprite2D.play("pig_idle")
	
	#if it has 0 or less, spawn. Eliminates duplicates
	if box_path.get_child_count() <= 0:
		box_path.add_child(spawn_box())
	
	#if it's reached the end of the path, respawn	
	if box_path.progress_ratio == 1 || Global.is_box_moving == false:
		var boxes = box_path.get_children()
		#clear all boxes
		for box in boxes:
			box.queue_free()
			
		#reset the throw box animation
		box_animation.stop()
		box_path.progress_ratio == 0
		box_animation.play("box_movement")
		
		#play throwing animation
		$AnimatedSprite2D.play("pig_throw")
		return
		
