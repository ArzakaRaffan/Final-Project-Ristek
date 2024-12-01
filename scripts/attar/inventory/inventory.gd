extends PanelContainer

const Slot = preload("res://scenes/attar/inventory/slot.tscn")
@onready var main_character: CharacterBody3D = $"../../.."
@onready var item_grid: GridContainer = $MarginContainer/ItemGrid
@export var column:int = 4
var inv_data: InventoryData

func _ready() -> void:
	inv_data = main_character.inventory_data
	populate_item_grid(inv_data)
	item_grid.columns = column

func populate_item_grid(inventory_data:InventoryData) -> void :
	inventory_data.items = {}
	for child in item_grid.get_children() :
		child.queue_free()
		
	for slot_data in inventory_data.slot_datas :
		var slot = Slot.instantiate()
		item_grid.add_child(slot)
		
		slot.slot_clicked.connect(inventory_data.on_slot_clicked)
		
		if slot_data:
			inventory_data.items[slot_data.item_data.name] = slot_data
			slot.set_slot_data(slot_data)

func add_item(inventory_data:InventoryData, slot_selected:SlotData) -> void :
	for slot_data in inv_data.slot_datas :
		if not slot_data:
			slot_data = slot_selected

func select_index(index:int) :
	var slot = item_grid.get_child(index)
	slot.select()

func unselect_index(index:int) :
	var slot = item_grid.get_child(index)
	slot.unselect()
