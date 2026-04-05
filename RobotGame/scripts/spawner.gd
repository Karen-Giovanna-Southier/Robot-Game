extends Node2D

@export var min_distance_from_ball: float = 200.0
@export var min_distance_between_objects: float = 80.0

const MAP_LEFT   = 80.0
const MAP_RIGHT  = 1200.0
const MAP_TOP    = 60.0
const MAP_BOTTOM = 550.0

const TYPE_TO_IMAGE = {
	"star":   "res://images/star.png",
	"bomb":   "res://images/bomb.png",
	"ice":    "res://images/ice.png",
	"fire":   "res://images/ember.png",
	"mud":    "res://images/heavy.png",
	"wind":   "res://images/light.png",
	"magnet": "res://images/power.png",
}

var ball_ref: Node2D = null

func _ready():
	ball_ref = get_tree().get_first_node_in_group("ball")

# Spawn inicial: só estrela e bomba
func spawn_initial():
	spawn_object("star")
	spawn_object("bomb")

func spawn_object(type: String):
	var pos = _find_valid_position()
	if pos == Vector2.ZERO:
		return
	var obj = _create_object(type, pos)
	add_child(obj)

func _find_valid_position() -> Vector2:
	# Usa posições dos objetos VIVOS para evitar sobreposição
	var live_positions: Array = []
	for obj in get_tree().get_nodes_in_group("objects"):
		live_positions.append(obj.global_position)

	var attempts = 50
	while attempts > 0:
		var x = randf_range(MAP_LEFT, MAP_RIGHT)
		var y = randf_range(MAP_TOP, MAP_BOTTOM)
		var pos = Vector2(x, y)

		if ball_ref and pos.distance_to(ball_ref.global_position) < min_distance_from_ball:
			attempts -= 1
			continue

		var too_close = false
		for existing_pos in live_positions:
			if pos.distance_to(existing_pos) < min_distance_between_objects:
				too_close = true
				break

		if not too_close:
			return pos
		attempts -= 1

	return Vector2.ZERO

func _create_object(type: String, pos: Vector2) -> Node:
	var obj = Area2D.new()
	obj.add_to_group("objects")
	obj.collision_layer = 2
	obj.collision_mask  = 1
	obj.monitoring  = true
	obj.monitorable = true

	var spr = Sprite2D.new()
	spr.name = "Sprite2D"
	if TYPE_TO_IMAGE.has(type):
		var tex = load(TYPE_TO_IMAGE[type])
		if tex:
			spr.texture = tex
			spr.scale = Vector2(0.25, 0.25)
	obj.add_child(spr)

	var col = CollisionShape2D.new()
	col.name = "CollisionShape2D"
	var shape = CircleShape2D.new()
	shape.radius = 24.0
	col.shape = shape
	obj.add_child(col)

	obj.set_meta("object_type", type)

	var script = load("res://scripts/object_base.gd")
	obj.set_script(script)

	obj.global_position = pos
	return obj

func _random_type() -> String:
	var types = ["ice", "fire", "mud", "wind", "magnet"]
	return types[randi() % types.size()]
