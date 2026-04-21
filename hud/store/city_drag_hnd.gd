class_name CityDragHnd
extends ProductBase

const CITY_TEXTURE: Texture2D = preload("res://assets/city.png")
const CITY_PIECE: PackedScene = preload("res://game_board/city_piece.tscn")
const ICON_SIZE = Vector2(32,32)

var trigger: Control
var _city_piece = CITY_PIECE.instantiate()
var _last_target: CornerTarget = null


func _init(trigger: Control) -> void:
	self.trigger = trigger
	self.trigger.gui_input.connect(self._city_press)


func _city_press(event: InputEvent) -> void:
	if is_left_click(event): self._start_drag()


func _start_drag() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	self._city_piece = CITY_PIECE.instantiate()

	var args = DragArgs.new()
	args.texture = CITY_TEXTURE
	args.payload = "city"
	args.size    = ICON_SIZE
	args.offset  = ICON_SIZE / -2	
	args.on_success = self._on_success
	args.on_failure = self._on_failure
	args.on_enter = self._on_enter
	args.on_exit = self._on_exit

	EventBus.show_city_targets.emit()
	MouseBus.start_drag(args)


func _on_success(_rec: DragRecord) -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	EventBus.clear_targets.emit()

	if self._last_target: 
		EventBus.set_city.emit(GameModel.self_id, _last_target.axial)
	
	self._last_target = null


func _on_failure(_rec: DragRecord) -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	EventBus.clear_targets.emit()
	self._last_target = null


func _on_enter(rec: HoverRecord) -> void:	
	if not rec.entered.owner is CornerTarget: return		

	var target := rec.entered.owner as CornerTarget
	if target == self._last_target: return  # already set, ignore

	rec.draggable.visible = false
	if self._last_target: self._last_target.clear_piece()
	self._last_target = rec.entered.owner as CornerTarget
	self._last_target.set_piece(self._city_piece)	
	

func _on_exit(rec: HoverRecord) -> void:	
	if not rec.exited.owner is CornerTarget: return	

	var target := rec.exited.owner as CornerTarget
	if target != self._last_target: return  # already moved on, ignore

	rec.draggable.visible = true
	self._last_target.clear_piece()
	self._last_target = null
