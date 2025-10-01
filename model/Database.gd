extends Node

# Stores all item data loaded from JSON
var content: Dictionary = {}


# Called when node enters the scene
func _ready():
	# Open the JSON file that contains all item data
	var file = FileAccess.open("res://Database.json", FileAccess.READ)

	# Parse JSON content into a dictionary
	content = JSON.parse_string(file.get_as_text())

	# Close the file after reading
	file.close()


# --------------------------
# Item property getters
# --------------------------

# Returns the texture filename for the given item ID
func get_texture(ID="0"):
	return content[ID]["texture"]

# Returns the quantity (default stack size) of the item
func get_cantitate(ID="0"):
	return content[ID]["quantity"]

# Returns the item number (unique numeric ID)
func get_number(ID="0"):
	return content[ID]["number"]

# Returns the item name
func get_nume(ID="0"):
	return content[ID]["name"]
