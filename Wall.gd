extends Node2D

const SPIKE_AMOUNT := 9
const SPIKE_HEIGHT := 80.0
const INITIAL_SPIKES := 2
const FINAL_SPIKES := 8

export (PackedScene) var Spike
var spikes := []

func _ready():
    randomize()
    for i in range(SPIKE_AMOUNT):
        var spike = Spike.instance()
        spike.position.y = SPIKE_HEIGHT * i
        add_child(spike)
        spikes.append(spike)

func reset(score):
    var spike_num = int(floor(min(1.0, score / Globals.FINAL_SCORE) * (FINAL_SPIKES - INITIAL_SPIKES)) + INITIAL_SPIKES) #number of spikes to spawn
    
    var spikes_enabled = spikes.duplicate()
    for i in range(SPIKE_AMOUNT - spike_num):
        var spike_disabling = randi() % (SPIKE_AMOUNT - i)
        spikes_enabled[spike_disabling].set_enabled(false)
        spikes_enabled.remove(spike_disabling)
        
    for i in spikes_enabled:
        i.set_enabled(true)
        
