require 'active_support/core_ext/string/output_safety'

module Kernel

  def Bignum(arg, base=0)
    Integer(arg, base)
  end

  def Fixnum(arg, base=0)
    Integer(arg, base)
  end

  def NilClass(arg)
    nil
  end

end
