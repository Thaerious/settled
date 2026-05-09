class_name ActionCardsContainer
extends PanelContainer

var ac_wallet := ActionCardWallet.new()

func _ready() -> void:

	self.ac_wallet.link_view({
		Model.ActionCardTypes.SOLDIER:        %QtyKnight,
		Model.ActionCardTypes.BUILD_ROAD:     %QtyBuildRoad,
		Model.ActionCardTypes.PLENTY:         %QtyPlenty,
		Model.ActionCardTypes.MONOPOLY:       %QtyMonopoly,
		Model.ActionCardTypes.VICTORY_POINTS: %QtyVictory,		
	})

	EventBus.action_cards_updated.connect(self._action_cards_updated)
	EventBus.model_loaded.connect(self._model_loaded)


func _model_loaded() -> void:
	self.ac_wallet.copy_from(Game.model.get_action_cards(Game.self_id))


func _action_cards_updated(id: int, cards: ActionCardWallet) -> void:
	if not id == Game.self_id: return
	self.ac_wallet.copy_from(cards)
