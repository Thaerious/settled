@tool
class_name HandResourceControl
extends DraggableDialogControl

@onready var _quantity_label := %Quantity
@onready var _exchange_label := %ExchangeRate

@export var resource_type: Model.ResourceTypes = Model.ResourceTypes.NONE


func _ready() -> void:
	super._ready()

	EventBus.resources_updated.connect(self.resources_updated)
	EventBus.exchange_rate_set.connect(self.exchange_rate_set)
	EventBus.model_loaded.connect(self.model_loaded)

	$DragNodeUI.drag_end.connect(self._on_drag_end)


func _on_drag_end(rec: DragRecord) -> void:
	if not rec.drop_target is HandResourceControl: return
	var target = rec.drop_target as HandResourceControl
	EventBus.request_exchange.emit(Game.self_id, self.resource_type, target.resource_type)


func exchange_rate_set(id: int, wallet: Wallet):
	if not id == Game.self_id: return
	var qty = wallet.get_resource(self.resource_type)
	self._exchange_label.text = "%s:1" % qty
	


func model_loaded() -> void:
	var wallet := Game.model.get_bank(Game.self_id)
	self._quantity_label.text = str(wallet.get_resource(self.resource_type))


func resources_updated(id: int, wallet: Wallet) -> void:
	if not id == Game.self_id: return
	self._quantity_label.text = str(wallet.get_resource(self.resource_type))


func _on_mouse_entered() -> void:	
	if disabled: return
	self._style_helper.style = "hover"


func _on_mouse_exited() -> void:	
	if disabled: return
	self._style_helper.style = "default"
