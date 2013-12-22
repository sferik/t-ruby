class Version
  include Comparable

  attr_reader :major, :feature_group, :feature, :bugfix

  def initialize(version="")
    v = version.split(".")
    @major = v[0].to_i
    @feature_group = v[1].to_i
    @feature = v[2].to_i
    @bugfix = v[3].to_i
  end
  
  def <=>(other)
    return @major <=> other.major if ((@major <=> other.major) != 0)
    return @feature_group <=> other.feature_group if ((@feature_group <=> other.feature_group) != 0)
    return @feature <=> other.feature if ((@feature <=> other.feature) != 0)
    return @bugfix <=> other.bugfix
  end

  def self.sort
    self.sort!{|a,b| a <=> b}
  end

  def to_s
    @major.to_s + "." + @feature_group.to_s + "." + @feature.to_s + "." + @bugfix.to_s
  end
end

## Example Usage:
##  list = []
##  ["1.2.2.10","1.2.2.1","2.1.10.2","2.3.4.1"].each {|v| list.push(Version.new(v)) }
##  list.sort.each{|v| pp v.to_s }
##
###"1.2.2.1"
###"1.2.2.10"
###"2.1.10.2"
###"2.3.4.1"
