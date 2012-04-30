module T
  module Collectable

    def collect_with_cursor(collection=[], cursor=-1, &block)
      object = yield cursor
      collection += object.collection
      object.last? ? collection : collect_with_cursor(collection, object.next_cursor, &block)
    end

    def collect_with_max_id(collection=[], max_id=nil, &block)
      array = yield max_id
      collection += array
      array.empty? ? collection : collect_with_max_id(collection, array.last.id - 1, &block)
    end

  end
end
