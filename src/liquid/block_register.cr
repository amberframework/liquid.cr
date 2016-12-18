class Liquid::BlockRegister
  @@inner = Hash(String, Block).new

  def self.register(name : String, block : Block, has_end = true)
    @@inner[name] = block
    @@inner["end#{name}"] = EndBlock if has_end
  end

  def self.for_name(name : String)
    @@inner[name]
  end
end
