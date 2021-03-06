require 'set'

require_relative 'rule'

module RordanGramsay
  module Rubocop
    # :nodoc:
    class RuleList
      include Enumerable

      def initialize
        @rules = Set.new
      end

      def each(&block)
        @rules.sort.each(&block)
      end

      def empty?
        count.zero?
      end

      def <<(rule)
        rule = Rule.new(rule) unless rule.is_a?(Rule)
        @rules << rule
      end

      def failures?
        @rules.any?(&:failure?)
      end
    end
  end
end
