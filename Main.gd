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

const NORMAL_ACHIEVEMENTS := ['CgkIqLj8oPITEAIQBQ', 'CgkIqLj8oPITEAIQBg', 'CgkIqLj8oPITEAIQBw', 'CgkIqLj8oPITEAIQCA', 'CgkIqLj8oPITEAIQEg', 'CgkIqLj8oPITEAIQCg']
const NORMAL_LEADERBOARD := 'CgkIqLj8oPITEAIQDw'
const HARD_ACHIEVEMENTS := ['CgkIqLj8oPITEAIQCw', 'CgkIqLj8oPITEAIQDA', 'CgkIqLj8oPITEAIQDQ', 'CgkIqLj8oPITEAIQDg']
const HARD_LEADERBOARD := 'CgkIqLj8oPITEAIQEA'
const BIRD_ACHIEVEMENTS := ['CgkIqLj8oPITEAIQAA', 'CgkIqLj8oPITEAIQAQ', 'CgkIqLj8oPITEAIQAg', 'CgkIqLj8oPITEAIQAw', 'CgkIqLj8oPITEAIQBA']
const HUESHIFT_ACHIEVEMENT := 'CgkIqLj8oPITEAIQCQ'

export (PackedScene) var Bird
var score : int
var theme_tween
var menu_tween
var walls 
var bird
var playing := true
var hard : bool

var play_games_services

func _ready():
    randomize()
    walls = [$Walls/Right, $Walls/Left]
    theme_tween = $ThemeTween
    menu_tween = $MenuTween
    $MainMenu.rect_scale = Vector2(0, 0)
    $MainMenu.modulate.a = 0
    $MenuTransition.visible = false
    update_theme(0, 0.0)
    start_game(true) #testin
    $SkinSelectMenu.rect_scale = Vector2(0, 0)
    $Stats.rect_scale = Vector2(0, 0)
    #$SkinSelectMenu.show_skins(theme)
    
    #google play services
    if Engine.has_singleton("GodotPlayGamesServices"):
        play_games_services = Engine.get_singleton("GodotPlayGamesServices")
        play_games_services.init(true,false,false,"")
        play_games_services.signIn()

func play_ready():
    return typeof(play_games_services) != 0 && play_games_services.isSignedIn()

func start_game(first_game):
    playing = true
    score = 0
    hard = Save.get('mode_is_hard')
    update_score_text()
    
    if !first_game: 
        update_theme(score, MAIN_MENU_SHOW_TIME * 2)
        menu_tween.stop_all()
        menu_tween.interpolate_property($MainMenu, 'modulate:a', $MainMenu.modulate.a, 0.0, MAIN_MENU_SHOW_TIME, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
        menu_tween.start()
        yield(menu_tween, 'tween_completed')
    
    walls[0].reset(score)
    walls[1].reset(score+1)
    if !first_game: 
        $MainMenu.rect_scale = Vector2(0, 0)
        menu_tween.interpolate_property($HUD, 'modulate:a', 0.0, 1.0, MAIN_MENU_SHOW_TIME, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
        menu_tween.start()
        yield(menu_tween, 'tween_completed')
    
    var skin = Save.get('skin_selected')
    var skins_unlocked = Save.get('skins_unlocked')
    if skin == 'random':
        if randi() % 200 != 0:
            while skin == 'random':
                skin = skins_unlocked[randi() % len(skins_unlocked)]
    
    bird = Bird.instance()
    bird.connect('score', self, 'score_a_point')
    bird.connect('die', self, 'game_over')
    bird.position = Vector2(20, -50)
    bird.do_tutorial = first_game
    bird.skin = skin
    add_child(bird)
    bird.start_game(hard)

func update_score_text():
    $HUD/Score.text = str(score)
    $HUD/Score.rect_scale = Vector2(1, 1) * TEXT_SIZES[min(len(str(score)), len(TEXT_SIZES))]

func update_theme(s, transition_time, main_menu=false):
    Globals.theme = THEMES[min(floor(s / THEME_CHANGE_INTERVAL), len(THEMES)-1)]
    theme_tween.interpolate_property($Background, 'color', $Background.color, Globals.theme[0], transition_time, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
    theme_tween.start()
    theme_tween.interpolate_property($HUD/Score, 'custom_colors/font_color', $HUD/Score.get('custom_colors/font_color'), Globals.theme[0], transition_time, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
    theme_tween.start()
    theme_tween.interpolate_property($Accent, 'color', $Accent.color, Globals.theme[1], transition_time, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
    theme_tween.start()
    theme_tween.interpolate_property($Walls, 'modulate', $Walls.modulate, Globals.theme[1], transition_time, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
    theme_tween.start()
    if main_menu:
        theme_tween.interpolate_property($MainMenu/Primary, 'modulate', $MainMenu/Primary.modulate, Globals.theme[0], transition_time, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
        theme_tween.start()
        theme_tween.interpolate_property($MainMenu/Accent, 'modulate', $MainMenu/Accent.modulate, Globals.theme[1], transition_time, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
        theme_tween.start()
    
func score_a_point():
    if bird:
        score += 1
        update_score_text()
        if score % THEME_CHANGE_INTERVAL == 0:
            update_theme(score, THEME_CHANGE_TIME)
        walls[int(bird.rightwards)].reset(score+1)

func game_over():
    playing = false
    bird = null
    for i in walls:
        i.tween.remove_all()
    
    #edit save
    var mode_suffix = '_hard' if hard else '_normal'
    Save.set('total_score'+mode_suffix, Save.get('total_score'+mode_suffix) + score)
    Save.set('lifetime_games_played'+mode_suffix, Save.get('lifetime_games_played'+mode_suffix) + 1)
    Save.set('currency', Save.get('currency') + score)
    Save.set('previous_score'+mode_suffix, score)
    Save.set('best'+mode_suffix, max(score, Save.get('best'+mode_suffix)))
    Save.save()
        
    menu_tween.interpolate_property($HUD, 'modulate:a', 1.0, 0.0, MAIN_MENU_SHOW_TIME, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
    menu_tween.start()
    yield(menu_tween, 'tween_completed')
    
    $MainMenu.rect_scale = Vector2(1, 1)
    $MainMenu/Accent/Score/Score.text = str(score)
    $MainMenu/Accent/Score/Best.text = str(Save.get('best'+mode_suffix))
    $MainMenu/Primary.modulate = Globals.theme[0]
    $MainMenu/Accent.modulate = Globals.theme[1]
    menu_tween.interpolate_property($MainMenu, 'modulate:a', 0.0, 1.0, MAIN_MENU_SHOW_TIME, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
    menu_tween.start()
    $MainMenu.set_buttons_disabled(false)
    
    if play_ready():
        play_games_services.submitLeaderBoardScore(HARD_LEADERBOARD if hard else NORMAL_LEADERBOARD, score)
        for i in (HARD_ACHIEVEMENTS if hard else NORMAL_ACHIEVEMENTS):
            play_games_services.setAchievementSteps(i, score)

func unlock_hue_shift():
    if play_ready():
        play_games_services.unlockAchievement(HUESHIFT_ACHIEVEMENT)

func unlock_skin():
    if play_ready():
        for i in BIRD_ACHIEVEMENTS:
            play_games_services.setAchievementSteps(i, len(Save.get('skins_unlocked')))

func show_leaderboards():
    if play_ready():
        play_games_services.showLeaderBoard(HARD_LEADERBOARD if Save.get('mode_is_hard') else NORMAL_LEADERBOARD)

func show_achievements():
    if play_ready():
        play_games_services.showAchievements()
