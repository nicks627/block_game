extends CharacterBody2D

var speed: float = 450.0
var is_started: bool = false
var direction: Vector2 = Vector2.ZERO
const MAX_SPEED: float = 800.0
const SPEED_INCREMENT: float = 15.0

signal ball_lost

func _ready():
	set_physics_process(false)

func _physics_process(delta):
	if not is_started:
		return
	
	velocity = direction * speed
	var collision = move_and_collide(velocity * delta)
	
	if collision:
		_handle_collision(collision)
	
	if position.y > get_viewport_rect().size.y + 50:
		ball_lost.emit()
		reset_position()

func start_ball():
	if is_started:
		return
	
	is_started = true
	direction = Vector2(randf_range(-0.5, 0.5), -1).normalized()
	set_physics_process(true)

func reset_position():
	is_started = false
	set_physics_process(false)
	var paddle = get_parent().get_node("Paddle")
	if paddle:
		position = paddle.position + Vector2(0, -30)
	speed = 450.0

func _handle_collision(collision: KinematicCollision2D):
	var collider = collision.get_collider()
	
	if collider.is_in_group("paddle"):
		var paddle_center = collider.position.x
		var hit_pos = position.x - paddle_center
		var paddle_width = collider.get_node("CollisionShape2D").shape.get_rect().size.x
		var normalized_hit = hit_pos / (paddle_width / 2)
		
		direction.x = normalized_hit * 0.75
		direction.y = -abs(direction.y)
		direction = direction.normalized()
		
		speed = min(speed + SPEED_INCREMENT, MAX_SPEED)
	else:
		direction = direction.bounce(collision.get_normal())
	
	if collider.is_in_group("blocks"):
		collider.destroy_block()