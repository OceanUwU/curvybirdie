extends Node2D

const FLAP_TIME := 0.42

var skin
var tween
var wing

func _ready():
    tween = $Tween
    wing = $Wing
    
    var skin_location = 'res://assets/birds/'+skin+'/'
    $Beak/Bottom.texture = load(skin_location+'beakbottom.png')
    $Beak/Top.texture = load(skin_location+'beaktop.png')
    $Body.texture = load(skin_location+'body.png')
    $Eye.texture = load(skin_location+'eye.png')
    $Wing.texture = load(skin_location+'wing.png')
    
    tween_wing()

func _on_Tween_tween_all_completed():
    tween_wing()

func tween_wing():
    tween.interpolate_property(wing, 'scale:y', wing.scale.y, wing.scale.y * -1, FLAP_TIME, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
    tween.start()
