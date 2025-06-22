extends Node2D

enum GameState {
	MENU,
	PLAYING,
	PAUSED,
	GAME_OVER,
	GAME_CLEAR
}

var score: int = 0
var lives: int = 3
var current_state: GameState = GameState.MENU
var blocks_remaining: int = 0
var paddle: CharacterBody2D
var ball: CharacterBody2D
var ui: Control
var block_scene = preload("res://scenes/Block.tscn")
var best_score: int = 0
const SAVE_FILE_PATH = "user://bestscore.save"

func _ready():
	paddle = $Paddle
	ball = $Ball
	ui = $UI
	
	paddle.add_to_group("paddle")
	ball.ball_lost.connect(_on_ball_lost)
	
	load_best_score()
	setup_blocks()
	update_ui()

func _input(event):
	if event.is_action_pressed("start_game"):
		if current_state == GameState.MENU:
			start_game()
		elif current_state == GameState.PLAYING:
			ball.start_ball()
	elif event.is_action_pressed("pause_game"):
		if current_state == GameState.PLAYING:
			pause_game()
		elif current_state == GameState.PAUSED:
			resume_game()

func setup_blocks():
	var block_container = $BlocksContainer
	
	for child in block_container.get_children():
		child.queue_free()
	
	blocks_remaining = 0
	
	for row in range(10):
		for col in range(14):
			var block = block_scene.instantiate()
			block.position = Vector2(col * 62, row * 32)
			block.set_block_properties(row % 5)
			block.block_destroyed.connect(_on_block_destroyed)
			block_container.add_child(block)
			blocks_remaining += 1

func start_game():
	current_state = GameState.PLAYING
	score = 0
	lives = 3
	setup_blocks()
	ball.reset_position()
	update_ui()

func pause_game():
	current_state = GameState.PAUSED
	get_tree().paused = true
	ui.get_node("StatusLabel").text = "PAUSED"

func resume_game():
	current_state = GameState.PLAYING
	get_tree().paused = false
	ui.get_node("StatusLabel").text = ""

func add_score(points: int):
	score += points
	update_ui()

func lose_life():
	lives -= 1
	update_ui()
	check_lose_condition()

func check_win_condition():
	if blocks_remaining <= 0:
		current_state = GameState.GAME_CLEAR
		ui.get_node("StatusLabel").text = "YOU WIN!"
		ball.set_physics_process(false)
		check_and_save_best_score()

func check_lose_condition():
	if lives <= 0:
		current_state = GameState.GAME_OVER
		ui.get_node("StatusLabel").text = "GAME OVER"
		ball.set_physics_process(false)
		check_and_save_best_score()

func restart_game():
	start_game()

func update_ui():
	ui.get_node("ScorePanel/VBoxContainer/ScoreLabel").text = "Score: %06d" % score
	ui.get_node("ScorePanel/VBoxContainer/BestScoreLabel").text = "Best: %06d" % best_score
	
	var lives_text = "Lives: "
	for i in range(lives):
		lives_text += "♥"
	ui.get_node("LivesLabel").text = lives_text
	
	if current_state == GameState.MENU:
		ui.get_node("StatusLabel").text = "PRESS SPACE TO START"
	elif current_state == GameState.PLAYING and not ball.is_started:
		ui.get_node("StatusLabel").text = "PRESS SPACE TO LAUNCH"
	elif current_state == GameState.PLAYING:
		ui.get_node("StatusLabel").text = ""

func _on_ball_lost():
	lose_life()
	if current_state == GameState.PLAYING:
		ball.reset_position()

func _on_block_destroyed(points: int):
	add_score(points)
	blocks_remaining -= 1
	check_win_condition()

func load_best_score():
	if FileAccess.file_exists(SAVE_FILE_PATH):
		var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
		if file:
			best_score = file.get_32()
			file.close()

func save_best_score():
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file:
		file.store_32(best_score)
		file.close()

func check_and_save_best_score():
	if score > best_score:
		best_score = score
		save_best_score()
		update_ui()