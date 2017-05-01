require 'debug_inspector'
require 'ruby-prolog'
require 'fileutils'
require 'byebug'
require 'i18n'
require 'trie'
require 'erb'

require './mellparser.rb'
require './logic.rb'

I18n.enforce_available_locales = false

module Config
  module_function
  def method_missing name, params=nil
    if name.to_s.end_with? "="
      realname = '@' + name.slice(0,name.length-1)
      return self.instance_variable_set(realname, params)
    end

    localname = '@' + name.to_s
    if instance_variable_defined? localname
      return self.instance_variable_get localname
    end

    nil
  end
end

def query(&block)
  Mell.metadata.query(&block)
end

def rules(&block)
  Mell.metadata.rules(&block)
end

def facts(&block)
  Mell.metadata.facts(&block)
end

class MellError < StandardError
end

class Hash
  def get(key)
    if self.has_key? key
      return self[key]
    else
      raise ArgumentError, "Missing parameter: #{key}"
    end
  end
end

module Mell

  def get_binding(__params)
    bind = binding
    __params.each { |key, value| bind.local_variable_set(key, value) }
    bind
  end

  def get_filepath(filename)
    unless defined? @filepaths and @filepaths != nil
      @filepaths = Trie.new
      Dir.glob('**/*.mell.rb').each do |filepath|
        @filepaths.add(filepath.reverse)
      end
    end

    children = @filepaths.children("/#{filename}.mell.rb".reverse)

    if children.length == 1
      return children.first.reverse

    elsif children.length == 0
      raise ArgumentError, "Template '#{filename}' was not found"

    else
      raise ArgumentError, "Ambiguous template for '#{filename}', candidates: #{children.map {|x| x.reverse}}"

    end
  end

  @metadata = Logic.new

  module_function

  def metadata
    @metadata
  end

  def cammel_case(name)
    I18n.locale = :en
    I18n.transliterate(name.to_s).split(/\s+/).collect(&:capitalize).join
  end

  def validate_presence(name)
    RubyVM::DebugInspector.open do |inspector|
      bind = inspector.frame_binding(2)
      unless bind.local_variable_defined? name
        raise ArgumentError, "Missing parameter '#{name}'"
      end
    end
  end

  def render(template, params=nil)
    template_stack
    begin
      filepath = get_filepath(template)
      input = File.read(filepath)
      template_stack << filepath
      #result = ERB.new(input, nil, '-').result(get_binding(params))
      result = MellParser.result(input, get_binding(params))
      template_stack.pop
      result
    rescue Exception => e
      unless @template_stack.nil?
        puts
        puts "Error: #{e.message}. In:"
        template_stack.reverse_each { |x| puts "\t" + x }
        puts
        @template_stack = nil
      end
      raise MellError, "Could not finish rendering: " + e.message
    end
  end

  def template_stack
    if !defined? @template_stack
      @template_stack = []
    end
    @template_stack
  end

  def render_with_indent(template, size, params=nil)
    render(template, params).gsub(/^/, ' ' * size)
  end

  def render_to_file(template, filenameOut, params=nil)
    FileUtils::mkdir_p(File.dirname(filenameOut))
    File.open(filenameOut, 'w') do |f|
      f.write render(template, params)
    end
  end

end
