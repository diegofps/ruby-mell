require './mell.rb'
include Mell

require './metadata/entities.rb'

query.model(:entity) do |entity|
  render_to_file 'model', "./gen/models/#{entity}.cs", entity: entity
end
