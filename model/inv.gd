extends PanelContainer

# Get references to nodes inside this PanelContainer
@onready var grid_container = $MarginContainer/GridContainer
@onready var texture_rect = $MarginContainer/TextureRect
@export var full:int = 0   # Keeps track of how many slots are filled

# The currently selected inventory slot
var selected_slot: Slot = null 
@onready var player = get_node_or_null("/root/Node2D/player")

# Adds an item to the inventory
func add_item(ID="", item_quantity=1) -> bool:
	# Load item texture and properties from ItemData
	var item_texture = load("res://assets/" + ItemData.get_texture(ID))
	var item_name    = ItemData.get_nume(ID)
	var item_number  = ItemData.get_number(ID)

	# Create a dictionary with item data
	var item_data = {
		"TEXTURE": item_texture,
		"QUANTITY": int(item_quantity),
		"NUMBER": item_number,
		"NAME": item_name,
	}

	# Check if the item already exists in inventory → increase quantity
	for i in range(grid_container.get_child_count()):
		var child = grid_container.get_child(i)
		if child is Slot and child.filled and child.get_id() == ID:
			child.quantity += int(item_quantity)
			child.set_property({
				"TEXTURE": child.get_texture(),
				"QUANTITY": child.quantity,
				"NUMBER": item_number,
				"NAME": item_name,
			})
			return true

	# If item does not exist → find an empty slot and put it there
	for i in range(grid_container.get_child_count()):
		var child = grid_container.get_child(i)
		if child is Slot and not child.filled:
			child.set_property(item_data)
			child.filled = true
			full += 1  # increase filled slots counter
			return true

	# Inventory full → cannot add item
	return false


var slots = []

func _ready():
	# Clear previous slot list
	slots.clear()
	# Connect signals for each slot
	for child in grid_container.get_children():
		if child is Slot:
			child.connect("slot_selected", Callable(self, "_on_slot_selected"))
			slots.append(child)

	# Select first slot if inventory has slots
	if slots.size() > 0:
		_on_slot_selected(slots[0])


# Called when a slot is selected
func _on_slot_selected(slot: Slot):
	# Deselect previous slot
	if selected_slot and is_instance_valid(player):
		selected_slot.deselect()

	# Update currently selected slot
	selected_slot = slot  
	selected_slot.select()

	# Move selector visual (texture_rect) to new slot
	update_selector_position(slot)


# Move the selector texture over the given slot
func update_selector_position(slot: Slot):
	var slot_position = slot.get_global_position()
	texture_rect.global_position = slot_position


# Handle input actions (drop items, select slots)
func _input(_event):
	if Input.is_action_just_pressed("drop"):
		drop_selected_item()
	if Input.is_action_just_pressed("drop_1"):
		drop_selected_item_1()
	if Input.is_action_just_pressed("slot_1"):
		select_slot_by_index(0)
	if Input.is_action_just_pressed("slot_2"):
		select_slot_by_index(1)
	if Input.is_action_just_pressed("slot_3"):
		select_slot_by_index(2)
	if Input.is_action_just_pressed("slot_4"):
		select_slot_by_index(3)
	if Input.is_action_just_pressed("slot_5"):
		select_slot_by_index(4)


# Transfers item data into another slot container
func transfer_item_to_slot(item_data: Dictionary, slot_container_aici: Node) -> bool:
	if typeof(item_data) == TYPE_DICTIONARY and item_data.has("NUMBER"):
		# Case 1: same item type → stack them together
		if slot_container_aici.get_id() == str(item_data["NUMBER"]):
			slot_container_aici.set_property({
				"TEXTURE": item_data["TEXTURE"],
				"QUANTITY": slot_container_aici.get_cantitate() + item_data["QUANTITY"],
				"NUMBER": item_data["NUMBER"],
				"NAME": item_data["NAME"]
			})
			return true  
		# Case 2: empty slot → place item here
		elif slot_container_aici.get_id() == "0": 
			slot_container_aici.set_property({
				"TEXTURE": item_data["TEXTURE"],
				"QUANTITY": item_data["QUANTITY"],
				"NUMBER": item_data["NUMBER"],
				"NAME": item_data["NAME"]
			})
			return true  
	return false 
	

# Selects a slot by index (0 = first slot, etc.)
func select_slot_by_index(indexx: int):
	if indexx >= 0 and indexx < grid_container.get_child_count():
		var slot = grid_container.get_child(indexx)
		if slot is Slot:
			_on_slot_selected(slot)


# Drops all items from the selected slot into the world
func drop_selected_item():
	if selected_slot:
		var ID = selected_slot.get_id() 
		if ID == "0":
			selected_slot.clear_item()
		if ID and is_instance_valid(player):
			var _world = get_node("/root/Node2D/")
			var cantiti = selected_slot.get_cantitate()

			drop_item(ID, cantiti)
			selected_slot.clear_item()
			selected_slot.deselect()
			selected_slot = null 


# Updates "full" counter → counts how many slots are filled
func update_inventory_status():
	full = 0
	for i in range(grid_container.get_child_count()):
		var child = grid_container.get_child(i)
		if child is Slot and child.filled:
			full += 1


# Spawns an item scene in the world at player's front
func drop_item(ID: String, cantiti: int):
	if cantiti == 0:
		return
	var item_cantitate = cantiti
	var item_texture_path = "res://assets/" + ItemData.get_texture(ID)
	var item_texture = load(item_texture_path) as Texture

	# Load item scene (world object)
	var item_scene = load("res://Item.tscn") as PackedScene
	if item_scene and is_instance_valid(player) :
		var world_node = get_node("/root/Node2D/")
		var item_instance = item_scene.instantiate()
		item_instance.set_cantitate(item_cantitate)
		item_instance.set_texture1(item_texture)

		item_instance.ID = ID
		item_instance.type = "slot"
		
		# Drop item in front of player
		var player_position = player.global_position
		var player_direction = player.last_direction.normalized() 
		var drop_distance = 150
		var drop_position = player_position + (player_direction * drop_distance)
		item_instance.position = drop_position 

		# Add item into world
		world_node.add_child(item_instance)


# Drops only 1 item from selected slot
func drop_selected_item_1():
	if selected_slot:
		var ID = selected_slot.get_id()  
		if ID == "0":
			selected_slot.clear_item()
		if ID and is_instance_valid(player):
			var drop_quantity = 1  

			# Example mouse drop position (not dynamic here, fixed to (100,100))
			var mouse_position = Vector2(100,100)
			var world = get_node("/root/Node2D/")
			var _local_mouse_position = world.to_local(mouse_position)

			# Decrease quantity in slot → if empty, clear slot
			if selected_slot.decrease_cantitate(drop_quantity): 
				selected_slot.clear_item()
				selected_slot.deselect()
				selected_slot = null
				full -= 1

			if ID == "0":
				drop_quantity = 0

			# Drop 1 item into world
			drop_item(ID , drop_quantity)

			# Update filled slot counter
			update_inventory_status()
