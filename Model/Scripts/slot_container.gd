extends PanelContainer
class_name Slot   # Makes this script usable as a custom class "Slot"

# UI references
@onready var texture_rect = $TextureHolder/TextureRect   # Slot image (the item icon)
@onready var label = %Label                             # Quantity label

@export var is_selected: bool = false   # Marks if this slot is selected by the player
var filled: bool = false                # True if the slot contains an item
var item_id: String = ""                # Item ID stored in this slot

# References to inventory and player
@onready var inv = get_node("/root/worldScene/CanvasLayer/Inv")
@onready var player = get_node("/root/worldScene/player")

# Signal emitted when a slot is selected
signal slot_selected(slot)

# Exported properties (with setters)
@export var namex: String:
	set(value):
		namex = value
		
@export var number : int = 0:
	set(value):
		number = value
		item_id = get_id()   # Update item ID when number changes

@export var quantity: int = 0:
	set(value):
		quantity = value
		# Update slot label
		label.text = str(quantity)
		if quantity > 0:
			label.text = str(quantity)
		else:
			label.text = ""

@export var raritate: String:   # "Rarity" of the item
	set(value):
		raritate = value


# Item property dictionary (contains all slot data)
@onready var property: Dictionary = {
	"TEXTURE": null,
	"QUANTITY": quantity,
	"NUMBER": number,
	"NAME": namex
}:
	set(value):
		property = value 
		texture_rect.texture = property["TEXTURE"]  
		quantity = property["QUANTITY"]
		number = property["NUMBER"]
		namex = property["NAME"]


@export var type: Variant = null   # Additional property (item type)


# -----------------------
# Slot functionality
# -----------------------

# Sets the slot with new item data
func set_property(data):
	property = data
	texture_rect.texture = property["TEXTURE"]
	quantity = property["QUANTITY"]
	number = property["NUMBER"]
	namex = property["NAME"]

	type = property.get("TYPE", [])
	label.text = str(quantity)
	if quantity > 0:
		label.text = str(quantity)
	else:
		label.text = ""
	
	# If no texture → mark as empty
	if data["TEXTURE"] == null:
		filled = false
	else:
		filled = true


# Getters
func get_texture() -> Texture:
	return property.get("TEXTURE", null)  

func get_cantitate() -> int:
	return property.get("QUANTITY", 0)
	
func get_number() -> int:
	return property.get("NUMBER", 0)
	
func get_nume() -> String:
	return property.get("NAME", "")


# -----------------------
# Drag & Drop Support
# -----------------------

# When dragging starts
func _get_drag_data(_at_position):
	var preview_texture = TextureRect.new()
	preview_texture.texture = texture_rect.texture
	preview_texture.expand_mode = 1
	preview_texture.size = Vector2(49, 49)

	var preview = Control.new()
	preview.add_child(preview_texture)

	# Show dragged preview
	set_drag_preview(preview)

	return self   # Return this slot as drag data


# Check if slot can accept a drop
func _can_drop_data(_at_position, data):
	if not (data is Slot):
		return false
	return true


# Handle dropped slot data
func _drop_data(_pos, data):
	if not (data is Slot):
		return 
	if self == data:
		return   # Ignore if slot drops onto itself

	var source_property = data.property  
	var target_property = property     

	# Case 1: target is empty → move item
	if source_property != null and target_property.has("NUMBER") and target_property.has("QUANTITY") and target_property["NUMBER"] == 0 and target_property["CANTITATE"] == 0:
		set_property(source_property)
		data.clear_item()

	# Case 2: swap items between slots
	elif source_property != null and target_property != null:
		var temp = target_property
		set_property(source_property)
		data.set_property(temp)


# -----------------------
# Input & Selection
# -----------------------

func _ready():
	# Connect mouse input for selecting slot
	connect("gui_input", Callable(self, "_on_gui_input"))

func _on_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		is_selected = true
		emit_signal("slot_selected", self)

func select():
	is_selected = true
	
func deselect():
	is_selected = false


# -----------------------
# Item Management
# -----------------------

# Clear slot (remove item)
func clear_item():
	$TextureHolder/TextureRect.texture = null  
	label.text = ""
	quantity = 0
	property = {"TEXTURE": null, "QUANTITY": 0, "NUMBER": 0, "NAME": ""}
	filled = false  


# Get item ID by matching number with ItemData content
func get_id() -> String:
	if property and property.has("number") != null:
		for key in ItemData.content.keys():
			if ItemData.content[key]["number"] == number:
				return key
	return "0"


# Decrease quantity by "amount"
# Returns true if item is completely removed
func decrease_cantitate(amount: int) -> bool:
	if quantity > 0:
		quantity -= amount  
		property["QUANTITY"] = quantity

		if quantity <= 0:
			quantity = 0  
			clear_item() 
			return true   # Item removed completely
		else:
			label.text = str(quantity)  
		return false  
	return true   # Slot was already empty


# Increase quantity in slot
func increase_cantitate(amount: int):
	quantity += amount
	property["QUANTITY"] = quantity
	if quantity > 0:
		label.text = str(quantity)
	else:
		label.text = ""


# Add new item into this slot
func add_item(new_item_id: String, amount: int):
	self.set_property({
		"TEXTURE": load("res://assets/" + ItemData.get_texture(new_item_id)),
		"QUANTITY": amount,
		"NUMBER": ItemData.get_number(new_item_id),
		"NAME": ItemData.get_nume(new_item_id)
	})
	self.filled = true
	

# Returns slot data as dictionary
func get_item() -> Dictionary:
	if filled:
		return {
			"TEXTURE": property["TEXTURE"],  
			"QUANTITY": property["QUANTITY"],  
			"NUMBER": property["NUMBER"], 
			"NAME": property["NAME"]
		}
	else:
		return {}   # Empty slot
