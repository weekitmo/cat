class_name CatScript
extends CharacterBody2D

@onready var cat_sprite: Sprite2D = $Body/Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var transfor_timer: Timer = $TransforTimer
@onready var state_machine: StateMachine = $StateMachine

@export var cat_size: Vector2

var offset = 160
var dragging = false
var direction_int: Vector2i = Vector2i.ZERO
var speed = 5

enum State {
	IDLE_1,
	IDLE_2,
	IDLE_3,
	IDLE_4,
	MOVE_1,
	MOVE_2,
	MOVE_3,
	MOVE_4,
	MOVE_5,
	LIE,
}
# := 推断赋值
const STATE_MAP := {
	0: State.IDLE_1, 1: State.IDLE_2, 2: State.IDLE_3, 3: State.IDLE_4, 4: State.MOVE_1, 5: State.MOVE_2, 6: State.MOVE_3, 7: State.MOVE_4, 8: State.MOVE_5, 9: State.LIE
}


# 初始化，非入口
func _ready() -> void:
	var screen_size: Vector2i = get_window().size
	randomize()
	get_viewport().set_size(cat_sprite.texture.get_size())
	var custom_cursor: CompressedTexture2D = load("res://Assets/mouse.png")
	var image_texture = ImageTexture.create_from_image(custom_cursor.get_image())
	Input.set_custom_mouse_cursor(image_texture, Input.CURSOR_ARROW, Vector2(16, 16))


func tick_physics(state: State, delta: float) -> void:
	if dragging:
		# 把窗口拖动到鼠标位置
		get_window().position += Vector2i(get_global_mouse_position())
	match state:
		State.IDLE_1, State.IDLE_2, State.IDLE_3, State.IDLE_4, State.LIE:
			pass
		# MOVE_1 走路 MOVE_2 快乐的走路
		State.MOVE_1, State.MOVE_2:
			move()
		_:
			pass


func invoke_test() -> void:
	print("Print from CatScript")


func get_next_state(state: State) -> int:
	# 每次计时器停止时随机切换状态
	if transfor_timer.is_stopped():
		var i = _random()
		while STATE_MAP[i] == state:
			i = _random()

		return STATE_MAP[i]

	return StateMachine.KEEP_CURRENT


func transition_state(from: State, to: State) -> void:
	match to:
		State.IDLE_1:
			transfor_timer.wait_time = 5
			animation_player.play("idle_1")
		State.IDLE_2:
			transfor_timer.wait_time = 5
			animation_player.play("idle_2")
		State.IDLE_3:
			transfor_timer.wait_time = 3
			animation_player.play("idle_3")
		State.IDLE_4:
			transfor_timer.wait_time = 3
			animation_player.play("idle_4")
		State.MOVE_1:
			transfor_timer.wait_time = 2.4
			animation_player.play("move_1")
		State.MOVE_2:
			# 欢快
			transfor_timer.wait_time = 1.6
			animation_player.play("move_2")
		State.MOVE_3:
			# 害怕竖毛
			transfor_timer.wait_time = 1.6
			animation_player.play("move_3")
		State.MOVE_4:
			# 伸手玩
			transfor_timer.wait_time = 1.8
			animation_player.play("move_4")
		State.MOVE_5:
			# 跳
			transfor_timer.wait_time = 0.7
			animation_player.play("move_5")
		State.LIE:
			# 睡觉
			print("lie amination length: {0}".format([animation_player.get_animation("lie").length]))
			transfor_timer.wait_time = 8
			animation_player.play("lie")

	transfor_timer.start()


func move() -> void:
	var current_screen_size = state_machine.screen_info["current_screen_size"] as Vector2i
	var game_window = state_machine.screen_info["game_window"] as Vector2i
	var min: Vector2i = Vector2i(offset, offset)
	var max: Vector2i = current_screen_size - min

	var temp = get_window().position + direction_int

	if temp.x >= max.x or temp.x <= min.x:
		# 翻转
		direction_int.x = -direction_int.x
	if temp.y >= max.y or temp.y <= min.y:
		direction_int.y = -direction_int.y

	# 翻转，默认是朝右边
	if direction_int.x > 0:
		cat_sprite.flip_h = false
	else:
		cat_sprite.flip_h = true

	# 移动窗口
	get_window().position += direction_int


# 监听输入，目前是鼠标点击事件
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				dragging = true
			else:
				dragging = false


func _random() -> int:
	direction_int = Vector2i(Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() * speed)
	var count := len(STATE_MAP.keys())
	return randi() % count
