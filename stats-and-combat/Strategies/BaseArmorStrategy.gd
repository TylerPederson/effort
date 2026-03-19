extends Resource
class_name BaseArmorStrategy

var lifetime : float = 1.0

func _init(_lifetime: float):
	lifetime = _lifetime

func apply_flat_reduction(amount: int):
	return amount

func apply_ratio_reduction(amount: float):
	return amount
