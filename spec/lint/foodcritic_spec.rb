require_relative '../../lib/rordan_gramsay/lint/foodcritic'

RSpec.describe RordanGramsay::Lint::Foodcritic do
  before(:all) { setup_monorepo! 'TEST_chef-repo' }
  after(:all) { teardown_monorepo! 'TEST_chef-repo' }

  # Setup a new test environment each time
  around(:example) do |example|
    FileUtils.cd('TEST_chef-repo/cookbooks') { setup_cookbook! 'example' }

    with_monorepo('TEST_chef-repo') do
      with_cookbook('example') do
        example.run
      end
    end

    FileUtils.rm_r('TEST_chef-repo/cookbooks/example', force: true)
  end

  let(:obj) { described_class.new }
  let(:files) { obj.files.map { |f| obj.nice_filename(f) } }

  it 'initializes without error' do
    expect { described_class.new }.not_to raise_error
  end

  describe '#files' do
    it 'should detect all files it needs to check' do
      expect(files).not_to be_empty
    end

    it 'displays absolute path' do
      expect(obj.files.all? { |f| f =~ %r{TEST_chef-repo/cookbooks/example/} }).to be_truthy
    end
  end

  describe '#call' do
    it 'prints pretty output by filename' do
      stdout, = capture_stdout_and_stderr { obj.call }

      files.each do |f|
        expect(stdout).to include f
      end

      obj.files.each do |f|
        expect(stdout).not_to include f
      end
    end
  end

  describe '#rules' do
    it 'lists the rules broken' do
      File.write('metadata.rb', '')

      expect(obj.rules).not_to be_empty
      obj.rules.each do |rule|
        expect(rule).to be_a RordanGramsay::Foodcritic::Rule
      end
    end
  end
end
