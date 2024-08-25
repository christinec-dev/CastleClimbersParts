### Time.gd

extends ColorRect

#ref to our label node
@onready var label = $Label

# updates label text when signal is emitted
func update_time(time_passed):
	label.text = str(time_passed)
