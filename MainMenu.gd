extends Control

#const NORMAL_BUTTON_TEXTURE = preload('res://assets/normalbutton.png')
#const HARD_BUTTON_TEXTURE = preload('res://assets/hardbutton.png')
const NORMAL_ICON_TEXTURE = preload('res://assets/normalicon.png')
const HARD_ICON_TEXTURE = preload('res://assets/hardicon.png')

var skin_select_menu : Control
var stats : Control
var menu_transition : TextureRect

func _ready():
    skin_select_menu = get_node('../SkinSelectMenu')
    stats = get_node('../Stats')
    menu_transition = get_node('../MenuTransition')
    update_mode_texture()

func _on_PlayButton_pressed():
    if !get_parent().playing:
        get_parent().start_game(false)


func _on_SkinSelectButton_pressed():
    set_buttons_disabled(true)
    menu_transition.transition(self, skin_select_menu, false)
    skin_select_menu.show_skins()

func _on_ModeChanger_pressed():
    var hard = !Save.get('mode_is_hard')
    Save.set('mode_is_hard', hard)
    Save.save()
    update_mode_texture()

func update_mode_texture():
    var hard = Save.get('mode_is_hard')
    $Accent/Score/ModeIndicator.texture = HARD_ICON_TEXTURE if hard else NORMAL_ICON_TEXTURE
    #$Accent/ModeChanger.texture_normal = HARD_BUTTON_TEXTURE if hard else NORMAL_BUTTON_TEXTURE
    var mode_suffix = '_hard' if hard else '_normal'
    $Accent/Score/Score.text = str(Save.get('previous_score'+mode_suffix))
    $Accent/Score/Best.text = str(Save.get('best'+mode_suffix))


func _on_StatsButton_pressed():
    set_buttons_disabled(true)
    stats.get_node('BackButton').modulate = Globals.theme[0]
    stats.get_node('BackButton').disabled = false
    stats.get_node('Accent').modulate = Globals.theme[1]
    stats.update()
    menu_transition.transition(self, stats, false)

func set_buttons_disabled(disabled):
    $Accent/SkinSelectButton.disabled = disabled
    $Accent/PlayButton.disabled = disabled
    $Accent/StatsButton.disabled = disabled
