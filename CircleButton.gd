extends TextureButton

class_name CircleButton

const FOCUS_ALPHA := 0.9
const PRESSED_ALPHA := 0.8
const FOCUS_SCALE := 1.02
const PRESSED_SCALE := 0.96
const ALPHA_TWEEN_TIME := 0.12

var mouse_inside := false
var tween : Tween
var initial_scale : float

func _ready():
    mouse_default_cursor_shape = 2
    rect_pivot_offset = rect_size * 0.5
    initial_scale = rect_scale.x
    for to_connect in ['mouse_entered', 'mouse_exited', 'button_down', 'button_up']:
        connect(to_connect, self, '_on_CircleButton_'+to_connect)
    tween = Tween.new()
    add_child(tween)

func _on_CircleButton_mouse_entered():
    mouse_inside = true
    change_alpha(FOCUS_ALPHA)
    change_scale(FOCUS_SCALE)

func _on_CircleButton_mouse_exited():
    mouse_inside = false
    change_alpha(1.0)
    change_scale(1.0)

func _on_CircleButton_button_down():
    change_alpha(PRESSED_ALPHA)
    change_scale(PRESSED_SCALE)

func _on_CircleButton_button_up():
    if mouse_inside: _on_CircleButton_mouse_entered()
    else: _on_CircleButton_mouse_exited()

func change_alpha(alpha):
    if !disabled:
        tween.interpolate_property(self, 'modulate:a', modulate.a, alpha, ALPHA_TWEEN_TIME, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
        tween.start()

func change_scale(scale):
    if !disabled:
        tween.interpolate_property(self, 'rect_scale', rect_scale, Vector2(1, 1) * scale * initial_scale, ALPHA_TWEEN_TIME, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
        tween.start()
