extends Area2D

signal score

const INITIAL_SPEED := 130.0
const MAX_SPEED := 250.0
const SCORE_AT_WHICH_MAX_SPEED_IS_ACHIEVED := 100.0
const SPEED_INCREASE := (MAX_SPEED - INITIAL_SPEED) / SCORE_AT_WHICH_MAX_SPEED_IS_ACHIEVED
const INITIAL_GRAVITY := 11.4
const TRAIL_INTERVAL := 0.2
const FLAP_FREQUENCY := 0.18
const ROTATION_SCALE := 0.12

export (PackedScene) var Trail
var rightwards : bool
var playing : bool
var flapped : bool
var flapping : bool
var current_gravity : float
var velocity : float
var speed : float
var time_since_last_trail : float

var flying_audio
var wing
var wing_tween

func _ready():
    flying_audio = $FlyingAudio
    wing = $Wing
    wing_tween = $Wing/Tween

func start_game():
    playing = true
    rightwards = true
    flapped = false
    flapping = false
    speed = INITIAL_SPEED
    current_gravity = INITIAL_GRAVITY
    velocity = 0.0
    time_since_last_trail = 0.0

func _input(event):
    if playing && event is InputEventMouseButton && event.button_index == 1:
        if event.pressed:
            if !flapped:
                flapping = true
                flapped = true
                time_since_last_trail = TRAIL_INTERVAL
                flying_audio.start()
                $Beak.open()
        else:
            if flapping:
                flapping = false
                flying_audio.end()
                $Beak.close()

func _physics_process(delta):
    if playing:
        if flapping:
            time_since_last_trail += delta
            if time_since_last_trail >= TRAIL_INTERVAL:
                time_since_last_trail -= TRAIL_INTERVAL
                var trail = Trail.instance()
                trail.position = position
                trail.scale = scale
                get_parent().add_child(trail)
        velocity += current_gravity * delta * (-1 if flapping else 1)
        position += Vector2(speed * delta * (1 if rightwards else -1), velocity)
        rotation = velocity * ROTATION_SCALE * (1 if rightwards else -1)

func _process(_delta):
    $FlyingAudio.adjust(velocity)
    if flapping && !wing_tween.is_active(): #if !wing_tween.is_active() && (flapping || wing.scale.y < 0):
        wing_tween.interpolate_property(wing, 'scale:y', wing.scale.y, wing.scale.y * -1, FLAP_FREQUENCY, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
        wing_tween.start()

func _on_Bird_area_shape_entered(_area_id, _area, _area_shape, _local_shape):
    rightwards = !rightwards
    scale.x *= -1
    flapped = false
    speed = min(speed+SPEED_INCREASE, MAX_SPEED)
    current_gravity = INITIAL_GRAVITY * (speed / INITIAL_SPEED)
    $ScoreAudio.play()
    emit_signal('score')
