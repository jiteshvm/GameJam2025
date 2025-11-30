extends Node
class_name PlayerCombatController

@export var combo_db: ComboDB
@export var enable_combo_debug_hud: bool = false
@export var combo_debug_hud_path: NodePath = NodePath("../../ComboRunnerDebugHUD")
@export var enable_combos_view_hud: bool = true
@export var combos_view_hud_path: NodePath = NodePath("../../ComboDesignerHUD")
@export var buffer_node_path: NodePath = NodePath("InputBuffer")
@export var runner_node_path: NodePath = NodePath("ComboRunner")

var _input_buffer: InputBuffer
var _combo_runner: ComboRunner
var _matcher: ComboMatcher = ComboMatcher.new()
var _combo_debug_hud: ComboRunnerDebugHUD
var _combos_view_hud: ComboDesignerHUD

func _ready() -> void:
	if combo_db == null:
		combo_db = load("res://features/combat/data/combos.tres") as ComboDB
	set_process(true)
	_resolve_nodes()
	if combo_db and _input_buffer:
		_input_buffer.set_tokens_to_watch(combo_db.tokens)
	if combo_db and _input_buffer and _combo_runner:
		_combo_runner.setup(combo_db, _input_buffer, _matcher)
	_bind_huds()
	_update_hud_visibility()

func _process(_delta: float) -> void:
	if _input_buffer == null or _combo_runner == null:
		return
	var now_ms: int = Time.get_ticks_msec()
	var now_frame: int = Engine.get_process_frames()
	_input_buffer.process_frame(now_ms, now_frame)
	_combo_runner.process_frame(now_ms, now_frame)
	if enable_combo_debug_hud and _combo_debug_hud:
		_combo_debug_hud.update_view(now_ms)

func _resolve_nodes() -> void:
	if _input_buffer == null and buffer_node_path != NodePath():
		_input_buffer = get_node_or_null(buffer_node_path) as InputBuffer
	if _combo_runner == null and runner_node_path != NodePath():
		_combo_runner = get_node_or_null(runner_node_path) as ComboRunner
	if _combo_debug_hud == null and combo_debug_hud_path != NodePath():
		_combo_debug_hud = get_node_or_null(combo_debug_hud_path) as ComboRunnerDebugHUD
	if _combos_view_hud == null and combos_view_hud_path != NodePath():
		_combos_view_hud = get_node_or_null(combos_view_hud_path) as ComboDesignerHUD

func _bind_huds() -> void:
	if enable_combo_debug_hud and _combo_debug_hud and _input_buffer and _combo_runner:
		_combo_debug_hud.bind_sources(_input_buffer, _combo_runner)
	if enable_combos_view_hud and _combos_view_hud and _input_buffer:
		_combos_view_hud.bind_buffer(_input_buffer)
		if _combo_runner:
			_combos_view_hud.bind_runner(_combo_runner)
	_update_hud_visibility()

func _update_hud_visibility() -> void:
	if _combo_debug_hud:
		_combo_debug_hud.visible = enable_combo_debug_hud
	if _combos_view_hud:
		_combos_view_hud.visible = enable_combos_view_hud
