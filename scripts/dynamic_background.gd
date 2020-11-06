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

# a scene depcting a dynamic background that changes with the timer
#
# NOTE: right now the time is not dynamic
# I could change it later.

const background_ghost = preload("res://scenes/enemies/background_ghost.tscn")

const background_library = ["desert1", "desert_lost_city", "forest_lost_city"]
const BACKGROUND_PATH = "res://images/backgrounds/%s.png"

# different states of the background.
enum STATES{
	PRE_START, # start pose before the game starts
	PLAYING, # the main animation is playing (day_to_night)
	REVERSE, # the animation "night_to_day" is playing
	STOP # the animation stopped
}

var state = STATES.PRE_START

signal reset_animation_finished # when night_to_day finished

# Called when the node enters the scene tree for the first time.
func _ready():
	$ghost_timer.connect("timeout", self, "summon_ghost")
	pick_background()

# sets a new random background from the library
func pick_background():
	randomize()
	var i = randi() % background_library.size()
	$background.texture = load(BACKGROUND_PATH % background_library[i])

# set the different states.
# NOTE: as a matter of prefernce I would like this method to be somewhat private
# the states can only be changed from inside this scene.
func set_state(st):
	if(st == STATES.PLAYING):
		state = STATES.PLAYING
		
		$anim.play("day_to_night")
		$ghost_timer.start()
	elif(st == STATES.STOP):
		state = STATES.STOP
		
		$anim.play("_night")
	elif(st == STATES.PRE_START):
		state = st
		
		$anim.play("rest_pos")
	elif(st == STATES.REVERSE):
		state = st
		
		$anim.play("night_to_day")

func start():
	set_state(STATES.PLAYING)

func stop():
	set_state(STATES.STOP)

func reset():
	set_state(STATES.REVERSE)
	
	yield($anim, "animation_finished")
	
	emit_signal("reset_animation_finished")

# summon ghost
func summon_ghost():
	var g = background_ghost.instance()
	g.global_position = Vector2(rand_range(0.0, 576), rand_range(595, 605) - 10.0)
	$ghosts.add_child(g)
	
	# set the next timer
	$ghost_timer.stop()
	$ghost_timer.wait_time = rand_range(1.0, 3.0)
	$ghost_timer.start()

func enrage_all_ghosts():
	for g in $ghosts.get_children():
		if g.has_method("enrage"):
			g.enrage()

func kill_all_ghosts():
	for g in $ghosts.get_children():
		if g.has_method("kill"):
			g.kill()
