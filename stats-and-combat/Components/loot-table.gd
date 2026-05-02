extends Resource
class_name LootTable

@export var table: Array[PackedScene] = []

@export var loot_max: int = 3
@export var loot_min: int = 1
@export var spawn_force_max: float = 10.0
@export var spawn_force_min: float = 5.0
@export var random_rot: bool = true
@export var unique_drops: bool = false #if true, item's won;t be chosen more than once per loot drop

var upward_bias: float = 0.4
