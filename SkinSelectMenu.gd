extends Control

const SKINS = [ #[name, price, layer, angle]
    ['default', 0, 1, 0.0/13],
    ['defaultgreen', 5, 1, 1.0/13],
    ['defaultdarkblue', 5, 1, 2.0/13],
    ['defaultblue', 5, 1, 3.0/13],
    ['defaultpurple', 5, 1, 4.0/13],
    ['defaultmagenta', 5, 1, 5.0/13],
    ['defaultpink', 5, 1, 6.0/13],
    ['defaultred', 5, 1, 7.0/13],
    ['defaultorange', 5, 1, 8.0/13],
    ['defaultbrown', 5, 1, 9.0/13],
    ['defaultblack', 5, 1, 10.0/13],
    ['defaultwhite', 5, 1, 11.0/13],
    ['defaultyellow', 5, 1, 12.0/13],
    
    ['angel', 0, 2, 18.0/20],
    ['demon', 0, 2, 19.0/20],
    ['water', 500, 2, 0.0/20],
    ['flowerbush', 0, 2, 1.0/20],
    ['default16', 0, 2, 2.0/20],
    ['default17', 0, 2, 8.0/20],
    ['default18', 0, 2, 9.0/20],
    ['default19', 0, 2, 11.0/20],
    ['default20', 0, 2, 12.0/20],
    
    ['default21', 0, 3, 24.0/26],
    ['default22', 0, 3, 25.0/26],
    ['default23', 0, 3, 0.0/26],
    ['default24', 0, 3, 1.0/26],
    ['default25', 0, 3, 2.0/26],
    ['default26', 0, 3, 11.0/26],
    ['default27', 0, 3, 12.0/26],
    ['default28', 0, 3, 14.0/26],
    ['default29', 0, 3, 15.0/26],
    
    ['default30', 0, 4, 24.2/26],
    ['default31', 0, 4, 1.8/26],
    ['floob', 0, 4, 11.2/26],
    ['random', 40, 3.5, 1.0/2],
    ['default34', 0, 4, 14.8/26],
]
const TIME_UNTIL_SKINS_SHOWED := 0.7
const TIME_TO_SHOW_ALL_BUTTONS := 1.2
const TIME_FROM_HIDING_TO_TRANSITION := 1.9
const DESELECTED_DARKEN_AMOUNT := 0.8
const BUTTON_ALPHA_CHANGE_TIME := 0.3

export (PackedScene) var SkinButton
var buttons := []
var button_selected
var main_menu : Control
var menu_transition : TextureRect

func _ready():
    main_menu = get_node('../MainMenu')
    menu_transition = get_node('../MenuTransition')

func show_skins():
    $Currency.text = str(Save.get('currency'))
    $Currency.modulate = Globals.theme[0]
    $BackButton.modulate = Globals.theme[1]
    $BackButton.disabled = true
    
    yield(get_tree().create_timer(menu_transition.CLOSE_TIME + menu_transition.ALPHA_TRANSITION_TIME * 2 + TIME_UNTIL_SKINS_SHOWED), 'timeout')
        
    var skin_selected = Save.get('skin_selected')
    var skins_unlocked = Save.get('skins_unlocked')
    for i in range(len(SKINS)):
        var skin = SKINS[i]
        var button = SkinButton.instance()
        button.skin = skin
        button.direction = PI * (2.0 * skin[3] - 0.5)
        button.self_modulate = Globals.theme[1]
        if skin_selected == skin[0]:
            button_selected = button
        else:
            button.self_modulate = Globals.theme[1].linear_interpolate(Globals.theme[0], DESELECTED_DARKEN_AMOUNT)
        button.locked = !(skin[0] in skins_unlocked)
        if button.locked:
            button.get_node('Lock/Padlock/Price').text = str(skin[1])
        else:
            button.get_node('Lock').queue_free()
        button.connect('select', self, 'select_skin', [button])
        button.add_bird()
        add_child(button)
        buttons.append(button)
    #for button in buttons:
        button.show()
        yield(get_tree().create_timer(TIME_TO_SHOW_ALL_BUTTONS / len(SKINS)), 'timeout')
    
    $BackButton.disabled = false

func select_skin(button):
    $Currency.text = str(Save.get('currency'))
    Save.set('skin_selected', button.skin[0])
    Save.save()
    $Tween.interpolate_property(button_selected, 'self_modulate', button_selected.self_modulate, Globals.theme[1].linear_interpolate(Globals.theme[0], DESELECTED_DARKEN_AMOUNT), BUTTON_ALPHA_CHANGE_TIME, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
    $Tween.start()
    button_selected = button
    $Tween.interpolate_property(button_selected, 'self_modulate', button_selected.self_modulate, Globals.theme[1], BUTTON_ALPHA_CHANGE_TIME, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
    $Tween.start()

func hide_skins():
    for i in range(len(buttons)-1, -1, -1):
        var button = buttons[i]
        button.disabled = true
        button.hide()
        yield(get_tree().create_timer(TIME_TO_SHOW_ALL_BUTTONS / len(SKINS)), 'timeout')
    buttons = []

func _on_BackButton_pressed():
    $BackButton.disabled = true
    hide_skins()
    yield(get_tree().create_timer(TIME_FROM_HIDING_TO_TRANSITION), 'timeout')
    menu_transition.transition(self, main_menu, true)
    var skin_select_button = main_menu.get_node('Accent/SkinSelectButton')
    main_menu.get_node('Accent/PlayButton').disabled = false
    skin_select_button.disabled = false
    skin_select_button._on_CircleButton_mouse_exited()
