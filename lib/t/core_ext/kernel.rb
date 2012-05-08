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
