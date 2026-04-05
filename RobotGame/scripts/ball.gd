extends CharacterBody2D

const BASE_SPEED = 300.0

const MAP_LEFT   = 40.0
const MAP_RIGHT  = 1240.0
const MAP_TOP    = 40.0
const MAP_BOTTOM = 570.0

var speed = BASE_SPEED
var speed_timer: Timer = null

@onready var sprite = $Sprite2D

func _ready():
	add_to_group("ball")
	collision_layer = 1
	collision_mask  = 1

	speed_timer = Timer.new()
	speed_timer.one_shot = true
	speed_timer.timeout.connect(_on_speed_timer_timeout)
	add_child(speed_timer)

func _physics_process(delta):
	var direction = Vector2.ZERO

	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1

	if direction != Vector2.ZERO:
		direction = direction.normalized()

	velocity = direction * speed
	move_and_collide(velocity * delta)

	position.x = clamp(position.x, MAP_LEFT, MAP_RIGHT)
	position.y = clamp(position.y, MAP_TOP, MAP_BOTTOM)

func apply_effect(effect: String):
	match effect:
		"ice":
			_set_speed(BASE_SPEED * 0.4, 4.0)
			sprite.modulate = Color(0.5, 0.8, 1.0)
		"fire":
			_set_speed(BASE_SPEED * 2.0, 4.0)
			sprite.modulate = Color(1.0, 0.4, 0.1)
		"mud":
			_set_speed(BASE_SPEED * 0.2, 5.0)
			sprite.modulate = Color(0.5, 0.35, 0.1)
		"wind":
			_set_speed(BASE_SPEED * 1.5, 3.0)
			sprite.modulate = Color(0.8, 1.0, 0.8)
		"magnet":
			sprite.modulate = Color(0.8, 0.3, 1.0)
			speed_timer.start(3.0)
		"bomb":
			pass

func _set_speed(new_speed: float, duration: float):
	speed = new_speed
	speed_timer.start(duration)

func _on_speed_timer_timeout():
	speed = BASE_SPEED
	sprite.modulate = Color(1, 1, 1)
