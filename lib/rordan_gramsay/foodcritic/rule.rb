module RordanGramsay
  module Foodcritic
    # :nodoc:
    class Rule
      include Comparable

      attr_reader :name, :code

      def initialize(rule, failure = true)
        @name = rule.name
        @code = rule.code
        @failure = failure
      end

      def <=>(other)
        code <=> other.code
      end

      def failure?
        @failure
      end

      def to_s
        "[#{code}] #{name}"
      end
    end
  end
end
