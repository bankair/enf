# encoding: utf-8

require 'enf/elephant'

# Base module
module Enf
  # Completion logic
  module Complete
    def suggest(start, limit: :none, incompletes: false)
      once_validated!(start, limit, incompletes) do |s, l, i|
        suggest_impl(s, l, i)
      end
    end

    protected

    # Nil class for suggestions
    class Silent
      require 'singleton'
      include Singleton
      def complete(_limit, _incompletes, _prefix, results)
        results
      end
    end

    def suggest_impl(start, limit, incompletes, prefix = '', results = Set.new)
      fetch_root(start).complete(limit, incompletes, prefix, results)
    end

    def fetch_root(start)
      Elephant::FetchService.search_in(self, start) { Silent.instance }
    end

    def complete(limit, incompletes, prefix, results)
      add_current_prefix_if_needed(results, limit, incompletes, prefix)
      limit = next_limit limit
      return results if limit != :none && limit < 0
      @children.each do |key, child|
        results = child.complete(limit, incompletes, prefix + key, results)
      end
      results
    end

    def next_limit(limit)
      return :none if limit == :none
      limit - 1
    end

    def add_current_prefix_if_needed(results, limit, incompletes, prefix)
      results << prefix if @leave || (incompletes && limit == 0)
    end

    class SuggestParamError < StandardError; end

    NEG_VAL_ERR = 'Strictly non negative values accepted only'

    def validate_char_limit!(value)
      return value if value == :none
      fail SuggestParamError if value.nil?
      value = Integer(value)
      fail SuggestParamError, NEG_VAL_ERR if value <= 0
      value
    rescue StandardError => error
      raise SuggestParamError, error.message
    end

    INVALID_ERR = 'Invalid input %s'

    def once_validated!(start, char_limit, return_incompletes)
      if Input.invalid? start
        fail SuggestParamError, INVALID_ERR % start.inspect
      end
      char_limit = validate_char_limit!(char_limit)
      yield start, char_limit, return_incompletes
    end
  end
  Elephant.send(:include, Complete)
end
