# encoding: utf-8

module Enf
  # Helper class for inputs
  class Input
    require 'set'

    AUTHORIZED_TYPES = Set.new([String, Array]).freeze

    def self.invalid?(element)
      return true if element.nil?
      return true unless AUTHORIZED_TYPES.include? element.class
      false
    end
  end
end
