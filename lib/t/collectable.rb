module T
  module Collectable

    def collect_with_cursor(collection=[], cursor=-1, &block)
      object = yield cursor
      collection += object.collection
      object.last? ? collection : collect_with_cursor(collection, object.next_cursor, &block)
    end

  end
end
