module T
  module Collectable

    def collect_with_cursor(collection=[], cursor=-1, &block)
      object = yield cursor
      collection += object.collection
      object.next_cursor.zero? ? collection : collect_with_cursor(collection, object.next_cursor)
    end

  end
end
