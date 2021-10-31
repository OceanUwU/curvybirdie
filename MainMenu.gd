extends Control

var skin_select_menu : Control
var menu_transition : TextureRect

func _ready():
    skin_select_menu = get_node('../SkinSelectMenu')
    menu_transition = get_node('../MenuTransition')

func _on_PlayButton_pressed():
    if !get_parent().playing:
        get_parent().start_game(false)


func _on_SkinSelectButton_pressed():
    $Accent/SkinSelectButton.disabled = true
    $Accent/PlayButton.disabled = true
    menu_transition.transition(self, skin_select_menu, false)
    skin_select_menu.show_skins()
