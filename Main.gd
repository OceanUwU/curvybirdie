extends Node

const TEXT_SIZES = [null, 0.43, 0.3, 0.23, 0.15]
const COLOR_CHANGE_INTERVAL = 5
const THEMES = [
    [Color(0.73, 0.73, 0.73), Color(0.87, 0.87, 0.87)], #0
    [Color(0.84, 0.95, 0.82), Color(0.94, 1.00, 0.93)], #5
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
const THEME_CHANGE_TIME = 0.5

var score : int
var theme_tween

func _ready():
    theme_tween = $ThemeTween
    update_theme(0, 0.0)
    start_game()

func start_game():
    score = 0
    update_score_text()
    $Bird.start_game()

func update_score_text():
    $Score.text = str(score)
    $Score.rect_scale = Vector2(1, 1) * TEXT_SIZES[min(len(str(score)), len(TEXT_SIZES))]

func update_theme(s, transition_time):
    var theme = THEMES[min(floor(s / COLOR_CHANGE_INTERVAL), len(THEMES)-1)]
    theme_tween.interpolate_property($Background, 'color', $Background.color, theme[0], transition_time, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
    theme_tween.start()
    theme_tween.interpolate_property($Score, 'custom_colors/font_color', $Score.get('custom_colors/font_color'), theme[0], transition_time, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
    theme_tween.start()
    theme_tween.interpolate_property($Accent, 'color', $Accent.color, theme[1], transition_time, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
    theme_tween.start()

func _on_Bird_score():
    score += 1
    update_score_text()
    if score % COLOR_CHANGE_INTERVAL == 0:
        update_theme(score, THEME_CHANGE_TIME)
