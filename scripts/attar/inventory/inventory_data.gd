extends Resource
class_name InventoryData

signal inventory_interact(inventory_data:InventoryData, index: int, button: int)

@export var slot_datas: Array[SlotData]
var items:Dictionary = {}

func on_slot_clicked(index: int, button: int) -> void:
	inventory_interact.emit(self, index, button)
