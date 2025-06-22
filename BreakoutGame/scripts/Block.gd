extends StaticBody2D

var score_value: int = 10
var block_color: Color = Color.WHITE

signal block_destroyed(score)

func _ready():
	add_to_group("blocks")

func set_block_properties(row: int):
	match row:
		0:
			score_value = 50
			block_color = Color.RED
		1:
			score_value = 40
			block_color = Color.ORANGE
		2:
			score_value = 30
			block_color = Color.YELLOW
		3:
			score_value = 20
			block_color = Color.GREEN
		4:
			score_value = 10
			block_color = Color.BLUE
	
	$Polygon2D.color = block_color

func destroy_block():
	block_destroyed.emit(score_value)
	queue_free()