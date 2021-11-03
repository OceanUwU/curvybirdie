extends Area2D

signal score
signal die

const INITIAL_SPEED := 130.0
const MAX_SPEED := 250.0
const SPEED_INCREASE := (MAX_SPEED - INITIAL_SPEED) / Globals.FINAL_SCORE
const INITAL_SPEED_HARD := 210.0
const SPEED_INCREASE_HARD := (MAX_SPEED - INITAL_SPEED_HARD) / Globals.FINAL_SCORE
const INITIAL_GRAVITY := 11.4
const GRAVITY_SCALE := 130.0
const TRAIL_INTERVAL := 0.2
const ROTATION_SCALE := 0.12
const TUTORIAL_EASE_TIME := 1.3
const TUTORIAL_EASE_TIME_HARD := 0.98
const FLAP_TIME := 0.18

export (PackedScene) var Trail
export (PackedScene) var DeathParticles
export (Material) var DeadMaterial
var skin : String
var dead_eye_texture
var trail_texture
var rightwards := true
var playing := false
var flapped := false
var flapping := false
var input_allowed := true
var do_tutorial := false
var tutorial_active := true
var current_gravity := INITIAL_GRAVITY
var velocity := Vector2(INITIAL_SPEED, 0.0)
var time_since_last_trail := 0.0
var moving := false
var last_score_time := 0
var time_scale := 1.0
var hard : bool

var flying_audio
var wing
var wing_tween
var tutorial
var tutorial_ease_time : float

func _ready():
    flying_audio = $FlyingAudio
    wing = $Wing
    wing_tween = $Wing/Tween
    tutorial = get_node('/root/Main/Tutorial')
    
    #apply textures
    var skin_location = 'res://assets/birds/'+skin+'/'
    $Beak/Bottom.texture = load(skin_location+'beakbottom.png')
    $Beak/Top.texture = load(skin_location+'beaktop.png')
    $Body.texture = load(skin_location+'body.png')
    $Eye.texture = load(skin_location+'eye.png')
    dead_eye_texture = load(skin_location+'deadeye.png')
    $Wing.texture = load(skin_location+'wing.png')
    trail_texture = load(skin_location+'trail.png')
    

func start_game(is_hard):
    hard = is_hard
    playing = true
    moving = true
    input_allowed = false
    modulate.a = 0
    if hard:
        velocity.x = INITAL_SPEED_HARD
        current_gravity = INITIAL_GRAVITY * (velocity.x / GRAVITY_SCALE)
    $Tween.interpolate_property(self, 'modulate:a', 0.0, 1.0, 0.5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
    $Tween.start()
    tutorial_ease_time = TUTORIAL_EASE_TIME_HARD if hard else TUTORIAL_EASE_TIME
    if do_tutorial:
        initiate_tutorial()
    else:
        end_tutorial()
        yield(get_tree().create_timer(0.5), 'timeout')
        input_allowed = true

func initiate_tutorial():
    tutorial_active = true
    $Tween.interpolate_property(self, 'time_scale', 1.0, 0.0, tutorial_ease_time, Tween.TRANS_QUAD, Tween.EASE_IN)
    $Tween.start()
    $Tween.interpolate_property(tutorial, 'modulate:a', 0.0, 1.0, tutorial_ease_time, Tween.TRANS_QUAD, Tween.EASE_OUT)
    $Tween.start()
    yield($Tween, 'tween_completed')
    input_allowed = true

func end_tutorial():
    tutorial_active = false
    $Tween.interpolate_property(self, 'time_scale', time_scale, 1.0, tutorial_ease_time, Tween.TRANS_QUAD, Tween.EASE_IN)
    $Tween.start()
    $Tween.interpolate_property(tutorial, 'modulate:a', tutorial.modulate.a, 0.0, tutorial_ease_time, Tween.TRANS_QUAD, Tween.EASE_IN)
    $Tween.start()
    yield($Tween, 'tween_completed')
    $CollisionPolygon2D.disabled = false
    

func _unhandled_input(event):
    if playing && input_allowed && event is InputEventMouseButton && event.button_index == 1:
        if event.pressed:
            if !flapped:
                flapping = true
                flapped = true
                time_since_last_trail = TRAIL_INTERVAL
                flying_audio.start()
                $Beak.open()
                if tutorial_active:
                    end_tutorial()
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
                trail.texture = trail_texture
                trail.position = position
                trail.scale = scale
                get_parent().add_child(trail)
    if moving:
        velocity.y += current_gravity * (-1 if flapping else 1) * time_scale
        position += velocity * delta * time_scale
        rotation = clamp(velocity.y * delta * ROTATION_SCALE, -0.5 * PI, 0.5 * PI) * (1 if rightwards else -1) * (1 if playing else -1)

func _process(_delta):
    $FlyingAudio.adjust(velocity.y * 0.017)
    if flapping && !wing_tween.is_active(): #if !wing_tween.is_active() && (flapping || wing.scale.y < 0):
        wing_tween.interpolate_property(wing, 'scale:y', wing.scale.y, wing.scale.y * -1, FLAP_TIME, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
        wing_tween.start()

func _on_Bird_area_shape_entered(_area_id, area, _area_shape, _local_shape):
    if area.name == 'Edges': #if bird scored a point
        #turn around
        rightwards = !rightwards
        scale.x *= -1
        flapped = false
        
        #speed up
        velocity.x = min(abs(velocity.x)+(SPEED_INCREASE_HARD if hard else SPEED_INCREASE), MAX_SPEED) * (1 if rightwards else -1)
        current_gravity = INITIAL_GRAVITY * (abs(velocity.x) / GRAVITY_SCALE)
        
        #score a point
        $ScoreAudio.play()
        emit_signal('score')
        last_score_time = OS.get_ticks_msec()
            
    elif 'Spike' in area.name: #if bird died
        if (OS.get_ticks_msec() - last_score_time) < 100: #if the player scored a point in the last couple frames
            #reverse this (visually), so that the bird doesnt die inside the walls
            rightwards = !rightwards
            scale.x *= -1
            velocity.x *= -1
        
        #stop controls
        flapping = false
        flying_audio.end()
        playing = false
        $CollisionPolygon2D.queue_free()
        
        #make the bird visually dead
        velocity *= -1
        $Beak.open()
        $DeathAudio.play()
        set_material(DeadMaterial)
        $Eye.texture = dead_eye_texture 
        
        #spawn blood(?) particles
        var particles = DeathParticles.instance()
        particles.position = $Beak/End.global_position
        particles.rotation = rotation + (PI if rightwards else 0.0)
        get_tree().get_root().add_child(particles)
        particles.emitting = true
        
        emit_signal('die')
        
        #remove the bird (but wait 10 seconds to make sure it's offscreen first)
        yield(get_tree().create_timer(10), 'timeout')
        queue_free()
