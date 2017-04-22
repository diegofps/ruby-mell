facts do

    model 'Shopping' do
        plural 'Shoppings'
        property 'Id' do
            type 'int'
            autoincrement
            pk
        end
        property 'Nome' do
            type 'string'
        end
    end

    model 'Produto' do
        plural 'Produtos'
        property 'Id' do
            type 'int'
            autoincrement
            pk
        end
        property 'Nome' do
            type 'string'
        end
        property 'Compras' do
            type 'reference'
            hasMany 'Compras'
        end
    end


    model 'Cliente' do
        plural 'Clientes'
        property 'Id' do
            type 'int'
            autoincrement
            pk
        end
        property 'Nome' do
            type 'string'
        end
        property 'Compras' do
            type 'reference'
            hasMany 'Compras'
        end
    end


    model 'Compra' do
        plural 'Compras'
        property 'Produto' do
            type 'reference'
            hasOne 'Produto'
            pk
        end
        property 'Cliente' do
            type 'reference'
            hasOne 'Cliente'
            pk
        end
        property 'Quantidade' do
            type 'int'
            required
        end
        property 'Valor' do
            type 'double'
            required
        end
    end


    father 'Arnaldo', 'Diego'
    mother 'Elenice', 'Diego'

    father 'Arnaldo', 'Aline'
    mother 'Elenice', 'Aline'

    mother 'Aline', 'Kiron'
    father 'Fernando', 'Kiron'

    father 'Augusto', 'Fernando'
    mother 'Augusta', 'Fernando'

end

rules do

    requires_constructor :model do
        hasMany :model, :prop, :others
    end

    parent :x, :y do
        father :x, :y
    end

    parent :x, :y do
        mother :x, :y
    end

end

query.hasMany(:m, :x, :y) do |m, x, y|
  puts "HasMany: #{m}, #{x}, #{y}"
end

query.property('Shopping', :x) do |x|
    puts x
end

query.parent(:x, :y).father(:y, 'Kiron') do |x, y|
    puts "x:" + x + ", y:" + y
end
