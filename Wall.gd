extends Node2D

const SPIKE_HEIGHT := 80.0
const SPIKE_AMOUNT := 9
const INITIAL_SPIKES := 2
const FINAL_SPIKES := 8
const HARD_SPIKE_AMOUNT := 10
const HARD_EXTRA_SPIKES := HARD_SPIKE_AMOUNT - SPIKE_AMOUNT
const HARD_INITIAL_SPIKES := 4
const HARD_FINAL_SPIKES := 8
const HARD_SLIDE_TIME := 0.84

export (PackedScene) var Spike
var spikes := []
var initial_y
var tween
var down : bool
var hard : bool

func _ready():
    initial_y = position.y
    tween = $Tween
    
    for i in range(max(SPIKE_AMOUNT, HARD_SPIKE_AMOUNT)):
        var spike = Spike.instance()
        spike.position.y = SPIKE_HEIGHT * i
        add_child(spike)
        spikes.append(spike)

func reset(score):
    if score <= 1: #if first reset
        hard = Save.get('mode_is_hard')
        if hard:
            down = true
            _on_Tween_tween_all_completed()
        else:
            $ResetTween.interpolate_property(self, 'position:y', position.y, initial_y, spikes[0].ENABLE_TIME, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
            $ResetTween.start()
    
    var spike_amount = HARD_SPIKE_AMOUNT if hard else SPIKE_AMOUNT
    var final_spikes = HARD_FINAL_SPIKES if hard else FINAL_SPIKES
    var initial_spikes = HARD_INITIAL_SPIKES if hard else INITIAL_SPIKES
    var spike_num = int(floor(min(1.0, score / Globals.FINAL_SCORE) * (final_spikes - initial_spikes)) + initial_spikes) #number of spikes to spawn
    
    var spikes_enabled = range(spike_amount)
    var spikes_left = spike_amount - spike_num
    while spikes_left > 0:
        var spike_to_remove = randi() % len(spikes_enabled)
        if spike_amount - spike_num == 1 && spike_amount - spikes_enabled[spike_to_remove] - 1 <= 1: #if there is only 1 spike to remove, make sure it's not one of the bottom two
            continue
        spikes_enabled.remove(spike_to_remove)
        spikes_left -= 1
    
    enable(spikes_enabled)

func enable(spikes_enabled):
    for i in range(len(spikes)):
        spikes[i].set_enabled(i in spikes_enabled)
        
func clear():
    enable([])

func _on_Tween_tween_all_completed():
    tween.interpolate_property(self, 'position:y', position.y, initial_y-(SPIKE_HEIGHT*HARD_EXTRA_SPIKES if down else 0.0), HARD_SLIDE_TIME, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
    tween.start()
    down = !down
