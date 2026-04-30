class_name InitialHouseDragHnd
extends HouseDragHnd

var _road_drag_hnd: InitialRoadDragHnd
var house_container: StoreItemContainer
var _road_container: StoreItemContainer

func _init(house_trigger: StoreItemContainer, road_trigger: StoreItemContainer) -> void:
	super._init(house_trigger)
	self._road_drag_hnd = InitialRoadDragHnd.new(road_trigger)
	self._road_drag_hnd.enabled = false
	self.house_container = house_trigger
	self._road_container = road_trigger


func _start_drag() -> void:
	self._house_piece = HOUSE_PIECE.instantiate()
	EventBus.show_initial_house_targets.emit()


func _on_success(_rec: DragRecord) -> void:
	EventBus.clear_targets.emit()
	EventBus.request_initial_house.emit(Game.self_id, self._last_target.axial)
	self.house_container.enabled = false
	self._road_container.enabled = true	

	self.enabled = false
	self._road_drag_hnd.house_axial = self._last_target.axial
	self._road_drag_hnd.enabled = true
