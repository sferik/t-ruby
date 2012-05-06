module T
  module Collectable

    MAX_NUM_RESULTS = 200

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

    def collect_with_count(method, count, opts = {})
      # Most of the APIs use :count to request a specific count. For the few that don't, this allows
      # to specify a different count parameter (e.g. search uses :rpp and recommendations uses :limit)
      count_key = opts[:count_key].nil? ? :count : opts[:count_key]
      params = {}
      params[count_key] = MAX_NUM_RESULTS
      statuses = collect_with_max_id do |max_id|
        params[:max_id] = max_id unless max_id.nil?
        params[count_key] = count unless count >= MAX_NUM_RESULTS
        if count > 0
          count -= MAX_NUM_RESULTS
          retryable(:tries => 3, :on => Twitter::Error::ServerError, :sleep => 0) do
            if opts[:args].nil? || !opts[:args].is_a?(Array) || opts[:args].empty?
              client.send(method, params)
            elsif opts[:args].length === 1
              client.send(method, opts[:args][0], params)
            elsif opts[:args].length === 2
              client.send(method, opts[:args][0], opts[:args][1], params)
            end
          end
        end
      end.flatten.compact
    end
  end
end
