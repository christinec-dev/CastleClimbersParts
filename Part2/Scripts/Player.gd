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
    
func horizontal_movement():
    # if keys are pressed it will return 1 for ui_right, -1 for ui_left, and 0 for neither
    var horizontal_input = Input.get_action_strength("ui_right") -  Input.get_action_strength("ui_left")
    # horizontal velocity which moves player left or right based on input
    velocity.x = horizontal_input * speed
