module MellParser

  def self.get_block(input, c, open, close)
    counter = 1
    start = c

    while counter != 0 && c != input.length
      char = input[c]
      if char == open
        counter += 1
      elsif char == close
        counter -= 1
      end
      c += 1
    end

    raise ArgumentError, "Non conformit at #{open}#{close} detected" unless counter == 0
    input.slice(start, c-start-1)
  end

  def self.get_whites(input, c)
    start = c

    while c != input.length && (input[c] == " " || input[c] == "\t" || input[c] == "\r")
      c += 1
    end

    if input[c] == "\n"
      input.slice(start, c-start + 1)
    else
      input.slice(start, c-start)
    end
  end

  def self.get_row(input, c)
    start = c

    while c != input.length && input[c] != "\n"
      c += 1
    end

    if input[c] == "\n"
      input.slice(start, c-start + 1)
    else
      input.slice(start, c-start)
    end
  end

  class Builder

    def initialize
      @content = []
      @content << "#initialization\n"
      @content << "builder = StringIO.new\n"
      @content << "rows = [[]]\n"
      @content << "\n"
    end

    def escaped_string(text)
      text = text.gsub("\"", "\\\"")
      text = text.gsub("\n", "\\n")
      "\"#{text}\""
    end

    def add_text(text)

      @content << "#text\n"
      @content << "rows.each { |row| row << #{escaped_string(text)}}\n"

      if text.end_with? "\n"
        @content << "rows.each { |row| builder << row.join('')}\n"
        @content << "rows.clear\n"
        @content << "rows << []\n"
      end
      @content << "\n"
    end

    def add_printable(code)
      @content << "#printable\n"
      @content << "rows.each { |row| row << eval(#{escaped_string(code)}).to_s}\n"
      @content << "\n"
    end

    def add_code(code)
      @content << "#code\n"
      @content << "rows.clear\n"
      @content << "rows << []\n"
      @content << code
      @content << "\n"
    end

    def add_indented(code)
      @content << "#indented\n"
      @content << "tmp = eval(#{escaped_string(code)}).split(\"\\n\")\n"
      @content << "rows2 = []\n"
      @content << "tmp.each do |text| \n"
      @content << "  rows.each do |row| \n"
      @content << "    rows2 << (row.clone << text)\n"
      @content << "  end\n"
      @content << "end\n"
      @content << "rows = rows2\n"
      @content << "\n"
    end

    def string
      @content << "builder.string\n"
      @content.join('')
    end

  end

  def self.parse(input)
    result = []
    start = 0
    c = 0

    while c < input.length
      char = input[c]
      next_char = c != input.length-1 ? input[c+1] : nil

      if char == "\n"
        c += 1
        result << [:text, input.slice(start, c-start)] unless c == start
        start = c

      elsif char == '@'
        result << [:text, input.slice(start, c-start)] unless c == start
        start = c

        # Multiple lines of ruby code
        if next_char == '{'
          c += 2
          whites = get_whites(input, c)
          c += whites.length

          block = get_block(input, c, '{', '}')
          result << [:code_ml, block]
          c += block.length + 1

          whites = get_whites(input, c)
          c += whites.length

          start = c

        elsif next_char == '|' || next_char == '!'
          c += 1

        # Single line of ruby code
        else
          c += 1
          row = get_row(input, c)
          result << [:code_sl, row]
          c += row.length

          start = c
        end

      elsif char == '%'
        if next_char == '('
          result << [:text, input.slice(start, c-start)] unless c == start
          start = c

          c += 2
          block = get_block(input, c, '(', ')')
          result << [:print, block]
          c += block.length + 1

          start = c

        elsif next_char == '{'
          result << [:text, input.slice(start, c-start)] unless c == start
          start = c

          c += 2
          block = get_block(input, c, '{', '}')
          result << [:print_prefix, block]
          c += block.length + 1

          start = c

        else
          c += 1

        end

      else
        c += 1

      end
    end

    result << [:text, input.slice(start, c-start)] unless c == start
    result
  end

  def self.create_script(tokens)
    builder = Builder.new

    tokens.each do |d|
      if d[0] == :text
        builder.add_text(d[1])

      elsif d[0] == :print
        builder.add_printable(d[1])

      elsif d[0] == :print_prefix
        builder.add_indented(d[1])

      elsif d[0] == :code_sl || d[0] == :code_ml
        builder.add_code(d[1])

      else
        raise ArgumentError, "Invalid input: #{d[0]}"
      end
    end

    builder.string
  end

  module_function

  def result(input, bind, verbose=false)
    tokens = parse(input)

    script = create_script(tokens)
    if verbose
      puts "Script -----------------------------------------------------------------------------"
      puts script
    end

    result = bind.eval(script)
    if verbose
      puts "ScriptResult -----------------------------------------------------------------------------"
      puts result
    end

    result.gsub(/\s*\@!/, "")
    #result = result.gsub(/\@\|(\s*)\@\|/, "\\1")
    #result.gsub(/@\|(\s*)@!/, "")
  end

end
