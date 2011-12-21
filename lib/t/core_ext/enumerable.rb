module Enumerable

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
