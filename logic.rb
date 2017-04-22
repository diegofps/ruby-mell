require 'ruby-prolog'
require 'byebug'

class LogicRule

    def initialize(env, parent=nil, name=nil, args=nil)
        @parent = parent
        @name = name
        @args = args
        @rules = []
        @env = env
    end

    def name
        @name
    end

    def args
        @args
    end

    def rules
        @rules
    end

    def parse(&block)
        instance_eval(&block)
    end

    def method_missing(name, *args, &block)
        token = LogicRule.new(@env, self, name, args)
        @rules << token
        token.parse &block unless block.nil?
    end

    def to_prolog
        @env.send(@name).send(:[], *@args)
    end

end

class LogicQuery

    def initialize(env)
        @rules = []
        @env = env
    end

    def each
        goals = @rules.map {|x| x.to_prolog}

        vars_list = []
        goals.each_with_index do |g, ig|
            g.args.each_with_index do |a, ia|
                if a.is_a? Symbol
                    vars_list << [a, ig, ia]
                end
            end
        end
        vars_list.uniq { |x| x[0] }

        @env.resolve(*goals) do |env|
            result = env[goals]
            yield *vars_list.map { |x| result[x[1]].args[x[2]] }
        end
    end

    def valid?
        goals = @rules.map {|x| x.to_prolog}
        @env.resolve(*goals) do |x|
            return true
        end
        return false
    end

    def method_missing(name, *args, &block)
        @rules << LogicRule.new(@env, self, name, args)
        each &block unless block.nil?
        self
    end

end

class Logic

    def initialize
        @env = RubyProlog::Core.new
    end

    def env
        @env
    end

    def facts(&block)
        lr = LogicRule.new(@env)
        lr.parse(&block)
        declare_facts([], lr)
    end

    def rules(&block)
        lr = LogicRule.new(@env)
        lr.parse(&block)
        lr.rules.each do |token|
            token.to_prolog.send(:<<, token.rules.map {|x| x.to_prolog})
        end
    end

    def query(&block)
        LogicQuery.new(@env)
    end

    def declare_facts(args, lr)
        lr.rules.each do |x|
            args << x.args
            new_args = args.flatten(1)
            #puts "Declaring fact " + x.name.to_s + " with args= " + new_args.to_s
            @env.send(x.name).send(:[], *new_args).fact
            declare_facts(args, x)
            args.pop
        end
    end

end
