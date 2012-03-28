module Enumerable

  def threaded_each
    threads = []
    result = each do |object|
      threads << Thread.new{yield object}
    end
    threads.each(&:join)
    result
  end

  def threaded_map
    results = map{nil}
    threads = []
    each_with_index do |object, index|
      threads << Thread.new{results[index] = yield object}
    end
    threads.each(&:join)
    results
  end

end
