extends Button

class_name ChooseBox

signal on_choose

# Called when the node enters the scene tree for the first time.
func _ready():
	self.button_up.connect(on_choose.emit)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
