extends CanvasLayer
class_name ComboDesignerHUD

@export var db_path: String = "res://features/combat/data/combos.tres"
@export var text_color: Color = Color.BLACK
@export var font_size: int = 24

var _db: ComboDB
var _buffer: InputBuffer
var _last_text: String = ""
var _runner: ComboRunner

@onready var _label: RichTextLabel = $CombosPanel/RichTextLabel

func bind_buffer(buffer: InputBuffer) -> void:
	_buffer = buffer

func bind_runner(runner: ComboRunner) -> void:
	_runner = runner

func _ready() -> void:
	_label.bbcode_enabled = true
	_label.scroll_active = false
	_label.add_theme_color_override("default_color", text_color)
	_label.add_theme_color_override("font_color", text_color)
	_label.add_theme_font_size_override("font_size", font_size)
	set_process(true)
	var res: Resource = load(db_path)
	if res is ComboDB:
		_db = res as ComboDB
	else:
		_label.text = "[b]Available Combos[/b]\n[error]Missing ComboDB: %s" % db_path

func _process(_delta: float) -> void:
	var now_ms: int = Time.get_ticks_msec()
	var text: String = _compose(now_ms)
	if text != _last_text:
		_last_text = text
		_label.text = text

func _compose(now_ms: int) -> String:
	if _db == null:
		return "[b]Available Combos[/b]\n(no db)"
	var sb: Array[String] = []
	sb.append("[b]Available Combos[/b]\n")
	var buf_tokens: Array[StringName] = []
	if _buffer != null:
		for e in _buffer.get_entries():
			buf_tokens.append(StringName(String(e["token"])))
	var has_input: bool = buf_tokens.size() > 0
	var runner_active: bool = false
	var runner_prefix: Array[StringName] = []
	if _runner != null:
		var snap: Dictionary = _runner.get_snapshot(now_ms)
		if String(snap["state"]) == "STEP_ACTIVE":
			var tokens: Array = snap["active_combo_tokens"]
			var prefix_len: int = min(tokens.size(), int(snap["step_index"]) + 1)
			if prefix_len > 0:
				runner_active = true
				for i in range(prefix_len):
					runner_prefix.append(StringName(tokens[i]))
	for combo in _db.combos:
		var match_len: int = 0
		if runner_active:
			match_len = _runner_match_len(combo, runner_prefix)
		else:
			match_len = _match_len(combo, buf_tokens)
		if match_len > 0:
			var green: PackedStringArray = PackedStringArray()
			var white: PackedStringArray = PackedStringArray()
			for j in range(match_len):
				green.append(String(combo[j]))
			for j in range(match_len, combo.size()):
				white.append(String(combo[j]))
			var line: String = "[color=green]%s[/color]%s" % [String("->".join(green)), ("->%s" % String("->".join(white)) if white.size() > 0 else "")]
			sb.append(line + "\n")
		else:
			var parts: PackedStringArray = PackedStringArray()
			for t in combo:
				parts.append(String(t))
			var text_line: String = String("->".join(parts))
			if has_input:
				sb.append("[color=red]%s[/color]\n" % text_line)
			else:
				sb.append(text_line + "\n")
	return "".join(sb)

func _match_len(combo: Array, buffer_tokens: Array) -> int:
	var buf_len: int = buffer_tokens.size()
	var max_k: int = min(combo.size(), buf_len)
	for k in range(max_k, 0, -1):
		var offset: int = buf_len - k
		var ok: bool = true
		for idx in range(k):
			if combo[idx] != buffer_tokens[offset + idx]:
				ok = false
				break
		if ok:
			return k
	return 0

func _runner_match_len(combo: Array, runner_prefix: Array[StringName]) -> int:
	if runner_prefix.is_empty() or combo.is_empty():
		return 0
	if combo[0] != runner_prefix[0]:
		return 0
	var max_len: int = min(combo.size(), runner_prefix.size())
	for i in range(max_len):
		if combo[i] != runner_prefix[i]:
			return i
	return max_len
