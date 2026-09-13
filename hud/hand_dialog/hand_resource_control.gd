@tool
class_name HandResourceControl
extends DraggableSpriteControl

@export var resource_type: Model.ResourceTypes = Model.ResourceTypes.NONE

var quantity := "0":
	set(v): %Quantity.text = v
	get: return %Quantity.text


var rate := "4:1":
	set(v): %ExchangeRate.text = v
	get: return %ExchangeRate.text


func _ready() -> void:
	super._ready()

	EventBus.resources_updated.connect(self._update_resources)
	EventBus.exchange_rate_set.connect(self._update_rate)
	EventBus.model_loaded.connect(self.reset_view)

	$DragNodeUI.drag_end.connect(self._on_drag_end)


func _on_drag_end(rec: DragRecord) -> void:
	if not rec.drop_target is HandResourceControl: return
	var target = rec.drop_target as HandResourceControl
	EventBus.request_exchange.emit(Game.self_id, self.resource_type, target.resource_type)


func reset_view() -> void:
	self._update_resources(Game.self_id, Game.model.get_bank(Game.self_id))
	self._update_rate(Game.self_id, Game.model.get_exchange_rate(Game.self_id))


func _update_resources(id: int, wallet: Wallet) -> void:
	if not id == Game.self_id: return
	self.quantity = str(wallet.get_resource(self.resource_type))
	self._update_view()


func _update_rate(id: int, wallet: Wallet):
	if not id == Game.self_id: return
	var qty = wallet.get_resource(self.resource_type)
	self.rate = "%s:1" % qty	
	self._update_view()


func _update_view() -> void:
	var resources = Game.model.get_bank(Game.self_id)
	var rates = Game.model.get_exchange_rate(Game.self_id)

	var qty = resources.get_resource(self.resource_type)
	var ex_rate = rates.get_resource(self.resource_type)
	if ex_rate > qty: self.hoverable = false
	else: self.hoverable = true
