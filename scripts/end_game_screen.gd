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

# a scene to control the end game screen.

signal restart_pressed
signal exit_pressed

# Called when the node enters the scene tree for the first time.
func _ready():
	$button_container/restart_button.connect("pressed", self, "on_restart_pressed")
	$button_container/exit_button.connect("pressed", self, "on_exit_pressed")


func set_score(s):
	$score_container/score_label.text = "%05d" % s

func on_restart_pressed():
	emit_signal("restart_pressed")

func on_exit_pressed():
	emit_signal("exit_pressed")
	
