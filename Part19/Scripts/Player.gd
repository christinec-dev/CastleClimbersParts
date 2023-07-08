### Player.gd

extends CharacterBody2D

#player movement variables
@export var speed = 100
@export var gravity = 200
@export var jump_height = -110

# Keep track of the last direction (1 for right, -1 for left, 0 for none)
var last_direction = 0
# Check the direction of the player's movement
var current_direction = 0

#custom signals
signal update_lives(lives, max_lives)
signal update_attack_boost(attack_time_left)
signal update_score(score)

#health stats
var max_lives = 3
var lives = 3
var is_hurt = false

#seconds allowed to attack
var attack_time_left = 0

#score stats
var score = 0

#time we started the level
var level_start_time = Time.get_ticks_msec()

#level value
@onready var level = $UI/Level/Value

func _ready():
	current_direction = -1
	#set our attack timer to be the value of our wait_time
	attack_time_left =	$AttackBoostTimer.wait_time
	
	#updates our UI labels when signals are emitted
	update_lives.connect($UI/Health.update_lives)
	update_attack_boost.connect($UI/Attack.update_attack_boost)
	update_score.connect($UI/Score.update_score)
	
	#show our correct lives value on load
	$UI/Health/Label.text = str(lives)
	
	update_level_label()
	
#movement and physics
func _physics_process(delta):
	# vertical movement velocity (down)
	velocity.y += gravity * delta
	# horizontal movement processing (left, right)
	horizontal_movement()
	
	#applies movement
	move_and_slide() 
	
	#applies animations
	if Global.is_climbing == false:
		player_animations()
	
	#countdown for attack boost
	if Global.is_attacking == true:
		attack_time_left = max(0, attack_time_left - 1)
		update_attack_boost.emit(attack_time_left)
		
		if Input.is_action_pressed("ui_attack"):
			#gets the colliders of our raycast
			var target = $AttackRayCast.get_collider()
			#is target valid
			if target != null:
				#remove box
				if target.name == "Box":
					Global.disable_spawning()
					target.queue_free()
					increase_score(10)
				#remove bomb
				if target.name == "Bomb":				
					Global.is_bomb_moving = false	
					increase_score(10)					
			Global.can_hurt = false
		else:
			Global.can_hurt = true
	
	#score boost
	if Input.is_action_pressed("ui_jump"):
		# Get the colliders of our raycast
		var target = $ScoreRayCast.get_collider()

		# Check if target is valid and player is not damaged
		if target != null:
			if target.name == "Box" or target.name == "Bomb":
				if is_hurt == false:
					increase_score(1)
				
#horizontal movement calculation
func horizontal_movement():
	# if keys are pressed it will return 1 for ui_right, -1 for ui_left, and 0 for neither
	var horizontal_input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	# horizontal velocity which moves player left or right based on input
	velocity.x = horizontal_input * speed

#animations
func player_animations():
	#on left  and we aren't hurt
	if Input.is_action_pressed("ui_left") && Global.is_jumping == false:
		$AnimatedSprite2D.flip_h = true
		$AnimatedSprite2D.play("run")
		$CollisionShape2D.position.x = 7
		$ScoreRayCast.position.x = 5
	#on right and we aren't hurt
	if Input.is_action_pressed("ui_right") && Global.is_jumping == false:
		$AnimatedSprite2D.flip_h = false
		$AnimatedSprite2D.play("run")
		$CollisionShape2D.position.x = -7
		$ScoreRayCast.position.x = -5
				
	#on idle if nothing is being pressed and we aren't hurt
	if !Input.is_anything_pressed():
		$AnimatedSprite2D.play("idle")

#singular input captures
func _input(event):
	#pause game
	if event.is_action_pressed("ui_pause"):
		#pause scene
		get_tree().paused = true
		#show menu
		$PauseMenu.visible = true
		
	#on attack
	if Input.is_action_just_pressed("ui_attack"):
		if Global.is_attacking == true:
			$AnimatedSprite2D.play("attack")
	
	#on jump
	if event.is_action_pressed("ui_jump") and is_on_floor():
		velocity.y = jump_height
		$AnimatedSprite2D.play("jump")
				
	#on climbing ladders
	if Global.is_climbing == true:
		if Input.is_action_pressed("ui_up"):
			$AnimatedSprite2D.play("climb")	
			gravity = 100
			velocity.y = -160
			Global.is_jumping = true
			
	#reset gravity
	else:
		gravity = 200
		Global.is_climbing = false	
		Global.is_jumping = false
				
#reset our animation variables
func _on_animated_sprite_2d_animation_finished():
	if attack_time_left <= 0:
		Global.is_attacking = false
	set_physics_process(true)
	is_hurt = false
	
	if $AnimatedSprite2D.animation == "death":
		# pause game
		get_tree().paused = true
		# show menu
		$GameOver/Menu.visible = true
		# make modular value visible
		$AnimationPlayer.play("ui_visibility")	
		#hide the player's UI 
		$UI.visible = false
		#get final values
		final_score_time_and_rating()
		# show player values
		$GameOver/Menu/Container/TimeCompleted/Value.text = str(Global.final_time)
		$GameOver/Menu/Container/Score/Value.text = str(Global.final_score)
		$GameOver/Menu/Container/Ranking/Value.text = str(Global.final_rating)
	
		
func _process(delta):
	if velocity.x > 0: # Moving right
		current_direction = 1
	elif velocity.x < 0: # Moving left
		current_direction = -1
	
	# If the direction has changed, play the appropriate animation
	if current_direction != last_direction:
		if current_direction == 1:
			#limits
			$Camera2D.limit_left = -110
			$Camera2D.limit_bottom = 705
			$Camera2D.limit_top = 40
			$Camera2D.limit_right = 1068
			
			# Play the right animation
			$AnimationPlayer.play("move_right")
			
			# Set raycast direction to right
			$AttackRayCast.target_position.x = 50
				
		elif current_direction == -1:
				
			#limits
			$Camera2D.limit_left = 90
			$Camera2D.limit_bottom = 705
			$Camera2D.limit_top = 40
			$Camera2D.limit_right = 1268
			
			# Play the left animation
			$AnimationPlayer.play("move_left")
			
			# Set raycast direction to left
			$AttackRayCast.target_position.x = -50
			
		# Update the last_direction variable
		last_direction = current_direction

	# Update the time label
	update_time_label()
	
# takes damage & death
func take_damage():
	#deduct and update lives    
	if lives > 0 and Global.can_hurt == true:
		lives = lives - 1
		update_lives.emit(lives, max_lives)
		#play damage animation
		$AnimatedSprite2D.play("damage")
		#allows animation to play
		set_physics_process(false)
		is_hurt = true
		#decrease score
		decrease_score(10)
	
	if lives <= 0:
		$AnimatedSprite2D.play("death")
		
#adds pickups to our player and updates our lives/attack boosts
func add_pickup(pickup):
	#increases life count if we don't have 3 lives already
	if pickup == Global.Pickups.HEALTH:
		if lives < max_lives:
			lives += 1
			update_lives.emit(lives, max_lives)
			
	#temporarily allows us to destroy boxes/bombs
	if pickup == Global.Pickups.ATTACK:
		Global.is_attacking = true
		
	#increases our player's score
	if pickup == Global.Pickups.SCORE:
		increase_score(1000)

#attack boost timer timeout (when it reaches 0)
func _on_attack_boost_timer_timeout():
	#sets attack back to false if the time on boost runs out
	if attack_time_left <= 0:
		Global.is_attacking = false
		Global.can_hurt = true

#increases our score
func increase_score(score_count):
	score += score_count
	update_score.emit(score)

#decreases our score
func decrease_score(score_count):
	if score >= score_count:
		score -= score_count
		update_score.emit(score)

func final_score_time_and_rating():
	# Time to complete in seconds
	var time_taken = (Time.get_ticks_msec() - level_start_time) / 1000.0 # Convert to seconds
	var time_rounded = str(roundf(time_taken)) + " secs"
	# Rating based on time and score
	var rating = ""
	
	if time_taken <= 60 and score >= 10000:
		rating = "Master" # Exceptionally high score and fast completion
	elif time_taken <= 120 and score >= 5000:
		rating = "Pro" # Very high score and fast completion
	elif time_taken <= 180 and score >= 3000:
		rating = "Expert" # High score and moderately fast completion
	elif time_taken <= 240 and score >= 2000:
		rating = "Intermediate" # Good score and completion time
	elif time_taken <= 300 and score >= 1000:
		rating = "Amateur" # Decent score, but not very fast
	else:
		rating = "Beginner" # All other cases
	
	# Final results
	Global.final_score = score
	Global.final_time = time_rounded
	Global.final_rating = rating

# Update the time display label every second since the game started
func update_time_label():
	var time_passed = (Time.get_ticks_msec() - level_start_time) / 1000.0 # in seconds
	$UI/Time/Label.text = str(round(time_passed)) + "s"

# Update the level label to display the current level
func update_level_label():
	var current_level = Global.get_current_level_number()
	if current_level != -1:
		level.text = " " + str(current_level)
	else:
		level.text = "err!"

#restarts game
func _on_restart_button_pressed():
	#unpause scene
	get_tree().paused = false
	#hide menu
	$GameOver/Menu.visible = false
	# Restart current scene
	get_tree().reload_current_scene()

#resume game
func _on_button_resume_pressed():
	#unpause scene
	get_tree().paused = false
	#hide menu
	$PauseMenu.visible = false

#quit to main menu	
func _on_button_quit_pressed():
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

func _on_button_load_pressed():
	pass

func _on_button_save_pressed():
	pass

