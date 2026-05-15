class_name ActionCardsContainer
extends PanelContainer

@onready var view_dict = {
	Model.ActionCardTypes.SOLDIER:        %QtyKnight,
	Model.ActionCardTypes.BUILD_ROAD:     %QtyBuildRoad,
	Model.ActionCardTypes.PLENTY:         %QtyPlenty,
	Model.ActionCardTypes.MONOPOLY:       %QtyMonopoly,
	Model.ActionCardTypes.VICTORY_POINTS: %QtyVictory,        
}

func _ready() -> void:
	EventBus.action_cards_updated.connect(self._action_cards_updated)
	EventBus.model_loaded.connect(self._model_loaded)


func _model_loaded() -> void:
	self._action_cards_updated(
		Game.self_id,
		Game.model.get_owned_action_cards(Game.self_id),
		Game.model.get_playable_action_cards(Game.self_id)
	)


func _action_cards_updated(id: int, owned: ActionCardWallet, playable: ActionCardWallet) -> void:
	if not id == Game.self_id: return

	for action_card_type: Model.ActionCardTypes in Model.ActionCardTypes.values():
		var o = owned.get_card(action_card_type)
		var p = playable.get_card(action_card_type)
		if o > p:
			self.view_dict[action_card_type].text = "%s+" % p
		else:
			self.view_dict[action_card_type].text = "%s" % p
