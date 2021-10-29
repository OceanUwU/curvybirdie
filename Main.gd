extends Node

const TEXT_SIZES := [null, 0.43, 0.3, 0.23, 0.15]
const THEME_CHANGE_INTERVAL := 5
const THEMES := [
    [Color(0.73, 0.73, 0.73), Color(0.87, 0.87, 0.87)], #0
    [Color(0.84, 0.95, 0.82), Color(0.61, 0.96, 0.55)], #5
    [Color(0.82, 0.95, 0.93), Color(0.93, 1.00, 0.98)], #10
    [Color(1.00, 0.92, 0.92), Color(1.00, 0.82, 0.82)], #15
    [Color(0.53, 0.38, 0.54), Color(0.35, 0.29, 0.36)], #20
    [Color(0.33, 0.33, 0.55), Color(0.45, 0.49, 0.65)], #25
    [Color(0.18, 0.34, 0.30), Color(0.34, 0.51, 0.35)], #30
    [Color(0.84, 0.00, 0.78), Color(0.51, 0.00, 0.44)], #35
    [Color(0.81, 0.78, 0.00), Color(1.00, 1.00, 0.55)], #40
    [Color(0.40, 0.02, 0.02), Color(0.88, 0.00, 0.00)], #45
    [Color(0.11, 0.10, 0.13), Color(0.31, 0.31, 0.31)], #50
    [Color(0.09, 0.91, 0.25), Color(0.58, 0.07, 0.89)], #55
    [Color(0.00, 0.56, 0.50), Color(0.89, 0.65, 0.07)], #60
    [Color(0.33, 0.22, 0.02), Color(1.00, 0.61, 0.44)], #65
    [Color(1.00, 0.49, 0.96), Color(0.03, 0.00, 1.00)], #70
    [Color(0.11, 0.29, 0.00), Color(0.00, 0.11, 0.20)], #75
    [Color(0.62, 0.40, 0.00), Color(0.17, 0.07, 0.21)], #80
    [Color(0.17, 0.24, 0.24), Color(0.73, 0.16, 0.40)], #85
    [Color(0.09, 0.09, 0.09), Color(0.92, 0.92, 0.92)], #90
    [Color(0.17, 0.17, 0.17), Color(0.67, 0.73, 0.16)], #95
    [Color(0.00, 0.00, 0.00), Color(1.00, 0.00, 0.00)], #100
]
const THEME_CHANGE_TIME := 0.5

const MAIN_MENU_SHOW_TIME := 0.6

export (PackedScene) var Bird
var score : int
var spikes := []
var theme_tween
var menu_tween
var walls 
var bird
var playing := true

func _ready():
    walls = [$Walls/Right, $Walls/Left]
    spikes = get_tree().get_nodes_in_group('spikes')
    theme_tween = $ThemeTween
    menu_tween = $MenuTween
    $MainMenu.rect_scale = Vector2(0, 0)
    $MainMenu.modulate.a = 0
    $MenuTransition.visible = false
    update_theme(0, 0.0)
    start_game(true) #testin
    $SkinSelectMenu.rect_scale = Vector2(0, 0)
    #$SkinSelectMenu.show_skins(theme)

func start_game(first_game):
    playing = true
    score = 0
    update_score_text()
    
    if !first_game: 
        update_theme(score, MAIN_MENU_SHOW_TIME * 2)
        menu_tween.interpolate_property($MainMenu, 'modulate:a', 1.0, 0.0, MAIN_MENU_SHOW_TIME, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
        menu_tween.start()
        yield(menu_tween, 'tween_completed')
    
    walls[0].reset(score)
    walls[1].reset(score+1)
    if !first_game: 
        $MainMenu.rect_scale = Vector2(0, 0)
        menu_tween.interpolate_property($HUD, 'modulate:a', 0.0, 1.0, MAIN_MENU_SHOW_TIME, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
        menu_tween.start()
        yield(menu_tween, 'tween_completed')
    
    bird = Bird.instance()
    bird.connect('score', self, 'score_a_point')
    bird.connect('die', self, 'game_over')
    bird.position = Vector2(20, -50)
    bird.do_tutorial = first_game
    bird.skin = Save.get('skin_selected')
    add_child(bird)
    bird.start_game()

func update_score_text():
    $HUD/Score.text = str(score)
    $HUD/Score.rect_scale = Vector2(1, 1) * TEXT_SIZES[min(len(str(score)), len(TEXT_SIZES))]

func update_theme(s, transition_time):
    Globals.theme = THEMES[min(floor(s / THEME_CHANGE_INTERVAL), len(THEMES)-1)]
    theme_tween.interpolate_property($Background, 'color', $Background.color, Globals.theme[0], transition_time, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
    theme_tween.start()
    theme_tween.interpolate_property($HUD/Score, 'custom_colors/font_color', $HUD/Score.get('custom_colors/font_color'), Globals.theme[0], transition_time, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
    theme_tween.start()
    theme_tween.interpolate_property($Accent, 'color', $Accent.color, Globals.theme[1], transition_time, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
    theme_tween.start()
    for spike in spikes:
        var spike_polygon = spike.get_node('Polygon2D')
        theme_tween.interpolate_property(spike_polygon, 'color', spike_polygon.color, Globals.theme[1], transition_time, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)

func score_a_point():
    score += 1
    update_score_text()
    if score % THEME_CHANGE_INTERVAL == 0:
        update_theme(score, THEME_CHANGE_TIME)
    walls[int(bird.rightwards)].reset(score+1)

func game_over():
    playing = false
    bird = null
    
    #edit save
    Save.set('total_score', Save.get('total_score') + score)
    Save.set('lifetime_games_played', Save.get('lifetime_games_played') + 1)
    Save.set('currency', Save.get('currency') + score)
    Save.set('best', max(score, Save.get('best')))
    Save.save()
        
    menu_tween.interpolate_property($HUD, 'modulate:a', 1.0, 0.0, MAIN_MENU_SHOW_TIME, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
    menu_tween.start()
    yield(menu_tween, 'tween_completed')
    
    $MainMenu.rect_scale = Vector2(1, 1)
    $MainMenu/Accent/Score/Score.text = str(score)
    $MainMenu/Accent/Score/Best.text = str(Save.get('best'))
    $MainMenu/Primary.modulate = Globals.theme[0]
    $MainMenu/Accent.modulate = Globals.theme[1]
    menu_tween.interpolate_property($MainMenu, 'modulate:a', 0.0, 1.0, MAIN_MENU_SHOW_TIME, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
    menu_tween.start()
