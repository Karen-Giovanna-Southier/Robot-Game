extends Node2D

@onready var spawner         = $Spawner
@onready var difficulty      = $DifficultyTimer
@onready var score_label     = $UI/ScoreLabel
@onready var level_label     = $UI/LevelLabel
@onready var game_over_panel = $UI/GameOverPanel
@onready var score_final     = $UI/GameOverPanel/ScoreFinalLabel
@onready var ball            = $Ball

var score: int = 0
var is_game_over: bool = false

const MAX_STARS = 3

func _ready():
	add_to_group("main")
	game_over_panel.hide()

	await get_tree().create_timer(0.5).timeout
	spawner.spawn_initial()

	difficulty.start(spawner)
	difficulty.difficulty_increased.connect(_on_difficulty_increased)
	_update_ui()

func on_object_collected(type: String, points: int, _pos: Vector2):
	if is_game_over:
		return

	if type == "bomb":
		_trigger_game_over()
		return

	score += points
	score = max(score, 0)
	_update_ui()

	match type:
		"ice":  _play_sfx("res://sounds/ice.wav")
		"fire": _play_sfx("res://sounds/fire.wav")
		_:      _play_sfx("res://sounds/collect.wav")

	# Só estrela duplica (máx 3)
	if type == "star":
		difficulty.on_star_collected()
		# Aguarda 1 frame extra para o objeto coletado sair da cena antes de checar posições
		await get_tree().process_frame
		await get_tree().process_frame
		var count = _count_type("star")
		if count < MAX_STARS:
			spawner.spawn_object("star")
		if count < MAX_STARS - 1:
			spawner.spawn_object("star")

	# Outros objetos NÃO duplicam

func _count_type(type: String) -> int:
	var count = 0
	for obj in get_tree().get_nodes_in_group("objects"):
		if obj.has_meta("object_type") and obj.get_meta("object_type") == type:
			count += 1
	return count

func _trigger_game_over():
	is_game_over = true
	difficulty.stop()
	ball.set_physics_process(false)
	ball.velocity = Vector2.ZERO
	get_tree().call_group("objects", "set_process", false)
	_play_sfx("res://sounds/bomb.wav")
	score_final.text = "Pontuação final: %d" % score
	game_over_panel.show()

func _play_sfx(path: String):
	var player = AudioStreamPlayer.new()
	add_child(player)
	player.stream = load(path)
	player.play()
	player.finished.connect(player.queue_free)

func _on_restart_pressed():
	get_tree().reload_current_scene()

func _on_difficulty_increased(level: int):
	level_label.text = "Nível: %d" % level
	_show_level_popup(level)

func _show_level_popup(level: int):
	var canvas = $UI
	var nodes_to_remove = []

	var overlay = ColorRect.new()
	overlay.color = Color(0.05, 0.05, 0.1, 0.65)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(overlay)
	nodes_to_remove.append(overlay)

	var label = Label.new()
	label.text = "NÍVEL %d!" % level
	label.add_theme_font_size_override("font_size", 72)
	label.add_theme_color_override("font_color", Color(0, 0.85, 1.0))
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0.1))
	label.add_theme_constant_override("outline_size", 8)
	label.set_anchors_preset(Control.PRESET_CENTER)
	label.offset_left   = -240
	label.offset_right  =  240
	label.offset_top    = -50
	label.offset_bottom =  50
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	canvas.add_child(label)
	nodes_to_remove.append(label)

	var tw = create_tween()
	tw.tween_property(label, "scale", Vector2(1.2, 1.2), 0.25)
	tw.tween_property(label, "scale", Vector2(1.0, 1.0), 0.2)

	await get_tree().create_timer(1.5).timeout
	for n in nodes_to_remove:
		if is_instance_valid(n):
			n.queue_free()

func _update_ui():
	score_label.text = "Pontos: %d" % score
