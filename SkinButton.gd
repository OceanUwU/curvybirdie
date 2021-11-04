extends CircleButton

signal select

const Bird := preload('res://DisplayBird.tscn')
const LIGHT_MASK := 2
const CENTRE := Vector2(150, 350)
const START_DISTANCE_FROM_CENTRE := 95.0
const END_DISTANCE_FROM_CENTRE := 162.5
const APPEAR_TIME = 1.0

var skin_tween : Tween
var direction : float = PI * (2.0 / 12)
var skin : Array
var locked : bool
var selected : bool
var bird

func _init():
    #texture_normal = preload('res://assets/circlebutton.png')
    #rect_scale = Vector2(0.6, 0.6)
    #rect_pivot_offset = rect_size / 2
    visible = false
    rect_position = CENTRE

func _ready():
    mask(self)

func add_bird(textures):
    bird = Bird.instance()
    bird.skin = skin[0]
    bird.textures = textures
    if bird.skin == 'random':
        bird.modulate = Globals.theme[0]
    bird.position = Vector2(50, 50)
    mask(bird)
    add_child(bird)
    move_child(bird, 0)
    if selected:
        yield(bird, 'ready')
        select(true)

func select(now_selected):
    selected = now_selected
    if selected:
        bird.get_node('Beak').open()
    else:
        bird.get_node('Beak').close()

func mask(node):
    if 'light_mask' in node:
        node.light_mask = LIGHT_MASK
    for i in node.get_children():
        mask(i)

func get_dest(distance):
    return CENTRE + Vector2(
        cos(direction) * distance,
        sin(direction) * distance
    )

func show():
    tween.interpolate_property(self, 'rect_position', get_dest(START_DISTANCE_FROM_CENTRE), get_dest(START_DISTANCE_FROM_CENTRE + ((END_DISTANCE_FROM_CENTRE - START_DISTANCE_FROM_CENTRE) * skin[2])), APPEAR_TIME, Tween.TRANS_BACK, Tween.EASE_OUT)
    tween.start()
    visible = true
    yield(tween, 'tween_completed')

func hide():
    tween.interpolate_property(self, 'rect_position', rect_position, get_dest(START_DISTANCE_FROM_CENTRE), APPEAR_TIME, Tween.TRANS_BACK, Tween.EASE_IN)
    tween.start()
    yield(tween, 'tween_completed')
    queue_free()

func _pressed():
    if locked:
        if Save.get('currency') < skin[1]:
            $Lock/AnimationPlayer.play('shake')
            return
        var skins_unlocked = Save.get('skins_unlocked')
        skins_unlocked.append(skin[0])
        Save.set('skins_unlocked', skins_unlocked)
        Save.set('currency', Save.get('currency') - skin[1])
        Save.save()
        locked = false
        $Lock/AnimationPlayer.play('unlock')
    emit_signal('select')
