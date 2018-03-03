=begin
def hasMany(reference_key, name, other, other_name)
    byebug
    a=10
end
=end

Domain.project_name is 'SimpleStore'
Domain.models do

    compra is nil
    
    produto do
        name is 'Produto'
        plural is 'Produtos'
        properties do
            id do
                type is int
                autoincrement is true
                pk is true
            end
            nome do
                type is string
            end
            vendas do
                type is reference
                hasMany Domain.models.compra
            end
        end
    end

    cliente do
        name is 'Cliente'
        plural is 'Clientes'
        properties do
            id do
                type is int
                autoincrement is true
                pk is true
            end
            nome do
                type is string
            end
            compras do
                type is reference
                hasMany Domain.models.compra
                cascadeDelete is true
            end
        end
    end
    
    compra do
        name is 'Compra'
        plural is 'Compras'
        properties do
            id do
                type is int
                autoincrement is true
                pk is true
            end
            nome do
                type is string
            end
        end
    end

    shopping do
        name is 'Shopping Center'
        plural is 'Shopping Centers'
        properties do
            id do
                type is int
                autoincrement is true
                pk is true
            end
            nome do
                type is string
            end
        end
    end

end

#Domain.specialFiles are 'file1', 'file2', 'file3'
