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
      def suggest_impl(_start, _limit, _incompletes, _prefix, results)
        results
      end
    end

    def suggest_impl(start, limit, incompletes, prefix = '', results = Set.new)
      if start == ''
        return results if limit != :none && limit < 0
        results << prefix if @leave || (incompletes && limit == 0)
        limit = limit - 1 unless limit == :none
        if limit == :none || limit >= 0
          @children.each do |key, child|
            new_prefix = prefix + key
            results =
              child.suggest_impl(start, limit, incompletes, new_prefix, results)
          end
        end
      else
        child = @children.fetch(start[0]) { Silent.instance }
        results =
          child.suggest_impl(start[1..-1], limit, incompletes, prefix, results)
      end
      results
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

    INVALID_ERR = 'Invalid input "%s"'

    def once_validated!(start, char_limit, return_incompletes)
      fail SuggestParamError, INVALID_ERR % start if Input.invalid? start
      char_limit = validate_char_limit!(char_limit)
      yield start, char_limit, return_incompletes
    end
  end
  Elephant.send(:include, Complete)
end
