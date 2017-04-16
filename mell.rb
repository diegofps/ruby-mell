require 'debug_inspector'
require 'ruby-prolog'
require './logic.rb'
require 'byebug'
require "i18n"
require 'trie'
require 'erb'

Metadata = Logic.new

I18n.enforce_available_locales = false

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

  def self.get_binding(__params)
    bind = binding
    __params.each do |key, value|
      bind.local_variable_set(key, value)
    end
    bind
  end

  def self.get_filepath(filename)
    unless defined? @filepaths and @filepaths != nil
      @filepaths = Trie.new
      Dir.glob('**/*.erb').each do |filepath|
        @filepaths.add(filepath.reverse)
      end
    end

    children = @filepaths.children("/#{filename}.erb".reverse)

    if children.length == 1
      return children.first.reverse
    elsif children.length == 0
      raise ArgumentError, "Template '#{filename}' was not found"
    else
      raise ArgumentError, "Ambiguous template for '#{filename}', candidates: #{children.map {|x| x.reverse}}"
    end
  end

  module_function

  def cammel_case(name)
    I18n.locale = :en
    I18n.transliterate(name.to_s).split(/\s+/).collect(&:capitalize).join
  end

  def validate_variable(name)
    RubyVM::DebugInspector.open do |inspector|
      bind = inspector.frame_binding(2)
      unless bind.local_variable_defined? name
        raise ArgumentError, "Missing parameter '#{name}'"
      end
    end
  end

  def render(filename, params=nil)
    template_stack
    begin
      filepath = Mell.get_filepath(filename)
      input = File.read(filepath)
      template_stack << filepath
      result = ERB.new(input, nil, '-').result(get_binding(params))
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

  def self.push_template(name)
    template_stack << name
  end

  def self.pop_stack

  end

  def template_stack
    if !defined? @template_stack
      @template_stack = []
    end
    @template_stack
  end

  def render_with_indent(filename, size, params=nil)
    render(filename, params).gsub(/^/, ' ' * size)
  end

  def render_to_file(filenameIn, filenameOut, params=nil)
    File.open(filenameOut, 'w') do |f|
      f.write render(filenameIn, params)
    end
  end

end
