class String

  def prepend_at
    "@#{self}"
  end

  def strip_ats
    self.tr('@', '')
  end

  alias_method :old_to_i, :to_i

  def to_i(base=10)
    self.tr(',', '').old_to_i(base)
  end

end
