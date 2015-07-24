# encoding: utf-8
module Enf
  class Elephant
    # Pattern dectection service class
    class FetchService
      SEARCH_KEY_ERROR =  'key not found: %s'
      def self.search_in(head, searched)
        elephant = head
        index = 0
        while index < searched.size
          elephant = elephant.children.fetch(searched[index]) do
            return yield if block_given?
            fail KeyError, SEARCH_KEY_ERROR % searched[index].inspect
          end
          index += 1
        end
        elephant
      end
    end
  end
end
