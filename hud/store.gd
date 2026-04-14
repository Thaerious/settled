extends PanelContainer

const road_piece: Texture2D = preload("res://assets/road.png")
const house_piece: Texture2D = preload("res://assets/house.png")
const city_piece: Texture2D = preload("res://assets/city.png")

@onready var road_container: Control = %RoadContainer
@onready var house_container: Control = %HouseContainer
@onready var city_container: Control = %CityContainer
@onready var card_container: Control = %CardContainer

const ICON_SIZE = Vector2(64,64)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.road_container.gui_input.connect(self._road_press)
	self.house_container.gui_input.connect(self._house_press)
	self.city_container.gui_input.connect(self._city_press)
	self.card_container.gui_input.connect(self._card_press)

static func is_left_click(event: InputEvent) -> bool:
	return (
		event is InputEventMouseButton
		and event.button_index == MouseButton.MOUSE_BUTTON_LEFT
		and event.pressed
	)



func _road_press(event: InputEvent) -> void:
	if is_left_click(event):
		EventBus.show_road_targets.emit()
		var args = DragArgs.new()
		args.texture = road_piece
		args.payload = "road"
		args.size    = ICON_SIZE
		args.offset  = Vector2.ZERO		
		
		args.on_success = func (_rec: DragRecord):
			EventBus.clear_targets.emit()

		args.on_failure = func (_rec: DragRecord):
			EventBus.clear_targets.emit()

		args.on_enter = func (_rec: HoverRecord):
			pass

		args.on_exit = func (_rec: HoverRecord):
			pass

		MouseBus.start_drag(args)


func _house_press(event: InputEvent) -> void:
	if is_left_click(event):
		EventBus.show_house_targets.emit()
		var args = DragArgs.new()
		args.texture = house_piece
		args.payload = "house"
		args.size    = ICON_SIZE
		args.offset  = Vector2.ZERO		
		
		args.on_success = func (_rec: DragRecord):
			print("on success")
			EventBus.clear_targets.emit()

		args.on_failure = func (_rec: DragRecord):
			print("on failure")
			EventBus.clear_targets.emit()

		args.on_enter = func (rec: HoverRecord):
			print("on enter ", rec)

		args.on_exit = func (rec: HoverRecord):
			print("on exit ", rec)

		MouseBus.start_drag(args)


func _city_press(event: InputEvent) -> void:
	if is_left_click(event):
		EventBus.show_city_targets.emit()
		var args = DragArgs.new()
		args.texture = city_piece
		args.payload = "city"
		args.size    = ICON_SIZE
		args.offset  = Vector2.ZERO		
		
		args.on_success = func (_rec: DragRecord):
			EventBus.clear_targets.emit()

		args.on_failure = func (_rec: DragRecord):
			EventBus.clear_targets.emit()

		args.on_enter = func (_rec: HoverRecord):
			pass

		args.on_exit = func (_rec: HoverRecord):
			pass

		MouseBus.start_drag(args)


func _card_press(event: InputEvent) -> void:
	if is_left_click(event):
		pass				
