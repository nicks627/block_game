extends CharacterBody2D

const SPEED = 600.0
var screen_size: Vector2
var half_width: float

func _ready():
	screen_size = get_viewport_rect().size
	half_width = $CollisionShape2D.shape.get_rect().size.x / 2

func _physics_process(delta):
	var direction = 0
	if Input.is_action_pressed("move_left"):
		direction = -1
	elif Input.is_action_pressed("move_right"):
		direction = 1
	
	if direction != 0:
		move_paddle(direction, delta)

func move_paddle(direction: float, delta: float):
	position.x += direction * SPEED * delta
	position.x = clamp(position.x, half_width, screen_size.x - half_width)