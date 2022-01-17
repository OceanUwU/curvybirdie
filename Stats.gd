extends Control

func _on_BackButton_pressed():
    $BackButton.disabled = true
    get_node('../MenuTransition').transition(self, get_node('../MainMenu'), true)
    get_node('../MainMenu').set_buttons_disabled(false)

func update():
    $Accent/Normal/Best.text = str(Save.get('best_normal'))
    $Accent/Normal/TotalGames.text = str(Save.get('lifetime_games_played_normal'))
    $Accent/Normal/TotalScore.text = str(Save.get('total_score_normal'))
    if Save.get('lifetime_games_played_normal') > 0:
        $Accent/Normal/AverageScore.text = str(stepify(float(Save.get('total_score_normal')) / float(Save.get('lifetime_games_played_normal')), 0.01))
    else:
        $Accent/Normal/AverageScore.text = '0'
    $Accent/Hard/Best.text = str(Save.get('best_hard'))
    $Accent/Hard/TotalGames.text = str(Save.get('lifetime_games_played_hard'))
    $Accent/Hard/TotalScore.text = str(Save.get('total_score_hard'))
    if Save.get('lifetime_games_played_hard') > 0:
        $Accent/Hard/AverageScore.text = str(stepify(float(Save.get('total_score_hard')) / float(Save.get('lifetime_games_played_hard')), 0.01))
    else:
        $Accent/Hard/AverageScore.text = '0'
