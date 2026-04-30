class_name InitialRoadDragHnd
extends RoadDragHnd

var house_axial: Axial
var road_axial: AxialEdge
var _road_container: StoreItemContainer

func _init(road_trigger: StoreItemContainer) -> void:
	super._init(road_trigger)
	self._road_container = road_trigger


func _start_drag() -> void:
	self._road_piece = ROAD_PIECE.instantiate()
	EventBus.show_initial_road_targets.emit(self.house_axial)


func _on_success(_rec: DragRecord) -> void:
	EventBus.clear_targets.emit()

	if self._last_target != null: 
		EventBus.request_initial_road.emit(Game.self_id, self._last_target.axial_edge)
		self._last_target = null
		self.enabled = false
		self._road_container.enabled = false
