require_relative '../../lib/rordan_gramsay/lint/test_checker'

RSpec.describe RordanGramsay::Lint::TestChecker do
  before(:all) { setup_monorepo! 'TEST_chef-repo' }
  after(:all) { teardown_monorepo! 'TEST_chef-repo' }

  # Setup a new test environment each time
  around(:example) do |example|
    FileUtils.mkdir_p('TEST_chef-repo/cookbooks')
    FileUtils.cd('TEST_chef-repo/cookbooks') { setup_cookbook! 'example' }

    with_monorepo('TEST_chef-repo') do
      with_cookbook('example') do
        example.run
      end
    end

    FileUtils.rm_r('TEST_chef-repo/cookbooks', force: true)
  end

  let(:obj) { described_class.new }
  let(:files) { obj.files.map { |f| obj.nice_filename(f) } }

  let(:bad_test) do
    <<~INSPEC
      # encoding: utf-8

      # Inspec test for recipe example::default

      # The Inspec reference, with examples and extensive documentation, can be
      # found at http://inspec.io/docs/reference/resources/

      raise RuntimeError, 'Something went wrong'
    INSPEC
  end

  it 'should detect all files it needs to check' do
    %w[test/integration test/smoke].each do |base|
      FileUtils.rm_r(base, force: true)

      FileUtils.mkdir_p File.join(base, 'no_profile')
      File.write(File.join(base, 'no_profile', 'some_test.rb'), '')
      File.write(File.join(base, 'no_profile', 'some_random_file.rb'), '')

      FileUtils.mkdir_p File.join(base, 'profile', 'controls')
      File.write(File.join(base, 'profile', 'controls', 'default.rb'), '')
      FileUtils.mkdir_p File.join(base, 'profile', 'files')
      File.write(File.join(base, 'profile', 'files', 'fizz_buzz.rb'), '')
      FileUtils.mkdir_p File.join(base, 'profile', 'libraries')
      File.write(File.join(base, 'profile', 'libraries', 'resource.rb'), '')
      File.write(File.join(base, 'profile', 'inspec.yml'), '')
    end

    expect(files).not_to be_empty
    %w[test/integration test/smoke].each do |base|
      expect(files).to include File.join(base, 'no_profile', 'some_test.rb')
      expect(files).not_to include File.join(base, 'no_profile', 'some_random_file.rb')

      expect(files).to include File.join(base, 'profile', 'controls', 'default.rb')
      expect(files).not_to include File.join(base, 'profile', 'libraries', 'resource.rb')
      expect(files).not_to include File.join(base, 'profile', 'files', 'fizz_buzz.rb')
      expect(files).not_to include File.join(base, 'profile', 'inspec.yml')
    end
  end

  it 'displays files with absolute path' do
    expect(obj.files.all? { |f| f =~ %r{TEST_chef-repo/cookbooks/example/} }).to be_truthy
  end

  context 'when file exists but is empty' do
    before(:each) do
      File.write('test/integration/example/controls/default.rb', "\n\n\n")
    end

    it 'prints a failure message' do
      stdout, = capture_stdout_and_stderr { obj.call }

      expect(stdout).to match(%r{^.*test/integration/example/controls/default\.rb.+Failed.*$})
    end

    it 'prints the reason for the failure' do
      stdout, = capture_stdout_and_stderr { obj.call }

      expect(stdout).to match(%r{^.*test/integration/example/controls/default\.rb.+Failed.+missing_tests.*$})
    end
  end

  context 'when all files have tests' do
    it 'prints a success message' do
      stdout, = capture_stdout_and_stderr { obj.call }

      expect(stdout).to match(%r{^.*test/integration/example/controls/default\.rb.+Passed.*$})
    end
  end

  context 'when checking the error count before running the linter' do
    it 'fails with a RuntimeError' do
      expect { obj.error_count }.to raise_error(RuntimeError, 'Accessing results before the task has executed')
    end
  end

  context 'when checking the error count after running the linter' do
    it 'gives an integer with the number of files errored' do
      File.write('test/integration/example/controls/default.rb', bad_test)

      capture_stdout_and_stderr { obj.call }

      expect { obj.error_count }.not_to raise_error
      expect(obj.error_count).to eq 1
    end
  end
end
