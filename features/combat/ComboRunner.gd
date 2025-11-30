extends Node
class_name ComboRunner

enum State { IDLE, STEP_ACTIVE }

@export var STEP_DUR_MS: int = 400
@export var WINDOW_MS: int = 150
@export var ALWAYS_OPEN: bool = true

var _db: ComboDB
var _buffer: InputBuffer
var _matcher: ComboMatcher

var state: int = State.IDLE
var active_combo_index: int = -1
var active_combo_tokens: Array = []
var step_index: int = -1
var step_start_ms: int = 0
var step_end_ms: int = 0
var window_open_ms: int = 0
var _candidate_combo_indices: Array[int] = []
var _pending_short_combo_index: int = -1
var _current_prefix: Array[StringName] = []

var last_result: Dictionary = { "tokens": [], "status": "" }

func setup(db: ComboDB, buffer: InputBuffer, matcher: ComboMatcher) -> void:
	_db = db
	_buffer = buffer
	_matcher = matcher
	_reset()

func _reset() -> void:
	state = State.IDLE
	active_combo_index = -1
	active_combo_tokens = []
	step_index = -1
	step_start_ms = 0
	step_end_ms = 0
	window_open_ms = 0
	_candidate_combo_indices.clear()
	_pending_short_combo_index = -1
	_current_prefix.clear()

func process_frame(now_ms: int, now_frame: int) -> void:
	if _db == null or _buffer == null or _matcher == null:
		return

	var new_inputs: Array = _buffer.consume_new()

	if state == State.IDLE:
		if new_inputs.is_empty():
			return
		var entries: Array = _buffer.get_entries()
		var tokens: Array[StringName] = []
		for e in entries:
			tokens.append(StringName(String(e["token"])))
		var res: Dictionary = _matcher.find_longest_suffix(_db.combos, tokens)
		if res["found"] and int(res["matched_len"]) >= 1:
			var idx: int = int(res["combo_index"])
			var first_tok: StringName = StringName(_db.combos[idx][0])
			var anchor_ms: int = _find_anchor_ms_in_new(new_inputs, first_tok)
			if anchor_ms == -1:
				anchor_ms = int(entries[entries.size() - 1]["t_ms"]) if entries.size() > 0 else now_ms
			_start_combo_from_match(res, anchor_ms)
		return

	if state == State.STEP_ACTIVE:
		_advance_with_inputs(new_inputs)
		if state == State.IDLE:
			return
		if now_ms >= step_end_ms:
			if _complete_pending_short_combo():
				return
			last_result = {
				"tokens": active_combo_tokens.duplicate(true),
				"status": "broken",
			}
			_reset()

func _start_combo_from_match(match: Dictionary, anchor_ms: int) -> void:
	var initial_index: int = int(match["combo_index"])
	var first_token: StringName = StringName(_db.combos[initial_index][0])
	active_combo_index = _select_primary_combo(first_token, initial_index)
	active_combo_tokens = _db.combos[active_combo_index]
	step_index = 0
	_current_prefix = [first_token]
	_candidate_combo_indices = _gather_candidate_combos()
	_pending_short_combo_index = -1
	_update_pending_short_combo()
	_set_step_timing(anchor_ms)
	state = State.STEP_ACTIVE

func _advance_with_inputs(new_inputs: Array) -> void:
	if active_combo_tokens.is_empty():
		return
	var last_step_index: int = active_combo_tokens.size() - 1
	for e in new_inputs:
		if step_index >= last_step_index:
			continue
		var press_ms: int = int(e["t_ms"])
		if not ALWAYS_OPEN and press_ms < window_open_ms:
			continue
		var token: StringName = StringName(String(e["token"]))
		var expected: StringName = StringName(active_combo_tokens[step_index + 1])
		if token != expected:
			if not _switch_active_combo_for_token(token):
				continue
			last_step_index = active_combo_tokens.size() - 1
			expected = StringName(active_combo_tokens[step_index + 1])
			if token != expected:
				continue
		step_index += 1
		_set_step_timing(press_ms)
		_current_prefix.append(token)
		_candidate_combo_indices = _filter_candidates_by_prefix()
		_update_pending_short_combo()
		if step_index == last_step_index:
			_complete_active_combo()
			return

func _set_step_timing(anchor_ms: int) -> void:
	step_start_ms = anchor_ms
	step_end_ms = step_start_ms + STEP_DUR_MS
	window_open_ms = step_end_ms - WINDOW_MS

func _find_anchor_ms_in_new(new_inputs: Array, token: StringName) -> int:
	# Search from newest to oldest within this frame's inputs for the press of the first token.
	for i in range(new_inputs.size() - 1, -1, -1):
		var e: Dictionary = new_inputs[i]
		var t: StringName = StringName(String(e["token"]))
		if t == token:
			return int(e["t_ms"])
	return -1

func get_snapshot(now_ms: int) -> Dictionary:
	var snapshot: Dictionary = {
		"state": ("STEP_ACTIVE" if state == State.STEP_ACTIVE else "IDLE"),
		"active_combo_index": active_combo_index,
		"active_combo_tokens": active_combo_tokens.duplicate(true),
		"step_index": step_index,
		"steps_total": active_combo_tokens.size(),
		"window_open": state == State.STEP_ACTIVE and (ALWAYS_OPEN or now_ms >= window_open_ms),
		"t_left": max(0, step_end_ms - now_ms),
		"next_token": (active_combo_tokens[step_index + 1] if state == State.STEP_ACTIVE and step_index + 1 < active_combo_tokens.size() else null),
		"last_result": last_result,
	}
	return snapshot

func _gather_candidate_combos() -> Array[int]:
	var result: Array[int] = []
	if _db == null:
		return result
	for i in range(_db.combos.size()):
		if i == active_combo_index:
			continue
		var combo: Array = _db.combos[i]
		if combo.size() >= active_combo_tokens.size():
			continue
		if _prefix_matches(combo):
			result.append(i)
	return result

func _prefix_matches(combo: Array) -> bool:
	if _current_prefix.size() > combo.size():
		return false
	for j in range(_current_prefix.size()):
		if combo[j] != _current_prefix[j]:
			return false
	return true

func _filter_candidates_by_prefix() -> Array[int]:
	var filtered: Array[int] = []
	for idx in _candidate_combo_indices:
		var combo: Array = _db.combos[idx]
		if _prefix_matches(combo):
			filtered.append(idx)
	return filtered

func _update_pending_short_combo() -> void:
	_pending_short_combo_index = -1
	var best_len: int = -1
	for idx in _candidate_combo_indices:
		var combo: Array = _db.combos[idx]
		if combo.size() == _current_prefix.size() and combo.size() > best_len:
			best_len = combo.size()
			_pending_short_combo_index = idx

func _complete_pending_short_combo() -> bool:
	if _pending_short_combo_index == -1:
		return false
	var combo_tokens: Array = _db.combos[_pending_short_combo_index]
	last_result = {
		"tokens": combo_tokens.duplicate(true),
		"status": "completed",
	}
	_reset()
	return true

func _complete_active_combo() -> void:
	last_result = {
		"tokens": active_combo_tokens.duplicate(true),
		"status": "completed",
	}
	_reset()

func _select_primary_combo(first_token: StringName, fallback_index: int) -> int:
	var best_index: int = fallback_index if fallback_index >= 0 else 0
	var best_len: int = -1
	if fallback_index >= 0 and fallback_index < _db.combos.size():
		best_len = _db.combos[fallback_index].size()
	for i in range(_db.combos.size()):
		var combo: Array = _db.combos[i]
		if combo.size() == 0:
			continue
		if combo[0] != first_token:
			continue
		if combo.size() > best_len:
			best_len = combo.size()
			best_index = i
	return best_index

func _switch_active_combo_for_token(token: StringName) -> bool:
	if _db == null:
		return false
	var best_index: int = -1
	var best_len: int = -1
	for i in range(_db.combos.size()):
		if i == active_combo_index:
			continue
		var combo: Array = _db.combos[i]
		if combo.size() <= step_index + 1:
			continue
		if combo[step_index + 1] != token:
			continue
		if not _prefix_matches(combo):
			continue
		if combo.size() > best_len:
			best_len = combo.size()
			best_index = i
	if best_index == -1:
		return false
	active_combo_index = best_index
	active_combo_tokens = _db.combos[best_index]
	_candidate_combo_indices = _gather_candidate_combos()
	_pending_short_combo_index = -1
	_update_pending_short_combo()
	return true
