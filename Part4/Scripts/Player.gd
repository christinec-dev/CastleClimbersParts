### Player.gd

extends CharacterBody2D

#player movement variables
@export var speed = 100
@export var gravity = 200

#movement and physics
func _physics_process(delta):
	# vertical movement velocity (down)
	velocity.y += gravity * delta
	# horizontal movement processing (left, right)
	horizontal_movement()
	
	#applies movement
	move_and_slide() 
	
	#applies animations
	if !Global.is_attacking and !Global.is_climbing:
		player_animations()

func horizontal_movement():
	# if keys are pressed it will return 1 for ui_right, -1 for ui_left, and 0 for neither
	var horizontal_input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	# horizontal velocity which moves player left or right based on input
	velocity.x = horizontal_input * speed

#animations
func player_animations():
    #on left (add is_action_just_released so you continue running after jumping)
    if Input.is_action_pressed("ui_left") || Input.is_action_just_released("ui_jump"):
        $AnimatedSprite2D.flip_h = true
        $AnimatedSprite2D.play("run")
        $CollisionShape2D.position.x = 7
        
    #on right (add is_action_just_released so you continue running after jumping)
    if Input.is_action_pressed("ui_right") || Input.is_action_just_released("ui_jump"):
        $AnimatedSprite2D.flip_h = false
        $AnimatedSprite2D.play("run")
        $CollisionShape2D.position.x = -7
    
    #on idle if nothing is being pressed
    if !Input.is_anything_pressed():
        $AnimatedSprite2D.play("idle")
