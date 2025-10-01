extends CharacterBody2D

# Player movement speed
@export var speed: float = 200.0 

# Stores the last movement direction (used for dropping items, facing direction, etc.)
var last_direction: Vector2 = Vector2.DOWN 


# Called every physics frame
func _physics_process(_delta: float) -> void:
	var input_vector = Vector2.ZERO   # Reset movement input
	
	# Get horizontal input: right (1) - left (1) → results in -1, 0, or 1
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	# Get vertical input: down (1) - up (1) → results in -1, 0, or 1
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

	# If player is moving (input is not zero)
	if input_vector != Vector2.ZERO:
		# Normalize so diagonal movement isn't faster
		input_vector = input_vector.normalized()
		# Update last direction (used for dropping items in front of player)
		last_direction = input_vector 
	
	# Apply velocity and move player
	velocity = input_vector * speed
	move_and_slide()
