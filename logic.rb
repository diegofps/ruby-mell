require 'ruby-prolog'
require 'byebug'

class Token

    def initialize(logic, name, args)
        @logic = logic
        @name = name
        @args = args
    end
    
    def save
        to_prolog.fact
    end
    
    def each
        @logic.env.query(to_prolog).each do |x|
            yield *(x[0].args)
        end
    end
    
    def possible?
        @logic.env.query(to_prolog).any?
    end
    
    def to_prolog
        @logic.env.send(@name).send(:[], *@args)
    end
    
end

class LogicBlock 
    
    def initialize(logic)
        @logic = logic
        @rules = []
    end
    
    def call(&block)
        instance_eval(&block)
        @rules
    end
    
    def method_missing(name, *args)
        token = Token.new(@logic, name, args)
        @rules << token.to_prolog
    end
    
end

class Logic

    def initialize
        @environment = RubyProlog::Core.new
    end

    def env
        @environment
    end
    
    def method_missing(name, *args, &block)
        token = Token.new(self, name, args)
        
        if block.nil?
            return token
        else
            lb = LogicBlock.new(self)
            rules = lb.call(&block)
            token.to_prolog.send(:<<, rules)
        end
    end
    
end

