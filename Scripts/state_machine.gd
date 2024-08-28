class_name StateMachine
extends Node

const KEEP_CURRENT := -1

@onready var parent_node = get_node("..") as CatScript

var screen_info := {
	"game_window": Vector2i.ZERO,
	"current_screen_index": 0,
	"current_screen_size": Vector2i.ZERO,
	"window_pos": Vector2i.ZERO,
	"screen_position": Vector2i.ZERO,
	"window_in_current_display_pos": Vector2i.ZERO
}

var current_state: int = -1:
	set(v):
		parent_node.transition_state(current_state, v)
		current_state = v


func update_screen_info() -> void:
	# 1920x1080, 多个屏幕时 window_pos 会大于这个值
	var current_screen_index = DisplayServer.window_get_current_screen() as int
	# 1920x1080
	var current_screen_size = DisplayServer.screen_get_size(current_screen_index)
	# 在第二个屏幕会显示 (1920,0) 在主屏幕时会显示 (0,0)
	var screen_position = DisplayServer.screen_get_position(current_screen_index)
	# [P:(60,25),S:(1860,1055)]
	#var display_safe_area: Rect2i = DisplayServer.get_display_safe_area()
	# (256,320)
	var game_window = get_window().size
	# 无边框
	var window_pos = DisplayServer.window_get_position_with_decorations()
	var window_in_current_display_pos = window_pos - screen_position
	screen_info = {
		"game_window": game_window,
		"current_screen_index": current_screen_index,
		"current_screen_size": current_screen_size,
		"window_pos": window_pos,
		"screen_position": screen_position,
		"window_in_current_display_pos": window_in_current_display_pos
	}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await owner.ready
	# owner is parent, equal get_node("..")
	parent_node.invoke_test()
	# print(get_node(".."))
	update_screen_info()


# 程序入口
func _physics_process(delta: float) -> void:
	while true:
		var next := parent_node.get_next_state(current_state) as int
		# 正在运行
		if next == KEEP_CURRENT:
			break
		current_state = next

	parent_node.tick_physics(current_state, delta)
