extends Node2D

#	Copyright 2020  Dor "GodRabbit" Shlush
# This file is part of "EquationsGhosts".
#
#    "EquationsGhosts" is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    "EquationsGhosts" is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with "EquationsGhosts".  If not, see <https://www.gnu.org/licenses/>.
#
#	Copyright 2020  Dor "GodRabbit" Shlush

# main scene of the game.
# once the player hit start, the timer starts, and the player must submit
# the solution to each equation that pop on the screen.
# after the time is over, the score is displayed to the player

enum GAME_STATES{
	PRE_START, # before the player pressed start
	PLAYING, # the timer is running and the player is solving Equations
	GAME_OVER # the timer ended, waiting for player response
}

#const GAME_STATE_PRE_START = "prestart"
#const GAME_STATE_PLAYING = "playing"
#const GAME_STATE_GAME_OVER = "game_over"


const correct_score = 15 # how many points you get for correct answer
const incorrect_score = 10 # how much score you lose on incorrect answer
const max_score = 99999
var score = 0
var time = 300 # seconds

var game_state = GAME_STATES.PRE_START

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process_input(true)
	
	# set signals connections:
	$canvas_layer/start_button.connect("pressed", self, "on_start_pressed")
	$timer.connect("timeout", self, "subtract_timer")
	$canvas_layer/equation_displayer.connect("correct_submitted", self, "on_correct_submitted")
	$canvas_layer/equation_displayer.connect("incorrect_submitted", self, "on_incorrect_submitted")
	$canvas_layer/end_game_screen.connect("restart_pressed", self, "restart_game")
	$canvas_layer/end_game_screen.connect("exit_pressed", self, "exit_game")
	
	set_game_state(GAME_STATES.PRE_START)

func _input(event):
	if(event.is_action_pressed("ui_accept") and game_state == GAME_STATES.PLAYING):
		$canvas_layer/equation_displayer.on_submit_pressed()
	if(event.is_action_pressed("ui_cancel")):
		# on the game running, it moves to the end game screen:
		if(game_state == GAME_STATES.PLAYING):
			set_game_state(GAME_STATES.GAME_OVER)
		elif(game_state == GAME_STATES.PRE_START || game_state == GAME_STATES.GAME_OVER):
			exit_game()
	if(event.is_action_pressed("t_debug")):
		for i in range(0, 20):
			subtract_timer()
			

# sets the game state: hide\show the relevant guis and do preperations for the next stage
func set_game_state(state):
	if(state == GAME_STATES.PRE_START):
		# if there was a game over before that, pause
		# until the background animation finished:
		if(game_state == GAME_STATES.GAME_OVER):
			$dynamic_background.reset()
			get_tree().paused = true
			yield($dynamic_background, "reset_animation_finished")
			get_tree().paused = false
		
		# show and hide the relevant controls:
		$canvas_layer/start_button.show()
		$canvas_layer/equation_displayer.hide()
		$canvas_layer/end_game_screen.hide()
		
		# setup pre game starting
		game_state = GAME_STATES.PRE_START
		
		# set the vars:
		set_score(0)
		time = 300
	elif(state == GAME_STATES.PLAYING):
		# set the game state:
		game_state = GAME_STATES.PLAYING
		
		# hide start_button and show the eq displayer:
		$canvas_layer/start_button.hide()
		$canvas_layer/end_game_screen.hide()
		$canvas_layer/equation_displayer.show()
		
		# start the background:
		$dynamic_background.start()
	elif(state == GAME_STATES.GAME_OVER):
		game_state = state
		# stops the timer, and show the end game screen
		$timer.stop()
		
		$canvas_layer/end_game_screen.set_score(score)
		$canvas_layer/start_button.hide()
		$canvas_layer/end_game_screen.show()
		$canvas_layer/equation_displayer.hide()
		
		$dynamic_background.stop()

func set_new_equation():
	$canvas_layer/equation_displayer.set_equation(simple_equation_class.new())

func set_score(s):
	if(s > max_score):
		score = max_score
	elif(s < 0):
		score = 0
	else:
		score = s
	_update_score()

func add_to_score(v):
	set_score(score + v)

func subtract_timer():
	time = time - 1
	if(time <= 0):
		set_game_state(GAME_STATES.GAME_OVER)
	_update_time()

# updates the gui score element
func _update_score():
	$canvas_layer/score_container/score_label.text = "%05d" % score

# updates the timer gui element
func _update_time():
	$canvas_layer/timer_container/timer_label.text = "%03d" % time

func on_start_pressed():
	set_game_state(GAME_STATES.PLAYING)
	
	# start timer:
	$timer.start()
	
	# set new equation:
	set_new_equation()

# When a correct answer submitted through the equation displayer
func on_correct_submitted():
	play_audio("res://sounds/sfx/powerUp7.ogg")
	add_to_score(correct_score)
	$dynamic_background.kill_all_ghosts()
	set_new_equation()

# When a incorrect answer submitted through the equation displayer
func on_incorrect_submitted():
	play_audio("res://sounds/sfx/lowThreeTone.ogg")
	add_to_score(-incorrect_score)
	$dynamic_background.enrage_all_ghosts()
	set_new_equation()

func restart_game():
	set_game_state(GAME_STATES.PRE_START)

func exit_game():
	get_tree().quit()

func play_audio(file_name):
	var s = load(file_name)
	s.loop = false
	$audio_stream.stream = s
	$audio_stream.play()
	
