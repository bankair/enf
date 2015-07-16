# encoding: utf-8

require 'enf/input'

module Enf
  # Represent a node of the graph
  class Elephant
    class CannotRegister < RuntimeError; end
    def initialize(default_leave_value = false)
      @default_leave_value = default_leave_value
      @leave = default_leave_value
      @children = Hash.new { |hash, key| hash[key] = Elephant.new }
    end

    def register!(element, payload = true)
      fail CannotRegister if frozen? || Input.invalid?(element)
      return (@leave = payload) if element.empty?
      @children[element[0]].register!(element[1..-1])
    end

    # Null node, used to answer to unknown values
    class Nope
      require 'singleton'
      include Singleton

      def include_impl(_)
        false
      end

      def register!(_)
        fail CannotRegister
      end
    end

    def include?(element)
      return @default_leave_value if Input.invalid?(element)
      include_impl element
    end

    def include_impl(element)
      return @leave if element.empty?
      @children.fetch(element[0]) { Nope.instance }.include_impl(element[1..-1])
    end
  end
end
