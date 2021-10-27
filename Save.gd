extends Node

const SAVE_PATH = 'user://save.dat'

var save_file : File
var data := {}

func _init():
    read()

func read():
    #read default data
    var default_data = preload('res://DefaultSave.gd').DEFAULT_DATA

    #read saved data
    save_file = File.new()
    save_file.open(SAVE_PATH, File.READ)
    var saved_data = save_file.get_var(true)
    if saved_data == null: #if the save data file is empty
        saved_data = {} #set our save to an empty dictionary (we will populate it in a second)
    save_file.close()

    for i in default_data: #for each property defined in default data
        data[i] = (saved_data if i in saved_data else default_data)[i] #set it to the saved value if there is one, otherwise use the default
    save()

func save():
    save_file.open(SAVE_PATH, File.WRITE)
    save_file.store_var(data, true)
    save_file.close()

func get(property):
    return data[property]

func set(property, value):
    data[property] = value
