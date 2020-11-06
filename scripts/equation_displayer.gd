extends Control

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

# A scene with a control used for displaying the equation and the relevant controls.

var equation : simple_equation_class

signal correct_submitted # emitted when the answer submitted is correct
signal incorrect_submitted # emitted when the answer submitted is incorrect

# Called when the node enters the scene tree for the first time.
func _ready():
	$main_container/submit_button.connect("pressed", self, "on_submit_pressed")
	
	# a timer that randomly fire and create a shine effect on the sprite with "anim"
	$shine_timer.connect("timeout", self, "on_shine_timeout")

func set_equation(eq : simple_equation_class):
	equation = eq
	update_gui()

func get_equation():
	return equation

func update_gui():
	$main_container/eq_label.text = equation.get_equation_to_string()
	$main_container/line_edit.text = ""
	if(!$main_container/line_edit.has_focus()):
		$main_container/line_edit.grab_focus()

func on_submit_pressed():
	# check if the answer is correct:
	var answer = $main_container/line_edit.text
	if(answer.is_valid_integer()):
		var ans_int = int(answer) 
		if(equation.check_solution(ans_int)):
			emit_signal("correct_submitted")
			return true
		else:
			emit_signal("incorrect_submitted")
			return false
	else:
		emit_signal("incorrect_submitted")
		return false

func on_shine_timeout():
	$anim.play("idle0")
	# randomize the next time frame for shining:
	randomize()
	$shine_timer.wait_time = rand_range(1.0, 6.0)
	$shine_timer.start()
