require 'twitter'
require 'retryable'

module T
  module Collectable

    MAX_NUM_RESULTS = 200

    def collect_with_max_id(collection=[], max_id=nil, &block)
      tweets = retryable(:tries => 3, :on => Twitter::Error, :sleep => 0) do
        yield(max_id)
      end
      return collection if tweets.nil?
      collection += tweets
      tweets.empty? ? collection.flatten : collect_with_max_id(collection, tweets.last.id - 1, &block)
    end

    def collect_with_count(count, &block)
      opts = {}
      opts[:count] = MAX_NUM_RESULTS
      collect_with_max_id do |max_id|
        opts[:max_id] = max_id unless max_id.nil?
        opts[:count] = count unless count >= MAX_NUM_RESULTS
        if count > 0
          tweets = yield opts
          count -= tweets.length
          tweets
        end
      end.flatten.compact
    end

    def collect_with_page(collection=[], page=1, &block)
      tweets = retryable(:tries => 3, :on => Twitter::Error, :sleep => 0) do
        yield page
      end
      return collection if tweets.nil?
      collection += tweets
      tweets.empty? ? collection.flatten.uniq : collect_with_page(collection, page + 1, &block)
    end

  end
end
