class String

  def strip_ats
    self.tr('@', '')
  end

  def strip_commas
    self.tr(',', '')
  end

end
