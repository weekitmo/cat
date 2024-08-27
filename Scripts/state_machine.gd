class_name StateMachine
extends Node

const KEEP_CURRENT := -1

@onready var parent_node = get_node("..") as CatScript

var screen_info := {"game_window": Vector2i.ZERO, "current_screen_index": 0, "current_screen_size": Vector2i.ZERO, "window_pos": Vector2i.ZERO}

var current_state: int = -1:
	set(v):
		parent_node.transition_state(current_state, v)
		current_state = v


func update_screen_info() -> void:
	var current_screen_size = DisplayServer.screen_get_size()
	var current_screen_index = DisplayServer.window_get_current_screen() as int
	var game_window = get_window().size
	var window_pos = DisplayServer.window_get_position()
	screen_info = {
		"game_window": game_window,
		"current_screen_index": current_screen_index,
		"current_screen_size": current_screen_size,
		"window_pos": window_pos,
	}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await owner.ready
	# owner is parent, equal get_node("..")
	parent_node.invoke_test()
	# print(get_node(".."))
	update_screen_info()
	print(screen_info)


# 程序入口
func _physics_process(delta: float) -> void:
	while true:
		var next := parent_node.get_next_state(current_state) as int
		# 正在运行
		if next == KEEP_CURRENT:
			break
		current_state = next

	parent_node.tick_physics(current_state, delta)
