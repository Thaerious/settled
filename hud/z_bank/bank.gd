# ## bank.gd
# @tool
# class_name Bank
# extends PanelContainer

# var RESOURCE_QTY_LABEL_MAP: Dictionary[Model.ResourceTypes, Label] = {}
# var RESOURCE_EX_LABEL_MAP: Dictionary[Model.ResourceTypes, Label] = {}

# func _ready() -> void:
# 	self.RESOURCE_QTY_LABEL_MAP = {
# 		Model.ResourceTypes.BRICK: %QtyBrick,
# 		Model.ResourceTypes.WOOD:  %QtyWood,
# 		Model.ResourceTypes.ROCK:  %QtyRock,
# 		Model.ResourceTypes.WHEAT: %QtyWheat,
# 		Model.ResourceTypes.WOOL:  %QtyWool,
# 	}

# 	self.RESOURCE_EX_LABEL_MAP = {
# 		Model.ResourceTypes.BRICK: %ExBrick,
# 		Model.ResourceTypes.WOOD:  %ExWood,
# 		Model.ResourceTypes.ROCK:  %ExRock,
# 		Model.ResourceTypes.WHEAT: %ExWheat,
# 		Model.ResourceTypes.WOOL:  %ExWool,
# 	}

# 	EventBus.resources_updated.connect(func(id: int, resources: Wallet) -> void:
# 		if id != Game.self_id: return
# 		resources.link_view(self.RESOURCE_QTY_LABEL_MAP)
# 	)

# 	EventBus.exchange_rate_set.connect(func(id: int, r: Model.ResourceTypes, value: int) -> void:
# 		if id != Game.self_id: return
# 		RESOURCE_EX_LABEL_MAP[r].text = "%s:1" % value		
# 	)

# 	EventBus.current_phase_updated.connect(self._on_current_phase_updated)
# 	EventBus.model_loaded.connect(self._on_model_loaded)


# func _on_current_phase_updated(phase: Model.GamePhase) -> void:
# 		match phase:
# 			Model.GamePhase.DURING_DISCARD: 
# 				self.visible = false
# 			Model.GamePhase.YEAR_OF_PLENTY:
# 				self.visible = false
# 			Model.GamePhase.MONOPOLY:
# 				self.visible = false
# 			_: self.visible = true


# func _on_model_loaded() -> void:	
# 	var qty_wallet = Game.model.get_bank(Game.self_id)
# 	var ex_wallet = Game.model.get_exchange_rate(Game.self_id, r)	

# 	self._on_current_phase_updated(Game.model.get_current_phase())

# 	wallet.update_view(RESOURCE_QTY_LABEL_MAP)
# 	wallet.update_view(RESOURCE_EX_LABEL_MAP, "%s:1")

# 	for r:Model.ResourceTypes in ServiceModule.EXCHANGABLE:
# 		RESOURCE_QTY_LABEL_MAP[r].text = str(wallet.get_resource(r))
# 		RESOURCE_EX_LABEL_MAP[r].text = "%s:1" % Game.model.get_exchange_rate(Game.self_id, r)	
