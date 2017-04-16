#!/usr/bin/env ruby

require './logic.rb'

################# The Environment #################

Metadata = Logic.new

################# Facts #################

puts "Defining the rules"

Metadata.father('Arnaldo', 'Diego').save
Metadata.father('Arnaldo', 'Aline').save
Metadata.mother('Elenice', 'Diego').save
Metadata.mother('Elenice', 'Aline').save

Metadata.parent(:x,:y) do
    father(:x, :y)
end

Metadata.parent(:x,:y) do
    mother(:x, :y)
end

################# Queries #################

puts "Searching for mothers"

Metadata.mother(:x, :y).each do |x, y|
    puts x + " & " + y
end

puts "Searching for parents"

Metadata.parent(:x, :y).each do |x, y|
    puts x + " & " + y
end

puts "Is Arnaldo a father? " + if Metadata.father('Arnaldo', :j).possible? then 'Yes' else 'No' end
puts "Is Arnaldo a mother? " + if Metadata.mother('Arnaldo', :j).possible? then 'Yes' else 'No' end


