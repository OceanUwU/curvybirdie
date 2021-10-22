extends Node2D

const TOP_OPEN_ROTATION := -0.07
const BOTTOM_OPEN_ROTATION := 0.21
const OPEN_TIME := 0.3
const CLOSE_TIME := 0.3

var top
var bottom
var tween

func _ready():
    top = $Top
    bottom = $Bottom
    tween = $Tween
    pass

func open():
    tween.stop_all()
    tween.interpolate_property(top, 'rotation', top.rotation, TOP_OPEN_ROTATION, OPEN_TIME, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
    tween.start()
    tween.interpolate_property(bottom, 'rotation', bottom.rotation, BOTTOM_OPEN_ROTATION, OPEN_TIME, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
    tween.start()

func close():
    tween.stop_all()
    tween.interpolate_property(top, 'rotation', top.rotation, 0.0, OPEN_TIME, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
    tween.start()
    tween.interpolate_property(bottom, 'rotation', bottom.rotation, 0.0, OPEN_TIME, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
    tween.start()
