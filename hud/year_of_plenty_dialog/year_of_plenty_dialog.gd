class_name YearOfPlentyDialog
extends Control

var wallet := Wallet.new()

func _ready() -> void:
	self._on_ready(%BrickControl)
	self._on_ready(%WoodControl)
	self._on_ready(%WheatControl)
	self._on_ready(%RockControl)
	self._on_ready(%WoolControl)
	self.update_view()

	%ButtonAccept.pressed.connect(func():
		EventBus.play_plenty_card.emit(Game.self_id, self.wallet)
	)

	EventBus.current_phase_updated.connect(self._update_phase)
	EventBus.model_loaded.connect(func(): 
		self._update_phase(Game.model.get_current_phase())
	)


func _update_phase(phase: Model.GamePhase) -> void:
	self.visible = false	

	if phase != Model.GamePhase.YEAR_OF_PLENTY: return
	if not Game.model.get_current_player() == Game.self_id: return

	self.wallet.set_all(0)
	self.update_view()
	self.visible = true	


func _on_ready(control: ResourceControl) -> void:	
	control.get_node("ButtonUp").pressed.connect(func():
		if self.wallet.size() >= 2: return
		self.wallet.add_resource(control.resource_type)
		control.get_node("Qty").text = str(wallet.get_resource(control.resource_type))
		self.update_view()
	)

	control.get_node("ButtonDn").pressed.connect(func():
		if self.wallet.get_resource(control.resource_type) <= 0: return
		self.wallet.remove_resource(control.resource_type)
		control.get_node("Qty").text = str(wallet.get_resource(control.resource_type))
		self.update_view()
	)

func update_view() -> void:
	if self.wallet.size() >= 2:
		%BrickControl.get_node("ButtonUp").disabled = true
		%WoodControl.get_node("ButtonUp").disabled = true
		%WheatControl.get_node("ButtonUp").disabled = true
		%RockControl.get_node("ButtonUp").disabled = true
		%WoolControl.get_node("ButtonUp").disabled = true
		%ButtonAccept.disabled = false
	else:
		%BrickControl.get_node("ButtonUp").disabled = false
		%WoodControl.get_node("ButtonUp").disabled = false
		%WheatControl.get_node("ButtonUp").disabled = false
		%RockControl.get_node("ButtonUp").disabled = false
		%WoolControl.get_node("ButtonUp").disabled = false
		%ButtonAccept.disabled = true

	%BrickControl.get_node("Qty").text = str(wallet.get_resource(Model.ResourceTypes.BRICK))
	%WoodControl.get_node("Qty").text = str(wallet.get_resource(Model.ResourceTypes.WOOD))
	%WheatControl.get_node("Qty").text = str(wallet.get_resource(Model.ResourceTypes.WHEAT))
	%RockControl.get_node("Qty").text = str(wallet.get_resource(Model.ResourceTypes.ROCK))
	%WoolControl.get_node("Qty").text = str(wallet.get_resource(Model.ResourceTypes.WOOL))

	if self.wallet.has_resource(Model.ResourceTypes.BRICK):
		%BrickControl.get_node("ButtonDn").disabled = false
	else:
		%BrickControl.get_node("ButtonDn").disabled = true

	if self.wallet.has_resource(Model.ResourceTypes.WOOD):
		%WoodControl.get_node("ButtonDn").disabled = false
	else:
		%WoodControl.get_node("ButtonDn").disabled = true

	if self.wallet.has_resource(Model.ResourceTypes.WHEAT):
		%WheatControl.get_node("ButtonDn").disabled = false
	else:
		%WheatControl.get_node("ButtonDn").disabled = true

	if self.wallet.has_resource(Model.ResourceTypes.ROCK):
		%RockControl.get_node("ButtonDn").disabled = false
	else:
		%RockControl.get_node("ButtonDn").disabled = true

	if self.wallet.has_resource(Model.ResourceTypes.WOOL):
		%WoolControl.get_node("ButtonDn").disabled = false
	else:
		%WoolControl.get_node("ButtonDn").disabled = true						
