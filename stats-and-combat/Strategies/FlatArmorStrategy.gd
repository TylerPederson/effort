extends BaseArmorStrategy
class_name FlatArmorStrategy

var flat_amount:int

func _init(_flat_amount, _lifetime):
	super(_lifetime)
	flat_amount = _flat_amount

func apply_flat_reduction(amount: int):
	return amount + flat_amount
