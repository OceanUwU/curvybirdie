extends Area2D

const ENABLE_TIME := 0.5

func _ready():
    pass

func set_enabled(enabled):
    if !enabled:
        $CollisionPolygon2D.position.x = -100
        
    $Tween.interpolate_property($Polygon2D, 'scale:x', $Polygon2D.scale.x, 1 if enabled else 0, ENABLE_TIME, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
    $Tween.start()
    yield($Tween, 'tween_completed')
    
    if enabled:
        $CollisionPolygon2D.position.x = 0
