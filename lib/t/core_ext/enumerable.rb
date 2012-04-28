module Enumerable

  def threaded_each
    threads = []
    each do |object|
      threads << Thread.new{yield object}
    end
    threads.each(&:value)
  end

  def threaded_map
    threads = []
    each do |object|
      threads << Thread.new{yield object}
    end
    threads.map(&:value)
  end

end
