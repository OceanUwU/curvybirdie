extends Node2D

const FLAP_TIME := 0.42

var skin
var tween
var wing
var textures

func _ready():
    tween = $Tween
    wing = $Wing
    
    var skin_location = 'res://assets/birds/'+skin+'/'
    $Beak/Bottom.texture = textures[0]
    $Beak/Top.texture = textures[1]
    $Body.texture = textures[2]
    $Eye.texture = textures[3]
    $Wing.texture = textures[4]
    
    tween_wing()

func _on_Tween_tween_all_completed():
    tween_wing()

func tween_wing():
    tween.interpolate_property(wing, 'scale:y', wing.scale.y, wing.scale.y * -1, FLAP_TIME, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
    tween.start()
