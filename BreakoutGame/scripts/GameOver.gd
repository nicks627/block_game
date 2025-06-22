extends Control

signal restart_requested
signal quit_requested

func _ready():
	$VBoxContainer/RestartButton.pressed.connect(_on_restart_pressed)
	$VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)

func set_final_score(score: int):
	$VBoxContainer/ScoreLabel.text = "Final Score: %d" % score

func _on_restart_pressed():
	restart_requested.emit()

func _on_quit_pressed():
	quit_requested.emit()
	get_tree().quit()