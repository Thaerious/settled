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


	EventBus.add_action_card.connect(self._on_add_action_card)
	EventBus.reset_view.connect(self._reset_view)


func _reset_view() -> void:
	self.ac_wallet.copy_from(Game.model.get_action_cards(Game.self_id))


func _on_add_action_card(id: int, _card: Model.ActionCardTypes) -> void:
	if not id == Game.self_id: return
	self.ac_wallet.copy_from(Game.model.get_action_cards(Game.self_id))
