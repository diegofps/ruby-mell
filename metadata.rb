require 'byebug'

class MetadataException < StandardError
end

class SetMetadata
    attr_reader :_value

    def initialize(value)
        @_value = value
    end
end

def is(param)
    SetMetadata.new param
end

def are(*param)
    SetMetadata.new param
end

class Metadata

    attr_reader :_id
    attr_reader :_value
    attr_reader :_parent
    attr_reader :_children

    def initialize(parent=nil, id=nil, args=nil)
        @_id = id
        @_parent = parent
        @_children = {}
        self._value=(args)
    end

    def _cannonical_id
        current = self
        result = []
        while !current._parent.nil?
            result << current
            current = current._parent
        end
        (result.reverse!.map {|x| x._id}).join('.')
    end

    def _value=(args)
        if args.nil? || args.empty? 
            @_value = nil
        elsif args[0].class == SetMetadata
            @_value = args[0]._value
        else
            @_value = args[0]
        end
    end

    def method_missing(id, *args, &block)
        strId = id.to_s

        if strId.end_with? '?'
            id = id.slice(0, id.length-1).to_sym
            return @_children.has_key?(id) && !@_children[id]._empty?

        elsif strId.end_with? '='
            id = id.slice(0, id.length-1).to_sym

            if @_children.has_key? id
                data = @_children[id]
                data._value = args
                data._evaluate(block)
                return data._value
            else
                data = Metadata.new(self, id, args)
                @_children[id] = data
                data._evaluate(block)
                return data
            end
        
        elsif strId.end_with? '!'
            id = id.slice(0, id.length-1).to_sym

            if @_children.has_key? id
                data = @_children[id]
                return data
            else
                raise MellError, "Missing property at #{_cannonical_id} : #{id}"
            end

        elsif @_children.has_key? id
            data = @_children[id]
            data._evaluate(block)
            return data._children.any? || data._value.nil? ? data : data._value
        
        else
            unless args.any? || !block.nil?
                #byebug
                raise MellError, "Unknown property #{id} at #{_cannonical_id}" 
            end

            data = Metadata.new(self, id, args)
            @_children[id] = data
            data._evaluate(block)
            return data
        end
    end

    def _evaluate(block)
        instance_eval(&block) unless block.nil?
    end

    def each
        @_children.each do |x|
            yield x[1]
        end
    end

    def _empty?
        return @_children.empty? && @_value.nil?
    end

    def has?(id)
        @_children.has_key? id
    end

    def to_s
        if @_value.nil?
            raise MellError, "Missing value for #{_cannonical_id}"
        else
            return @_value.to_s
        end
    end

    def to_ary
        [to_s]
    end

    def delete
        @_parent.delete_property @_id unless @_parent.nil?
    end

    def delete_property(id)
        @_children.delete id
    end

end    
