### Box.gd 

extends Area2D

#default animation on spawn
func _ready():
	$AnimatedSprite2D.play("moving")
	
func _on_body_entered(body):
	#if the bomb collides with the player, play the explosion animation and start the timer
	if body.name == "Player":
		$AnimatedSprite2D.play("explode")
		$Timer.start()
		Global.is_box_moving = false

	#if the bomb collides with our Wall scene, explode and remove
	if body.name.begins_with("Wall"):
		$AnimatedSprite2D.play("explode")
		$Timer.start()
		Global.is_box_moving = false

#remove the bomb from the scene only if the Bomb exists
func _on_timer_timeout():
	if is_instance_valid(self):
		self.queue_free()

