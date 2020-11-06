extends RigidBody2D

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

# a scene controlling a background ghost that appear in the back.
# the ghosts move up, when they enrage they change their sprite,
# and when they "die", they fall and disappear [?? or maybe just fade out? or both?]

const image_path = "res://images/enemies/ghost%d_%s.png"

 # how big can the ghosts be
const scale_range = [0.75, 1.5]

# how many ghosts there are to choose from
const ghosts_ids = 3

# the three states of the ghosts:
enum STATES{
	NORMAL, # normal, the ghost just chill
	ENRAGED, # the player made a mistake and now the ghosts are pissed
	DEAD # the player answer correctly and now the ghost die
}

var state = STATES.NORMAL

var ghost_id = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	# pick a ghost id at random
	randomize()
	ghost_id = randi() % ghosts_ids
	set_state(STATES.NORMAL)
	
	# every time the ghost is enrages, the timer is starting, and after it ends, 
	# the ghost goes back to normal
	$enrage_timer.connect("timeout", self, "enrage_over")
	
	# after 60 seconds kill the ghost no matter what (prevent clogging)
	$life_timer.connect("timeout", self, "insta_kill")
	
	# randomly choose the flip of the sprite
	randomize()
	var n = randi() % 2
	if(n == 0):
		$sprite.flip_h = true 
	
	randomize()
	var s = rand_range(scale_range[0], scale_range[1])
	$sprite.scale = s*$sprite.scale

func set_state(st):
	if(state == STATES.DEAD): # if the ghost died it cannot revive
		return
	if(st == STATES.NORMAL):
		randomize()
		gravity_scale = -rand_range(0.1, 0.7)
		state = st
		$sprite.texture = load(image_path % [ghost_id, "idle"])
	elif(st == STATES.ENRAGED):
		state = st
		$sprite.texture = load(image_path % [ghost_id, "mad"])
		$enrage_timer.start()
	elif(st == STATES.DEAD):
		state = st
		$sprite.texture = load(image_path % [ghost_id, "dead"])
		$sprite.flip_v = true
		gravity_scale = 2.0
		$anim.play("death")
		yield($anim, "animation_finished")
		insta_kill()

# called when enrage is over
func enrage_over():
	set_state(STATES.NORMAL)

func enrage():
	set_state(STATES.ENRAGED)

func kill():
	set_state(STATES.DEAD)

# kill without the animation and the falling
func insta_kill():
	queue_free()
