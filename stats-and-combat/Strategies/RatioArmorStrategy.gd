extends BaseArmorStrategy
class_name RatioArmorStrategy

var ratio_amount:float

func _init(_ratio_amount, _lifetime):
	super(_lifetime)
	ratio_amount = _ratio_amount

func apply_ratio_reduction(amount: float):
	return amount * ratio_amount
