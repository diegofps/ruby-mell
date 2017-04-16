load './mell.rb'
load './metadata/entities.rb'

Metadata.model(:entity).each do |entity|
  Mell.render_to_file 'class', "./gen/models/#{entity.get(:name)}.cs", entity: entity
end
