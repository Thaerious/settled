extends Node2D

func _on_button_4_button_up():
	%SelectableSpriteControl.disabled = !%SelectableSpriteControl.disabled
	print("SelectableSpriteControl.disabled = %s" % [%SelectableSpriteControl.disabled])


func _on_button_3_button_up():
	%DraggableSpriteControl.disabled = !%DraggableSpriteControl.disabled
	print("DraggableSpriteControl.disabled = %s" % [%DraggableSpriteControl.disabled])


func _on_button_2_button_up():
	%DialogSpriteControl.disabled = !%DialogSpriteControl.disabled
	print("DialogSpriteControl.disabled = %s" % [%DialogSpriteControl.disabled])


func _on_button_button_up():
	%DialogControl.disabled = !%DialogControl.disabled
	print("DialogControl.disabled = %s" % [%DialogControl.disabled])


func _on_button_5_button_up():
	EventBus.current_phase_updated.emit(Model.GamePhase.SETUP)


func _on_button_6_button_up():
	EventBus.current_phase_updated.emit(Model.GamePhase.MONOPOLY)


func _on_button_7_button_up():
	EventBus.current_phase_updated.emit(Model.GamePhase.YEAR_OF_PLENTY)


func _on_button_8_button_up():
	EventBus.current_phase_updated.emit(Model.GamePhase.ROAD_BUILDING)


func _on_button_9_button_up():
	EventBus.current_phase_updated.emit(Model.GamePhase.STEAL_RESOURCES)
