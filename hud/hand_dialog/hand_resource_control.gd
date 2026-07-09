@tool
class_name HandResourceControl
extends DialogControl

@onready var _quantity_label := %Quantity
@onready var _exchange_label := %ExchangeRate

@export var resource_type: Model.ResourceTypes = Model.ResourceTypes.NONE
@export var drag_mask := 1

@export var sprite_texture : Texture2D:
	set(value):
		sprite_texture = value		
		if not is_node_ready(): return
		%ScaledSprite.texture = value


@export var sprite_size := Vector2(50, 50):	
	set(value):
		sprite_size = value
		if not is_node_ready(): return
		if not self.sprite_texture: return
		if value == Vector2.ZERO: return
		%ScaledSprite.sprite_size = value


func _ready() -> void:
	super._ready()

	self.sprite_texture = self.sprite_texture
	self.sprite_size = self.sprite_size
	EventBus.resources_updated.connect(self.resources_updated)
	EventBus.exchange_rate_set.connect(self.exchange_rate_set)
	EventBus.model_loaded.connect(self.model_loaded)

	$DragNode.drag_end.connect(self._on_drag_end)

	# DEBUG EVENT LISTENER TODO REMOVE
	self.gui_input.connect(func(event: InputEvent):
		if not event is InputEventMouse: return
		var mouse_event = event as InputEventMouse
		if not mouse_event.ctrl_pressed: return
		if not mouse_event.is_pressed(): return
		
		var wallet = Wallet.new([self.resource_type])
		Game.model.do_add_resources(Game.self_id, wallet)
	)


func _on_drag_end(rec: DragRecord) -> void:
	if not rec.destination is HandResourceControl: return
	var target = rec.destination as HandResourceControl
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


func _on_drag_start():
	pass # Replace with function body.
