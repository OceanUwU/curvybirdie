extends TextureRect

const TARGET_SCALE := Vector2(0.49, 0.49)
const CLOSE_TIME := 1.5
const ALPHA_TRANSITION_TIME = 0.15

var initial_scale : Vector2
var tween : Tween

func _ready():
    initial_scale = rect_scale
    tween = $Tween

func transition(from_node, to_node, show_walls):
    modulate = Globals.theme[1]
    visible = true
    
    tween.interpolate_property(self, 'rect_scale', rect_scale, TARGET_SCALE, CLOSE_TIME, Tween.TRANS_CUBIC, Tween.EASE_OUT)
    tween.start()
    yield(tween, 'tween_completed')
    
    tween.interpolate_property(from_node, 'modulate:a', 1.0, 0.0, ALPHA_TRANSITION_TIME, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
    tween.start()
    yield(tween, 'tween_completed')
    
    from_node.rect_scale = Vector2(0, 0)
    to_node.modulate.a = 0.0
    to_node.rect_scale = Vector2(1, 1)
    for wall in get_parent().walls:
        wall.visible = show_walls
    
    tween.interpolate_property(to_node, 'modulate:a', 0.0, 1.0, ALPHA_TRANSITION_TIME, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
    tween.start()
    yield(tween, 'tween_completed')
    
    tween.interpolate_property(self, 'rect_scale', rect_scale, initial_scale, CLOSE_TIME, Tween.TRANS_CUBIC, Tween.EASE_IN)
    tween.start()
    yield(tween, 'tween_completed')
    
    visible = false 
