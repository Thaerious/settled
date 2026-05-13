extends PanelContainer

const road_piece: Texture2D = preload("res://assets/road.png")
const city_piece: Texture2D = preload("res://assets/city.png")

@onready var _road_container: StoreItemContainer = %RoadContainer
@onready var _house_container: StoreItemContainer = %HouseContainer
@onready var _city_container: StoreItemContainer = %CityContainer
@onready var _card_container: StoreItemContainer = %CardContainer
@onready var _road_free: Control = %RoadFree
@onready var _road_cost: Control = %RoadCost
@onready var _house_free: Control = %HouseFree
@onready var _house_cost: Control = %HouseCost

var _house_hnd: HouseDragHnd
var _city_hnd: CityDragHnd
var _road_hnd: RoadDragHnd
var _inital_house_hnd: InitialHouseDragHnd
var _free_road_hnd: FreeRoadDragHnd


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self._house_hnd = HouseDragHnd.new(self._house_container)
	self._city_hnd = CityDragHnd.new(self._city_container)
	self._road_hnd = RoadDragHnd.new(self._road_container)
	self._inital_house_hnd = InitialHouseDragHnd.new(self._house_container, self._road_container)
	self._free_road_hnd = FreeRoadDragHnd.new(self._road_container)

	self._reset_state()

	self._card_container.gui_input.connect(self._on_click_card_container)
	EventBus.phase_updated.connect(self._update_phase)
	EventBus.add_resources.connect(func(_id, _res): self._update_main_phase())
	EventBus.remove_resources.connect(func(_id, _res): self._update_main_phase())
	
	EventBus.model_loaded.connect(func():
		self._update_phase(Game.model.get_current_phase())
	)


func _on_click_card_container(event: InputEvent) -> void:
	if self._card_container.enabled == false: return
	if not event is InputEventMouseButton: return
	if not event.button_index == MOUSE_BUTTON_LEFT: return
	if event.pressed: return
	EventBus.request_purchase_action_card.emit()		


# turn the store "off"
func _reset_state():
	self._road_free.visible = false
	self._house_free.visible = false
	self._road_cost.visible = true
	self._house_cost.visible = true		

	self._road_container.enabled = false	
	self._house_container.enabled = false
	self._city_container.enabled = false
	self._card_container.enabled = false

	self._road_hnd.enabled = false
	self._house_hnd.enabled = false
	self._city_hnd.enabled = false
	self._inital_house_hnd.enabled = false		
	self._free_road_hnd.enabled = false


func _update_phase(phase: Model.GamePhase) -> void:
	self._reset_state()
	if not Game.model.get_current_player() == Game.self_id: return

	match phase:
		Model.GamePhase.MAIN:
			self._update_main_phase()
		Model.GamePhase.SETUP_FORWARD_HOUSE:
			self._house_free.visible = true
			self._house_cost.visible = false	
			self._inital_house_hnd.enabled = true
			self._house_cost.visible = false	
			self._house_container.enabled = true
		Model.GamePhase.SETUP_REVERSE_HOUSE:
			self._house_free.visible = true
			self._house_cost.visible = false
			self._inital_house_hnd.enabled = true
			self._house_cost.visible = false	
			self._house_container.enabled = true
		Model.GamePhase.SETUP_FORWARD_ROAD:
			self._road_free.visible = true
			self._road_cost.visible = false
			self._road_container.enabled = true	
		Model.GamePhase.SETUP_REVERSE_ROAD:
			self._road_free.visible = true
			self._road_cost.visible = false
			self._road_container.enabled = true	
		Model.GamePhase.ROAD_BUILDING:
			self._road_free.visible = true
			self._road_cost.visible = false
			self._road_container.enabled = true	
			self._road_hnd.enabled = false
			self._free_road_hnd.enabled = true


func _update_main_phase():
	if Game.model.has_resources(Game.self_id, 1, 1, 0, 0, 0):
		self._road_container.enabled = true
		self._road_hnd.enabled = true
	else:
		self._road_container.enabled = false
		self._road_hnd.enabled = false

	if Game.model.has_resources(Game.self_id, 1, 1, 1, 1, 0):
		self._house_container.enabled = true
		self._house_hnd.enabled = true
	else:
		self._house_container.enabled = false
		self._house_hnd.enabled = false

	if Game.model.has_resources(Game.self_id, 0, 0, 0, 2, 3):
		self._city_container.enabled = true
		self._city_hnd.enabled = true
	else:
		self._city_container.enabled = false
		self._city_hnd.enabled = false

	if Game.model.has_resources(Game.self_id, 0, 0, 1, 1, 1):
		self._card_container.enabled = true
	else:
		self._card_container.enabled = false						
