facts do

    model 'Shopping' do
        plural 'Shoppings'
        property 'Id' do
            type 'int'
            pk
        end
        property 'Nome' do
            type 'string'
            hasIndex
        end
        property 'Lojas' do
          type 'reference'
          hasMany 'Lojas'
        end
    end

    model 'Loja' do
      plural 'Lojas'
      property 'Id' do
        type 'int'
        pk
      end
      property 'Nome' do
        type 'string'
        isUnique
      end
      property 'Produtos' do
        type 'reference'
        hasMany 'Produtos'
      end
    end

    model 'Produto' do
        plural 'Produtos'
        property 'Id' do
            type 'int'
            pk
        end
        property 'Nome' do
            type 'string'
            isUnique
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
