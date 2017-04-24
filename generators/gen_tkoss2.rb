#!/usr/bin/env ruby

require './mell.rb'
include Mell

require './metadata/tkoss2.rb'

query.model(:model) do |model|
  render_to_file 'model', "./gen/models/#{model}.cs", model: model
  render_to_file 'configuration', "./gen/data/configurations/#{model}Configuration.cs", model: model
end
