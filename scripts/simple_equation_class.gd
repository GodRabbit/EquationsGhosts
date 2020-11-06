extends Node

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


class_name simple_equation_class

# represents simple linear with 1 unknown of the form
# ax+b = cx+d
# where x is the unknown, all of the other variables are whole numbers 
# (might be negative) and they are chosen so x is a whole number too

var factor_range = 10 # look at init, this will be the range for n
var solution_range = 15 # this will be the range for x

var a = 0
var x = 0
var b = 0
var c = 0
var d = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# creates a random equation with solution x
func _init():
	create_equation()

func create_equation():
	# the algorithm is as follows:
	# pick we will pick n*x = m
	# 1st step is to pick x
	# and we will split n and m, to create a, c and b, d
	# n will be chosen to be in the range -factor_range to +factor_range
	# while x will be any number between -solution_range to solution_range
	randomize()
	x = int(rand_range(-solution_range, solution_range))
	randomize()
	var n =  int(rand_range(-factor_range, factor_range))
	var m = n*x
	
	# split both m and n into sums:
	var n_split = _split(n)
	var m_split = _split(m)
	
	# now we have (n0 + n1)x= m0 + m1
	# which means that:
	a = n_split[0] # a = n0
	c = -n_split[1] # c = -n1
	b = -m_split[0] # b = -m0
	d = m_split[1] # d = m1


# takes the value of v, and return an array with 2 values, that both add to v
func _split(v : int):
	if(v != 0):
		var ab = int(abs(v/2.0))
		randomize()
		var a0 = int(rand_range(-ab, ab))
		var a1 = v - a0
		return [a0, a1]
	else: # if v is 0 we don't want to use the absoulte value
		randomize()
		var a0 = int(rand_range(0, factor_range))
		return [a0, -a0]

# check if s a solution:
# NOTE: DON'T BE TEMPTED TO CHECK AGAINST x!
# The equation may have infinite solutions, hence this method
# check is more general
func check_solution(s):
	return a*s + b == c*s + d


func _to_string():
	var f = get_equation_to_string() + "; x = %d"
	return f % x

# returns a beautiful expression of the equation,
# used for display
func get_equation_to_string():
	var s = ""
	if(!(a == 0 and b == 0)): # if a== 0 and b == 0, then the left side is just 0
		s += _element_to_str(a, true)
		s += _element_to_str(b)
	else:
		s += "0"
	s += " = "
	if(!(c == 0 and d == 0)): # if c == 0 and d == 0, then the right side is just 0
		s += _element_to_str(c, true)
		s += _element_to_str(d)
	else:
		s += "0"
	return s

# create 1 expression into a string
# for examples: 
# _element_to_str(7, false) -> "+7"
# _element_to_str(-3, true) -> "-3x"
static func _element_to_str(val, has_unknown = false):
	var s = ""
	# add the sign:
	if(val > 0):
		s+= "+"
	elif(val < 0):
		s+= "-"
	else:
		return "" # if value is 0, just return empty
	
	# add the abs val:
	if(int(abs(val)) != 1 or !has_unknown):
		s += str(int(abs(val)))
	
	# if there's unknown add it too:
	if(has_unknown):
		s += "x"
	
	return s
