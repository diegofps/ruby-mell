
cliente  = { name: :Cliente,  plural: :Clientes  }
compra   = { name: :Compra,   plural: :Compras   }
shopping = { name: :Shopping, plural: :Shoppings }
produto  = { name: :Produto,  plural: :Produtos  }

shopping[:properties] = [
    { name: :Id, type: :int, pk: true, autoincrement: true },
    { name: :Nome, type: :string }
]

cliente[:properties] = [
    { name: :Id, type: :int, pk: true, autoincrement: true },
    { name: :Nome, type: :string, len: 20 },
    { name: :Compras, type: :reference, hasMany: compra }
]

produto[:properties] = [
    { name: :Id, type: :int, pk: true, autoincrement: true },
    { name: :Nome, type: :string, len: 128 },
    { name: :Compras, type: :reference, hasMany: compra }
]

compra[:properties] = [
    { name: :Produto, type: :reference, hasOne: produto, pk: true },
    { name: :Cliente, type: :reference, hasOne: cliente, pk: true },
    { name: :Quantidade, type: :int, required: true },
    { name: :Valor, type: :double, required: true }
]

=begin
Metadata.facts do

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
            type: 'double'
            required
        end
    end

end

Metadata.rules do 
    
    parent :x, :y do
        father :x, :y
    end
    
    parent :x, :y do
        mother :x, :y
    end
    
end


Metadata.property('Shopping', :x).each do |m, x|
    
end

=end
