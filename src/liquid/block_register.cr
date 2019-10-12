class Liquid::BlockRegister
  @@inner = Hash(String, Liquid::Block).new

  def self.register(name : String, block : Liquid::Block, has_end = true)
    @@inner[name] = block
    @@inner["end#{name}"] = Liquid::Block::EndBlock if has_end
  end

  def self.for_name(name : String)
    @@inner[name]
  end
end
