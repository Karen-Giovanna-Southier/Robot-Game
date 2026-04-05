extends Node

signal difficulty_increased(level: int)

@export var max_level: int = 10

var current_level: int = 0
var spawner_ref: Node = null
var stars_collected: int = 0

func _stars_needed() -> int:
	match current_level:
		0: return 5
		1: return 6
		_: return 7

func start(spawner: Node):
	spawner_ref = spawner
	current_level = 0
	stars_collected = 0
	add_to_group("difficulty")

func stop():
	pass

func on_star_collected():
	stars_collected += 1
	if stars_collected >= _stars_needed():
		stars_collected = 0
		_level_up()

func _level_up():
	if current_level >= max_level:
		return
	current_level += 1
	difficulty_increased.emit(current_level)
	if spawner_ref:
		# A partir do nível 2 spawna objeto aleatório + bomba extra
		if current_level >= 2:
			spawner_ref.call_deferred("spawn_object", spawner_ref._random_type())
			spawner_ref.call_deferred("spawn_object", "bomb")
