class Liquid::BlockRegister
  alias Block = InlineBlock | BeginBlock
  @@inner = Hash(String, Block.class | EndBlock).new

  def self.register(name : String, block : Block.class, has_end = true)
    @@inner[name] = block
    if block.is_a? BeginBlock.class && has_end
      @@inner["end#{name}"] = EndBlock.new block
    end
  end

  def self.for_name(name : String)
    @@inner[name]
  end
end
