module T
  module Collectable

    def collect_with_cursor(collection=[], cursor=-1, &block)
      return collection if cursor == 0
      object = yield cursor
      collection += object.collection
      collect_with_cursor(collection, object.next_cursor)
    end

  end
end
