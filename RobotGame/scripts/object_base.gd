extends Area2D

var object_type: String = "star"
var points: int = 0

const TIMED_DURATION = {
	"star":   12.0,
	"ice":     8.0,
	"fire":    8.0,
	"wind":    8.0,
	"mud":     8.0,
}

const MAP_LEFT   = 80.0
const MAP_RIGHT  = 1200.0
const MAP_TOP    = 60.0
const MAP_BOTTOM = 550.0

func _ready():
	if has_meta("object_type"):
		object_type = get_meta("object_type")

	# Pontuação
	match object_type:
		"star":   points = 1
		"magnet": points = 2
		_:        points = 0

	collision_layer = 2
	collision_mask  = 1
	monitoring  = true
	monitorable = true
	body_entered.connect(_on_body_entered)

	# Timer para sumir
	if TIMED_DURATION.has(object_type):
		var t = Timer.new()
		t.wait_time = TIMED_DURATION[object_type]
		t.one_shot = true
		t.timeout.connect(_on_expire)
		add_child(t)
		t.start()

	# Bomba troca de lugar
	if object_type == "bomb":
		var t = Timer.new()
		t.one_shot = false
		t.timeout.connect(_on_bomb_move)
		add_child(t)
		t.wait_time = _get_bomb_interval()
		t.start()

func _get_bomb_interval() -> float:
	var dt = get_tree().get_first_node_in_group("difficulty")
	var level = dt.current_level if dt else 0
	return max(4.0, 15.0 - level * 1.1)

func _on_expire():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(queue_free)

func _on_bomb_move():
	var t = get_node_or_null("Timer")
	if t:
		t.wait_time = _get_bomb_interval()
	var ball = get_tree().get_first_node_in_group("ball")
	var attempts = 30
	while attempts > 0:
		var x = randf_range(MAP_LEFT, MAP_RIGHT)
		var y = randf_range(MAP_TOP, MAP_BOTTOM)
		var new_pos = Vector2(x, y)
		if ball == null or new_pos.distance_to(ball.global_position) > 150.0:
			var tween = create_tween()
			tween.tween_property(self, "modulate:a", 0.0, 0.2)
			tween.tween_callback(func(): global_position = new_pos)
			tween.tween_property(self, "modulate:a", 1.0, 0.2)
			return
		attempts -= 1

func _on_body_entered(body):
	if body.is_in_group("ball"):
		set_deferred("monitoring", false)
		if body.has_method("apply_effect"):
			body.apply_effect(object_type)
		get_tree().call_group("main", "on_object_collected", object_type, points, global_position)
		call_deferred("queue_free")
