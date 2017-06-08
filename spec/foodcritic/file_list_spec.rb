require_relative '../../lib/rordan_gramsay/foodcritic/file_list'

RSpec.describe RordanGramsay::Foodcritic::FileList do
  subject { described_class.new }

  let(:file_klass) { RordanGramsay::Foodcritic::File }

  it 'should be enumerable' do
    expect(described_class.ancestors).to include Enumerable
  end

  describe '#each' do
    it 'is implemented' do
      expect(subject).to respond_to :each
    end
  end

  describe '#filenames' do
    before do
      subject << file_klass.new('file_a.rb')
      subject << file_klass.new('file_b.rb')
    end

    it 'is implemented' do
      expect(subject).to respond_to :filenames
    end

    it 'lists the files' do
      expect(subject.filenames).to include 'file_a.rb'
      expect(subject.filenames).to include 'file_b.rb'
    end
  end

  describe '#failures?' do
    before do
      subject << file_klass.new('file_a.rb')
      subject << file_klass.new('file_b.rb')
    end

    it 'is implemented' do
      expect(subject).to respond_to :failures?
    end

    context 'when 1+ failures in many files' do
      it 'calls File#failed? on each file until it finds one that is a failure' do
        files = []
        subject.each do |(_, f)|
          allow(f).to receive(:failed?).and_return(true)
          files << f
        end

        files.first.tap { |f| expect(f).to receive(:failed?) }

        expect(subject.failures?).to be_truthy
      end
    end

    context 'when no failures in many files' do
      it 'calls File#failed? on each file' do
        files = []
        subject.each do |(_, f)|
          allow(f).to receive(:failed?).and_return(false)
          files << f
        end

        files.each { |f| expect(f).to receive(:failed?) }

        expect(subject.failures?).to be_falsey
      end
    end
  end

  describe '#<<' do
    it 'is implemented' do
      expect(subject).to respond_to :<<
    end

    it 'adds a file to @files, keyed by File#name' do
      expect(subject.send(:instance_variable_get, :@files)).not_to have_key 'file_a.rb'

      expect {
        subject << file_klass.new('file_a.rb')
      }.to change {
        subject.count
      }.by(1)

      expect(subject.send(:instance_variable_get, :@files)).to have_key 'file_a.rb'
    end
  end

  describe '#[]' do
    it 'creates a new File with the given filename if the key does not exist' do
      expect {
        subject['file_a.rb']
      }.to change {
        subject.send(:instance_variable_get, :@files).key? 'file_a.rb'
      }
    end
  end
end
