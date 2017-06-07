require_relative '../../lib/rordan_gramsay/lint/base'

RSpec.describe RordanGramsay::Lint::Base do
  let(:klass) do
    Class.new(RordanGramsay::Lint::Base).tap do |k|
      k.send(:define_method, :initialize) do
        # noop
      end
    end
  end

  subject { klass.new }

  describe '#initialize' do
    subject { described_class.new }

    it 'is not implemented' do
      expect { subject }.to raise_error(RordanGramsay::MethodNotImplemented, '#initialize')
    end
  end

  describe '#call' do
    it 'is not implemented' do
      expect { subject }.not_to raise_error
      expect { subject.call }.to raise_error(RordanGramsay::MethodNotImplemented, '#call')
    end
  end

  describe '#files' do
    it 'is not implemented' do
      expect { subject }.not_to raise_error
      expect { subject.files }.to raise_error(RordanGramsay::MethodNotImplemented, '#files')
    end
  end
end
