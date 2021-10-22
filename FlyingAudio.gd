extends AudioStreamPlayer

const QUIETEN_TIME = 1.2
const MIN_PITCH = 0.1
const MAX_PITCH = 5.0
const PITCH_DIFFERENCE = MAX_PITCH - MIN_PITCH
const MAX_VEL = 10.0

var original_volume : float
var tween

func _ready():
    tween = $Tween
    original_volume = volume_db
    volume_db = -80
    play()

func start():
    tween.stop_all()
    volume_db = original_volume

func end():
    tween.interpolate_property(self, 'volume_db', volume_db, -80.0, QUIETEN_TIME, Tween.TRANS_LINEAR)
    tween.start()

func adjust(velocity):
    if !tween.is_active():
        pitch_scale = MIN_PITCH + (PITCH_DIFFERENCE * (clamp(velocity * -1, -MAX_VEL, MAX_VEL) + MAX_VEL) / (MAX_VEL * 2))
