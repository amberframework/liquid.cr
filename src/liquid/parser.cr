require "./blocks"

module Liquid
  class Parser
    STATEMENT        = /^\s*(?<keyword>[a-z]+).*$/
    ENDRAW_STATEMENT = {
      "raw"     => /(?<!\\){%\s*endraw\s*\-?%}|$/,
      "comment" => /(?<!\\){%\s*endcomment\s*\-?%}|$/,
    }

    getter root : Root

    @str : String
    @i = 0
    @current_line = 0
    @escape = false
    @lstrip = false
    @rstrip = false
    @buffer_start = -1
    @buffer_size = 0

    # buffers
    @nodes = Array(Node).new

    def self.parse(str : String)
      internal = self.new str
      internal.parse
      Template.new internal.root
    end

    def self.parse(file : File)
      str = file.gets_to_end
      path = File.dirname(file.path)

      internal = self.new str
      internal.parse
      Template.new internal.root, path
    end

    def initialize(@str)
      @root = Root.new
      @nodes << @root
    end

    def has_char?
      @i < str.size
    end

    # parse string
    def parse
      @i = 0
      while @i < @str.size - 1
        if @str[@i] == '{' && @str[@i + 1] == '%' && !@escape
          @i += 2
          if @str[@i] == '-'
            @rstrip = true
            @i += 1
          end
          add_raw
          consume_statement
        elsif @str[@i] == '{' && @str[@i + 1] == '{' && !@escape
          @i += 2
          if @str[@i] == '-'
            @rstrip = true
            @i += 1
          end
          add_raw
          consume_expression
        else
          consume_char
        end
        @escape = false if @escape
        @escape = true if @str[@i] == '\\'
        @i += 1
      end
      consume_char # last char ?
      add_raw
    end

    # Create and add a Raw node with current buffer
    def add_raw
      if @buffer_size > 0
        buffer_str = buffer
        buffer_str = buffer_str.lstrip if @lstrip
        buffer_str = buffer_str.rstrip if @rstrip
        @nodes.last << Block::Raw.new(buffer_str)
        reset_buffer
      end
      @lstrip = false
      @rstrip = false
    end

    def consume_expression
      while @i < @str.size - 1
        if @str[@i] == '-' && @str[@i + 1] == '}' && @str[@i + 2] == '}'
          @lstrip = true
          @i += 2
          break
        elsif @str[@i] == '}' && @str[@i + 1] == '}'
          @i += 1
          break
        else
          consume_char
        end
        @i += 1
      end

      raise "Invalid Expression at line #{@current_line}" if @buffer_size <= 0

      @nodes.last << Expression.new(buffer)
      reset_buffer
    end

    # Consume a statement
    def consume_statement
      while @i < @str.size - 1
        if @str[@i] == '-' && @str[@i + 1] == '%' && @str[@i + 2] == '}'
          @lstrip = true
          @i += 2
          break
        elsif @str[@i] == '%' && @str[@i + 1] == '}'
          @i += 1
          break
        else
          consume_char
        end
        @i += 1
      end

      buffer_str = buffer
      if match = buffer_str.match STATEMENT
        block_class = BlockRegister.for_name match["keyword"]
        case block_class.type
        when BlockType::End
          while (pop = @nodes.pop?) && pop.is_a? Block && !pop.class.type == BlockType::Begin
          end
        when BlockType::Begin
          block = block_class.new(buffer_str)
          @nodes.last << block
          @nodes << block
        when BlockType::Inline
          @nodes.last << block_class.new(buffer_str)
        else # when BlockType::Raw, BlockType::RawHidden
          if match = @str.match(ENDRAW_STATEMENT[match["keyword"]], @i)
            j = match.begin.not_nil! - 1
            buffer_str = @str[@i + 1..j]
            @i = match.end.not_nil! - 1
            @nodes.last << block_class.new(buffer_str)
          end
        end
      else
        raise "Invalid Statement at line #{@current_line}"
      end

      reset_buffer
    end

    private def buffer : String
      return "" if @buffer_start < 0

      @str[@buffer_start, @buffer_size]
    end

    private def reset_buffer
      @buffer_start = -1
      @buffer_size = 0
    end

    # Add current char to buffer
    private def consume_char
      @buffer_start = @i if @buffer_start < 0

      if @i < @str.size
        @buffer_size += 1
        @current_line += 1 if @str[@i] == '\n'
      end
    end
  end
end
