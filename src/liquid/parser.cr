require "./blocks"
require "./tokenizer"
require "./strip_visitor"

module Liquid
  class Parser
    private STATEMENT        = /^\s*(?<keyword>[a-z]+).*$/
    private ENDRAW_STATEMENT = /\A\s*endraw\s*\z/

    getter root : Root

    @str : String
    @nodes = Array(Node).new
    # if this flag is true we are parsing a {% raw %} block, so we keep creating Raw blocks for every token until we find
    # a {% endraw %}
    @under_raw_block = false

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
      @last_node = @root
      @nodes << @root
    end

    # parse string
    def parse : Root
      Tokenizer.parse(@str) do |token|
        if token.kind.raw?
          @nodes.last << Block::Raw.new(token.value)
          next
        elsif @under_raw_block # processing contents of {% raw %}
          if token.kind.statement? && token.value =~ ENDRAW_STATEMENT
            @under_raw_block = false
          else
            @nodes.last << Block::Raw.new(token.raw_value)
          end
        elsif token.kind.expression?
          block = Expression.new(token.value)
          block.rstrip = token.rstrip?
          block.lstrip = token.lstrip?
          @nodes.last << block
        elsif token.kind.statement?
          parse_statement(token)
        end
      end

      StripVisitor.new.visit(@root)
      @root
    end

    private def parse_statement(token : Token)
      token_value = token.value
      match = token_value.match(STATEMENT)
      invalid_statement!(token) if match.nil?

      block_class = BlockRegister.for_name(match["keyword"])
      block = block_class.new(token.value)
      block.rstrip = token.rstrip?
      block.lstrip = token.lstrip?

      case block
      when Block::EndBlock
        loop do
          last = @nodes.last
          if last != root && last.is_a?(Block::BeginBlock)
            @nodes.pop
          else
            break
          end
        end
        @nodes.last << block
      when Block::BeginBlock
        @nodes.last << block
        @nodes << block
      when Block::InlineBlock
        @nodes.last << block
      when Block::RawBlock
        # If a Raw block appear here, is because Raw statement is a RawBlock instead of a BeginBlock.
        # To process {% raw %} we turn this flag on and start generating RawBlock for every token until we
        # find a statement token that matches with ENDRAW_STATEMENT regex.
        @under_raw_block = true
      else
        invalid_statement!(token)
      end
    end

    private def invalid_statement!(token)
      raise InvalidStatement.new("Invalid Statement #{token.value.inspect} at line #{token.line_number}.")
    end
  end
end
