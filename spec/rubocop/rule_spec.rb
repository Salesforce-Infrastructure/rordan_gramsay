require_relative '../../lib/rordan_gramsay/rubocop/rule'

RSpec.describe RordanGramsay::Rubocop::Rule do
  let(:rule) { Struct.new(:name, :code).new('Do not do bad things', 'RG001') }

  describe '#failure?' do
    it 'defers to the value givin on initialization' do
      expect(described_class.new(rule, false).failure?).to be_falsey
      expect(described_class.new(rule, true).failure?).to be_truthy
    end
  end

  it 'compares based on the code' do
    rule_a = rule.dup
    rule_b = rule.dup

    # Change the rule names, make one rule fail and the other warn, but leave the codes the same
    a = described_class.new(rule_a.tap { |r| r.name = "Don't do bad things" }, false)
    b = described_class.new(rule_b.tap { |r| r.name = 'Do not do bad things' }, true)

    expect(described_class.ancestors).to include Comparable
    expect(a <=> b).to eq 0
  end

  it 'can be printed in a pretty way' do
    expect(described_class.new(rule, false).to_s).not_to include '<RordanGramsay::Rubocop::Rule'
  end
end
