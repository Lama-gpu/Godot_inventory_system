extends Sprite2D

# Item properties
@export var ID = ""              # Item ID (used to identify type of item)
@export var item_quant:int = 1   # Quantity of the item
@export var type: String         # Type (could be used for categorizing items)
var original_position: Vector2   # Stores the position where the item was first placed
var item_texture: Texture        # Texture reference for this item


# Called when the node enters the scene tree
func _ready():
	# Set the item texture using the ID from ItemData
	set_texture1(load("res://assets/" + ItemData.get_texture(ID)) as Texture)
	# Save the initial position of the item in the world
	original_position = position    


# Called when another body collides with this item
func _on_body_entered(body):
	# Check if the colliding body is the player
	if body.is_in_group("player"):
		# Get reference to player's inventory
		var inventory = get_node("/root/Node2D/CanvasLayer/Inv")

		print("Player touched item. ID:", ID, " Quantity:", item_quant)
		print("Inventory full:", inventory.full)

		# Try to add item to inventory
		var added = inventory.add_item(ID, self.get_cantiti())
		if added:
			# If item was successfully added → remove it from the world
			queue_free()
			print("Item collected and removed from world.")
		else:
			# If inventory is full → item remains in world
			print("Inventory is full! Cannot add item.")


# Sets the texture of this item
func set_texture1(texture_drop: Texture):
	item_texture = texture_drop
	self.texture = item_texture 


# Sets the item quantity
func set_cantitate(quantity: int):
	if quantity == 0:
		return
	item_quant = quantity


# Returns the current quantity of this item
func get_cantiti():
	return item_quant
