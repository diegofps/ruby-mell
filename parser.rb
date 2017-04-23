#!/usr/bin/env ruby

require 'byebug'
require './mellparser.rb'

entity = "ClassName"
constructor = [["plural1", "other1"], ["plural2", "other2"]]
properties = [["plural1", "reference"], ["plural2", "type2"]]

input = File.read("template.mell.rb")
puts input
puts "-------------------------------------------------------------------------"

puts MellParser.result(input, binding)
puts "-------------------------------------------------------------------------"
