class_name ActionCards
extends PanelContainer

@onready var qty_knight: Label = %QtyKnight
@onready var qty_build_road: Label = %QtyBuildRoad
@onready var qty_plenty: Label = %QtyPlenty
@onready var qty_monopoly: Label = %QtyMonopoly
@onready var qty_victory: Label = %QtyVictory

var _card_label_map: Dictionary[Model.ActionCards, Label] = {}


func _ready() -> void:
    self._card_label_map = {
        Model.ActionCards.SOLDIER:        self.qty_knight,
        Model.ActionCards.BUILD_ROAD:    self.qty_build_road,
        Model.ActionCards.PLENTY:        self.qty_plenty,
        Model.ActionCards.MONOPOLY:      self.qty_monopoly,
        Model.ActionCards.VICTORY_POINTS: self.qty_victory,
    }

    EventBus.add_action_card.connect(self._on_add_action_card)


func _on_add_action_card(id: int, card: Model.ActionCards) -> void:
    if id != Game.self_id: return

    var label: Label = self._card_label_map.get(card)
    if label:
        label.text = str(label.text.to_int() + 1)
