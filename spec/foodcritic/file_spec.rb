require_relative '../../lib/rordan_gramsay/foodcritic/file'

RSpec.describe RordanGramsay::Foodcritic::File do
  subject { described_class.new('some_file/foo.rb') }

  let(:rule_klass) { Struct.new(:name, :code) }

  describe '#rules' do
    subject { described_class.new('some_file.rb').rules }

    it { is_expected.to be_a Hash }

    it "contains hash of RuleLists, keyed by the file's line" do
      expect(subject[11]).to be_a RordanGramsay::Foodcritic::RuleList
    end
  end

  describe '#failed?' do
    it 'defers to RuleList#failures?' do
      # Some example ruleset for line 10 of the file
      subject.rules[10]

      expect(subject).to respond_to :failed?
      subject.rules.each do |(_, r)|
        expect(r).to receive(:failures?)
      end
      subject.failed?
    end
  end

  it 'is comparable to others by the filename' do
    # Make file_a and file_b only similar by the filename
    file_a = described_class.new('some_file/foo.rb')
    file_a.rules[11] << rule_klass.new('some rule', 'RG009')
    file_a.rules[11] << rule_klass.new('some other rule', 'RG010')
    allow(file_a.rules[11]).to receive(:failures?).and_return(false)

    file_b = described_class.new('some_file/foo.rb')
    file_b.rules[12] << rule_klass.new('my rule', 'RG007')
    file_b.rules[12] << rule_klass.new('my other rule', 'RG008')
    allow(file_b.rules[12]).to receive(:failures?).and_return(true)

    expect(described_class.ancestors).to include Comparable
    expect(file_a <=> file_b).to eq 0
  end
end
