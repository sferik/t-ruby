module T
  module Collectable

    MAX_NUM_RESULTS = 200

    def collect_with_count(count, &block)
      collect_with_number(count, :count, &block)
    end

    def collect_with_cursor(collection=[], cursor=-1, &block)
      object = yield cursor
      collection += object.collection
      object.last? ? collection : collect_with_cursor(collection, object.next_cursor, &block)
    end

    def collect_with_max_id(collection=[], max_id=nil, &block)
      array = yield max_id
      return collection unless !array.nil?
      collection += array
      array.empty? ? collection : collect_with_max_id(collection, array.last.id - 1, &block)
    end

    def collect_with_number(number, key, &block)
      opts = {}
      opts[key] = MAX_NUM_RESULTS
      statuses = collect_with_max_id do |max_id|
        opts[:max_id] = max_id unless max_id.nil?
        opts[key] = number unless number >= MAX_NUM_RESULTS
        if number > 0
          number -= MAX_NUM_RESULTS
          retryable(:tries => 3, :on => Twitter::Error::ServerError, :sleep => 0) do
            yield opts
          end
        end
      end.flatten.compact
    end

    def collect_with_per_page(per_page, &block)
      collect_with_number(per_page, :per_page, &block)
    end

    def collect_with_rpp(rpp, &block)
      collect_with_number(rpp, :rpp, &block)
    end

  end
end
