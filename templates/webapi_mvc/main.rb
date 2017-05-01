Config.project_name = query.project_name(:x).first!

query.model(:model) do |model|
  render_to_file 'model', "#{Config.app_root}/#{Config.project_name}/#{Config.project_name}.Model/#{model}.cs", model: model
  render_to_file 'configuration', "#{Config.app_root}/#{Config.project_name}/#{Config.project_name}.Data/Configurations/#{model}Configuration.cs", model: model
end
