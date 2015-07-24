# encoding: utf-8

require 'enf/input'
require 'enf/elephant/fetch_service'

module Enf
  # Represent a node of the graph
  class Elephant
    attr_reader :default_leave_value, :children
    attr_accessor :leave
    class CannotRegister < RuntimeError; end
    def initialize(default_leave_value = false)
      @default_leave_value = default_leave_value
      self.leave = default_leave_value
      @children = Hash.new { |hash, key| hash[key] = Elephant.new }
    end

    def register!(element, payload = true)
      fail CannotRegister if frozen? || Input.invalid?(element)
      return (self.leave = payload) if element.empty?
      children[element[0]].register!(element[1..-1])
    end

    # Null node, used to answer to unknown values
    class Nope < Elephant
      def initialize(leave = false)
        @leave = leave
        super(leave)
      end

      def register!(_)
        fail CannotRegister
      end
    end

    def include?(element)
      return default_leave_value if Input.invalid?(element)
      FetchService.search_in(self, element) { neutral_node }.leave
    end

    protected

    def neutral_node
      Nope.new default_leave_value
    end
  end
end
