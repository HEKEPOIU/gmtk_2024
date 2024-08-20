extends Node

class_name GameManarger

signal on_start
signal on_end
@onready var canvas := get_node("CanvasLayer/Canvas") as UiMain
@onready var camera: CameraManager = get_node("Camera2D")
@onready var pendulum_manager: PendulumManager = get_node("PendulumManager")
@onready var audio_manager: AudioManager = get_node("AudioManager")
@onready var end_timer: Timer = get_node("EndTimr")
var is_start_swing: bool = false

@export var inverse_speed_card: Resource = preload("res://src/ui/card/card_effect/inverse_speed_card.gd")
@export var add_speed_card: Resource = preload("res://src/ui/card/card_effect/add_speed_card.gd")
@export var double_speed_card: Resource = preload("res://src/ui/card/card_effect/double_speed_card.gd")

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pendulum_manager.on_change_pendulum.connect(camera.deal_follow)
	pendulum_manager.release_pendulum.connect(start_game)
	pendulum_manager.collide.connect(audio_manager.play_collide)
	pendulum_manager.init_pendulums()
	end_timer.timeout.connect(end_geme)

	canvas.on_card_click.connect((func() -> void: canvas.show_border(pendulum_manager.get_all_pendulum(), Vector2(1, 1))))
	on_start.connect(func() -> void:
		print('print list')
		canvas.refresh_card_state([add_speed_card.new(), inverse_speed_card.new(), add_speed_card.new(), add_speed_card.new(), add_speed_card.new(), add_speed_card.new(), add_speed_card.new()]))

	pendulum_manager.drop_card.connect(func() -> void:
		var my_random_number = int(rng.randf_range(0, 10.0)) % 3
		if my_random_number == 0:
			canvas.add_card(add_speed_card.new())
		elif my_random_number == 1:
			canvas.add_card(double_speed_card.new())
		else:
			canvas.add_card(inverse_speed_card.new())

	)

func start_game() -> void:
	if is_start_swing:
		return
	is_start_swing = true
	end_timer.start()
	on_start.emit()

func end_geme() -> void:
	on_end.emit()
