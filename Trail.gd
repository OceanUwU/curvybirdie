extends Node2D

const LIFETIME := 1.2
    
func _ready():
    $Tween.interpolate_property(self, 'scale', scale, Vector2(0, 0), LIFETIME, Tween.TRANS_QUAD, Tween.EASE_IN)
    $Tween.start()
    yield($Tween, 'tween_completed')
    queue_free()
