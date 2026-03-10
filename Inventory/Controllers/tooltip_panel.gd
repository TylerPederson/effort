extends Control

@export var item_name: String
@export var item_icon: Texture2D
@export var item_description: String

@onready var rich_text_label: RichTextLabel = $Panel/RichTextLabel
@onready var texture_rect: TextureRect = $"Panel/Item Icon"
@onready var name_label: Label = $"Panel/Item Name"


func update_panel(item_data: ItemData) -> void:
	self.visible = true
	
	item_name = item_data.item_name
	item_icon = item_data.Item_icon
	item_description = item_data.item_desc
	
	rich_text_label.text = item_description
	texture_rect.texture = item_icon
	name_label.text = item_name
	
	

func hide_panel() -> void:
	self.visible = false
