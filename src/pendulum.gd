extends Node2D

class_name Pendulum
# follow this video:
# https://www.youtube.com/watch?v=J1ClXGZIh00
signal start
signal on_drag(pos: Vector2)
signal be_current(pendulum: Pendulum)
signal be_eat(pendulum: Pendulum)
signal drop_card
var can_contorl: bool = false
var pivot_pos: Vector2
var end_position: Vector2
var angle: float
var prev_pos: Vector2
var is_simulating: bool = true
var is_moving: bool = false
@export var move_velocity: float = 5
@export var is_follow: bool = true

var length: float
@export var min_length: float = 400
@export var max_length: float = 1200
@export var gravity: float = 24
@export var end_point_move_multiplier: float = 5
var damping: float:
	get:
		return clamp(remap(mass, min_mass, max_mass, 0.99, 0.995), 0.995, 0.99)
@export var mass: float = 1
@export var min_mass: float = 1
@export var max_mass: float = 1000
@export var is_current: bool = false
@export var end_point_image: Texture2D
@export var max_angular_velocity: float = 0.5
@export var addition_velocity_when_collide: float = 3
@export_dir var end_point_image_path: String
@export_dir var chain_image_path: String


var end_point_images: Dictionary
var chain_images: Dictionary
var angular_velocity: float = 0.0
var angular_acceleration: float = 0.0
var cache_delta: float
var have_card: bool = false
@onready var end_point: PendulumEndPoint = get_node("PendulumEndPoint")
@onready var line: Line2D = get_node("Line2D")


func _ready() -> void:
	lazy_init_image()
	end_point.on_hit_other.connect(deal_collide)
	end_point.on_drag.connect(be_drag)
	end_point.on_drag_stop.connect(start_simulate)
	end_point.set_scale_base_mass(mass, min_mass, max_mass)
	random_select_ball_texture()
	prev_pos = global_position
	set_mass(mass)
	set_start_position(rotation)


func lazy_init_image() -> void:
	if end_point_images.is_empty() or chain_images.is_empty():
		for file_name in DirAccess.get_files_at(end_point_image_path):
			file_name = file_name.replace('.import', '')
			if file_name.get_extension() == "png":
				var texture: CompressedTexture2D = ResourceLoader.load(end_point_image_path + "/" + file_name)
				end_point_images[file_name] = texture

		for file_name in DirAccess.get_files_at(chain_image_path):
			file_name = file_name.replace('.import', '')
			if file_name.get_extension() == "png":
				var texture: CompressedTexture2D = ResourceLoader.load(chain_image_path + "/" + file_name)
				chain_images[file_name] = texture


func random_select_ball_texture() -> void:
	var end_point_image_name: String = end_point_images.keys().pick_random()
	var random_texture: CompressedTexture2D = end_point_images[end_point_image_name]
	line.texture = chain_images[chain_images.keys().pick_random()]
	if end_point_image_name.contains("glass_ball"):
		have_card = true
	end_point.set_sprite(random_texture)

func _physics_process(delta: float) -> void:
	if not is_simulating:
		return
	cache_delta = delta
	var pos_diff := global_position - prev_pos
	prev_pos = global_position
	update_position(delta, pos_diff)
	set_end_point_position(length)
	process_velocity(delta, pos_diff)


func set_start_position(init_angle: float) -> void:
	pivot_pos = global_position
	end_position = global_position + Vector2.DOWN.rotated(init_angle) * length
	end_point.global_position = end_position
	line.set_point_position(1, Vector2(0, length))
	angle = init_angle
	angular_velocity = 0
	angular_acceleration = 0
	rotation = angle


func set_end_point_position(arm_length: float) -> void:
	end_position = global_position + Vector2.DOWN.rotated(rotation) * arm_length
	end_point.global_position = end_position
	line.set_point_position(1, Vector2(0, arm_length))


func update_position(delta: float, pos_dif: Vector2) -> void:
	if is_follow:
		angular_velocity += delta * clamp(pos_dif.x, -1, 1) * delta * end_point_move_multiplier


func process_velocity(delta: float, _pivot_pos_diff: Vector2) -> void:
	angular_acceleration = (-gravity * delta) / length * sin(angle)
	angular_velocity += angular_acceleration
	angular_velocity *= damping

	angular_velocity = clamp(
		angular_velocity, -max_angular_velocity * delta, max_angular_velocity * delta
	)
	angle += angular_velocity

	rotation = angle


func add_velocity(velocity: float) -> void:
	angular_velocity += velocity * cache_delta


func set_mass(new_mass: float) -> void:
	mass = new_mass
	length = remap(mass, min_mass, max_mass, min_length, max_length)
	set_end_point_position(length)
	end_point.set_scale_base_mass(mass, min_mass, max_mass)


func deal_collide(other: Pendulum) -> void:
	if not is_current and other.is_current:
		is_current = true
		be_current.emit(self)
		return
	if not is_moving:
		var percent: float = mass / other.mass
		# u = (m_s * v_s + m_o * v_o) / (m_s + m_o)
		# https://zh.wikipedia.org/zh-tw/%E6%93%BA
		var new_velocity := (
			(mass * angular_velocity + other.mass * other.angular_velocity)
			/ (mass + other.mass)
			* percent
		)
		var dir: int = 1 if new_velocity > 0 else -1

		var addi : float = remap(percent, 1, 7, addition_velocity_when_collide, 0)

		other.add_velocity(new_velocity + dir * addi)

		other.set_mass(mass + other.mass/2)
		if not other.is_current:
			be_eat.emit(self)
		if have_card:
			drop_card.emit()
		queue_free()


func be_drag() -> void:
	if not is_current or not can_contorl:
		return
	is_simulating = true
	var dir_to_mouse := (get_global_mouse_position() - pivot_pos).normalized()
	var mouse_angle := -dir_to_mouse.angle_to(Vector2.DOWN)
	on_drag.emit(get_global_mouse_position())
	set_start_position(mouse_angle)


func start_simulate() -> void:
	if is_current and can_contorl:
		set_end_point_position(length)
		start.emit()
