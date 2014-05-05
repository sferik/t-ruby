module Kernel
  def Bignum(arg, base = 0) # rubocop:disable MethodName
    Integer(arg, base)
  end

  def Fixnum(arg, base = 0) # rubocop:disable MethodName
    Integer(arg, base)
  end

  def NilClass(_) # rubocop:disable MethodName
    nil
  end
end
