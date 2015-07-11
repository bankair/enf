# encoding: utf-8

module Gradic
  # Represent a node of the graph
  class Node
    class CannotRegister < RuntimeError; end

    def initialize
      @leave = false
      @children = Hash.new { |hash, key| hash[key] = Node.new }
    end

    def register!(element)
      fail CannotRegister if frozen? || invalid?(element)
      return (@leave = true) if element.empty?
      @children[element[0]].register!(element[1..-1])
    end

    # Null node, used to answer to unknown values
    class Nope
      require 'singleton'
      include Singleton

      def include?(_)
        false
      end

      def register!(_)
        fail CannotRegister
      end
    end

    def include?(element)
      return false if invalid?(element)
      return @leave if element.empty?
      @children.fetch(element[0]) { Nope.instance }.include?(element[1..-1])
    end

    protected

    require 'set'
    AUTHORIZED_TYPES = Set.new([String, Array]).freeze

    def invalid?(element)
      return true if element.nil?
      return true unless AUTHORIZED_TYPES.include? element.class
      false
    end
  end
end
