extends Node2D

var button_type = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_start_pressed() -> void:
	button_type = "start"
	$CreditsText.hide()
	$ControlsText.hide()
	$Logo1.show()
	$fade_transition.show()
	$fade_transition/fade_timer.start()
	$fade_transition/AnimationPlayer.play("fadeout")

func _on_credits_pressed() -> void:
	$Logo1.hide()
	$ControlsText.hide()
	$CreditsText.show()
	
func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_fade_timer_timeout() -> void:
	if button_type == "start" :
		get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_controls_pressed() -> void:
	$Logo1.hide()
	$CreditsText.hide()
	$ControlsText.show()
