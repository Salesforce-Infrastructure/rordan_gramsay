require_relative '../../lib/rordan_gramsay/foodcritic/rule_list'

RSpec.describe RordanGramsay::Foodcritic::RuleList do
  let(:rule_klass) { Struct.new(:name, :code) }

  subject { described_class.new }

  it 'is enumerable' do
    expect(described_class.ancestors).to include Enumerable
    expect(subject).to respond_to :each
    expect(subject).to respond_to :<<
  end

  describe '#<<' do
    it 'transforms any non-rule into a rule' do
      expect(subject.count).to eq 0

      rule = rule_klass.new('some rule', 'RG002')
      subject << rule
      last_rule = nil
      subject.each do |r|
        last_rule = r
      end

      expect(subject.count).to eq 1
      expect(last_rule).not_to be_nil
      expect(last_rule.name).to eq(rule.name)
      expect(last_rule.code).to eq(rule.code)
      expect(last_rule).to be_a RordanGramsay::Foodcritic::Rule
    end

    it 'appends another rule' do
      expect {
        subject << rule_klass.new('some rule', 'RG002')
      }.to change {
        subject.count
      }.by(1)
    end
  end

  describe '#failures?' do
    let(:internal_rule) { RordanGramsay::Foodcritic::Rule }
    let(:rule_a) { rule_klass.new('some rule', 'RG002') }
    let(:rule_b) { rule_klass.new('some other rule', 'RG003') }

    context 'when 1+ failures in many rules' do
      it 'calls Rule#failure? on each rule until it finds one that is a failure' do
        rules = []
        rules << internal_rule.new(rule_a, true)
        rules << internal_rule.new(rule_b, true)

        rules.each { |r| subject << r }
        rules.first.tap { |r| expect(r).to receive(:failure?) }

        expect(subject).to respond_to :failures?
        expect(subject.failures?).to be_truthy
      end
    end

    context 'when no failures in many rules' do
      it 'calls Rule#failure? on each rule' do
        rules = []
        rules << internal_rule.new(rule_a, false)
        rules << internal_rule.new(rule_b, false)

        rules.each do |r|
          expect(r).to receive(:failure?)
          subject << r
        end

        expect(subject).to respond_to :failures?
        expect(subject.failures?).to be_falsey
      end
    end
  end
end
