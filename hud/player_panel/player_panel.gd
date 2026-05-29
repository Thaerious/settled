extends Control


var player_record: PlayerRecord = null:
	set(value):
		player_record = value
		if self.is_node_ready():
			self.update_view()


func update_view() -> void:
	pass
