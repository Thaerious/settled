@tool
class_name HandActionControl
extends DialogSpriteControl

@export var action_type: Model.ActionCardTypes = Model.ActionCardTypes.BUILD_ROAD


func _ready() -> void:
	super._ready()
	EventBus.model_loaded.connect(self._on_model_loaded)
	EventBus.current_phase_updated.connect(self._on_current_phase_updated)
	EventBus.action_cards_updated.connect(self._on_action_cards_updated)


func _on_clicked() -> void:
	EventBus.request_play_action_card.emit(Game.self_id, self.action_type)


func _on_current_phase_updated(phase: Model.GamePhase) -> void:
	var action_cards = Game.model.get_playable_action_cards(Game.self_id)
	self.disabled = true

	if Game.model.get_current_player() != Game.self_id: return

	if phase == Model.GamePhase.MAIN or phase == Model.GamePhase.PRE_ROLL:
		if action_cards.get_card(self.action_type) > 0:
			self.disabled = false


func _on_model_loaded() -> void:
	var owned = Game.model.get_owned_action_cards(Game.self_id)
	var playable = Game.model.get_playable_action_cards(Game.self_id)
	self._on_action_cards_updated(Game.self_id, owned, playable)


func _on_action_cards_updated(id: int, owned: ActionCardWallet, playable: ActionCardWallet) -> void:
	if id != Game.self_id: return
	%Quantity.text = str(owned.get_card(self.action_type))

	if playable.get_card(self.action_type) <= 0:
		self.disabled = true
	else:
		self.disabled = false
