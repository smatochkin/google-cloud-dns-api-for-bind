#
# Convert String Hash keys to Symbols
#  Example {"one" => 1, "two" => 2} convert to
#          {:one  => 1, :two  => 2}
#
class Hash
  def to_sym
    Hash[self.map{|k,v| [k.class == String ? k.to_sym : k, v]}]
  end
end
