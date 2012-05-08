require 'active_support/core_ext/string/output_safety'

module Kernel

  def Bignum(arg)
    Integer(arg)
  end

  def Fixnum(arg)
    Integer(arg)
  end

  def NilClass(arg)
    nil
  end

end
