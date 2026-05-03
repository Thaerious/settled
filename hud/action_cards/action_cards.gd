class_name ActionCardsContainer
extends PanelContainer

@onready var qty_knight: Label = %QtyKnight
@onready var qty_build_road: Label = %QtyBuildRoad
@onready var qty_plenty: Label = %QtyPlenty
@onready var qty_monopoly: Label = %QtyMonopoly
@onready var qty_victory: Label = %QtyVictory

var _card_label_map: Dictionary[Model.ActionCardTypes, Label] = {}


func _ready() -> void:
	self._card_label_map = {
		Model.ActionCardTypes.SOLDIER:        self.qty_knight,
		Model.ActionCardTypes.BUILD_ROAD:     self.qty_build_road,
		Model.ActionCardTypes.PLENTY:         self.qty_plenty,
		Model.ActionCardTypes.MONOPOLY:       self.qty_monopoly,
		Model.ActionCardTypes.VICTORY_POINTS: self.qty_victory,
	}

	EventBus.add_action_card.connect(self._on_add_action_card)
	EventBus.reset_view.connect(self._reset_view)


func _reset_view() -> void:
	var action_cards_model := Game.model.get_action_cards(Game.self_id)

	for card: Model.ActionCardTypes in self._card_label_map.keys():
		var label: Label = self._card_label_map.get(card)
		var count = action_cards_model[card]
		label.text = str(count)	


func _on_add_action_card(id: int, card: Model.ActionCardTypes) -> void:
	if id != Game.self_id: return

	var label: Label = self._card_label_map.get(card)
	if label:
		label.text = str(label.text.to_int() + 1)