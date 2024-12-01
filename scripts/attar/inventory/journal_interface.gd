extends Control

@onready var main_character: CharacterBody3D = $"../.."
@onready var item_name: Label = $ItemName
@onready var description: Label = $Description
@onready var inventory: PanelContainer = $inventory

func _ready() :
	var inv_data: InventoryData = main_character.inventory_data
	inv_data.inventory_interact.connect(on_inventory_interact)

func on_inventory_interact(inventory_data:InventoryData, index: int, button: int) -> void :
	for i in range (4) :
		inventory.unselect_index(i)
	inventory.select_index(index)
	var slot_data = inventory_data.slot_datas[index]
	if slot_data :
		var item_data = slot_data.item_data
		item_name.text = item_data.name
		description.text = item_data.description
		item_name.show()
		description.show()
	else :
		item_name.hide()
		description.hide()
		
