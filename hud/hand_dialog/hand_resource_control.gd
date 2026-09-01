@tool
class_name HandResourceControl
extends DraggableSpriteControl

@export var resource_type: Model.ResourceTypes = Model.ResourceTypes.NONE
var _resources = null
var _exchange_rate = null


func _ready() -> void:
	super._ready()

	EventBus.resources_updated.connect(self.resources_updated)
	EventBus.exchange_rate_set.connect(self.exchange_rate_set)
	EventBus.model_loaded.connect(self.model_loaded)

	$DragNodeUI.drag_end.connect(self._on_drag_end)


func _on_drag_end(rec: DragRecord) -> void:
	print("hand resource control %s %s" % [rec, rec.drop_target])
	if not rec.drop_target is HandResourceControl: return
	var target = rec.drop_target as HandResourceControl
	EventBus.request_exchange.emit(Game.self_id, self.resource_type, target.resource_type)


func model_loaded() -> void:
	self.resources_updated(Game.self_id, Game.model.get_bank(Game.self_id))
	self.exchange_rate_set(Game.self_id, Game.model.get_exchange_rate(Game.self_id))


func resources_updated(id: int, wallet: Wallet) -> void:
	if not id == Game.self_id: return
	%Quantity.text = str(wallet.get_resource(self.resource_type))
	self._resources = wallet
	self._update_view()


func exchange_rate_set(id: int, wallet: Wallet):
	if not id == Game.self_id: return
	var qty = wallet.get_resource(self.resource_type)
	%ExchangeRate.text = "%s:1" % qty	
	self._exchange_rate = wallet
	self._update_view()


func _update_view() -> void:
	if self._resources == null: return
	if self._exchange_rate == null: return

	var qty = self._resources.get_resource(self.resource_type)
	var ex_rate = self._exchange_rate.get_resource(self.resource_type)
	if ex_rate > qty: self.hoverable = false
	else: self.hoverable = true
