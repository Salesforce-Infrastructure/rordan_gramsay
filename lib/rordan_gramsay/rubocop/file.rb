require_relative 'rule_list'

module RordanGramsay
  module Rubocop
    # :nodoc:
    class File
      include Comparable

      attr_reader :name, :rules

      def initialize(filename)
        @name = filename
        # Indexed by line number
        @rules = Hash.new { |hash, key| hash[key] = RuleList.new }
      end

      def failed?
        rules.any? { |(_, r)| r.failures? }
      end

      def <=>(other)
        @name <=> other&.name
      end
    end
  end
end
