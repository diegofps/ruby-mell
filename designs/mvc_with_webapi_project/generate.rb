# Expand the rules!

# Assures that:
# 1. Every model has a name and plural
Domain.models.each do |model|
  model.name = model._id.capitalize unless model.name?
  raise MellError, "Missing plural for #{model.cannonical_id}" unless model.plural?
end

# Assures that:
# 1. Every property has a name
# 2. Every reference has either hasMany or hasOne
# 3. Every hasOne and every hasMany have a reference_key
Domain.models.each do |model|
  model.properties.each do |prop|
    if prop.type == reference
      if prop.hasMany?
        prop.name is prop.hasMany.plural unless prop.name?
        prop.reference_key is prop.hasMany.name + "Id" unless prop.reference_key?
        
      elsif prop.hasOne?
        prop.name is prop.hasOne.name unless prop.name?
        prop.reference_key is prop.name + "Id" unless prop.reference_key?
        
      else
        raise MellError, "#{prop.cannonical_id} has type reference but not hasMany or hasOne"
      end
    end

    prop.name = prop._id.capitalize unless prop.name?
  end
end

# Assures that:
# 1. Every hasOne has an associated hasMany 
# 2. Every hasMany has an associated hasOne

# Method to check if there is a hasOne for the given hasMany
def hasAssociatedHasOne(prop)
  prop.hasMany.properties.each do |other_prop|
    next unless other_prop == prop.reference_key
    raise MellError, "Referenced objects mismatch between #{prop.cannonical_id} and #{other_prop.cannonical_id} " unless other.hasOne == prop._parent._parent
    return true
  end
  return false
end

# Method to check if there is a hasMany for the given hasOne
def hasAssociatedHasMany(prop)
  prop.hasOne.properties.each do |other_prop|
    next unless other_prop == prop.reference_key
    raise MellError, "Referenced objects mismatch between #{prop.cannonical_id} and #{other_prop.cannonical_id} " unless other.hasMany == prop._parent._parent
    return true
  end
  return false
end

# Detect which hasMany and which hasOne require a counterpart
hasOneTodos = []
hasManyTodos = []
Domain.models.each do |model|
  model.properties.each do |prop|
    next unless prop.type == :reference
    
    if prop.hasMany?
      hasManyTodos << prop unless hasAssociatedHasOne(prop)

    elsif prop.hasOne?
      hasOneTodos << prop unless hasAssociatedHasMany(prop)
    end

  end
end

# Create the missing hasOnes for the hasManys found
hasManyTodos.each do |prop|
  model = prop._parent._parent

  block = Proc.new do
    type is reference
    name is model.name.camel
    reference_key is prop.reference_key
    hasOne is model
    brother is prop
  end

  prop.brother is prop.hasMany.properties.method_missing(model._id.to_s.to_sym, &block) 
end

# Create the missing hasManys for the hasOnes found
hasOneTodos.each do |prop|
  model = prop._parent._parent

  block = Proc.new do
    type is reference
    name is model.plural.camel
    reference_key is prop.reference_key
    hasMany is model
    brother is prop
  end

  prop.brother is prop.hasOne.properties.method_missing(model._id.to_s.to_sym, &block)
end

# Set requires_constructor to true if the model has a hasMany
Domain.models.each do |model|
  model.properties.each do |prop|
    if prop.hasMany?
      model.requires_constructor is true
      break
    end
  end
end

# Create the files
Domain.models.each do |model|
  render_to_file 'model', "#{Domain.app_root}/#{Domain.project_name}/#{Domain.project_name}.Model/#{model.name.camel}.cs", model: model
  render_to_file 'configuration', "#{Domain.app_root}/#{Domain.project_name}/#{Domain.project_name}.Data/Configurations/#{model.name.camel}Configuration.cs", model: model
end
