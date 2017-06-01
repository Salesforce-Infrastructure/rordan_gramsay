require_relative '../../lib/rordan_gramsay/lint/test_checker'

RSpec.describe RordanGramsay::Lint::TestChecker do
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

  let(:good_test) do
    <<-EOF
    # # encoding: utf-8

    # Inspec test for recipe example::default

    # The Inspec reference, with examples and extensive documentation, can be
    # found at http://inspec.io/docs/reference/resources/

    unless os.windows?
      describe user('root') do
        it { should exist }
        # skip 'This is an example test, replace with your own test.'
      end
    end

    filename = if os.windows?
                 'C:\\\\cheftest.txt'
               else
                 '/tmp/cheftest.txt'
               end

    describe file(filename) do
      it { should exist }
      its('content') { should include('Hello world!') }
    end
    EOF
  end
  let(:bad_test) do
    <<-EOF
    # # encoding: utf-8

    # Inspec test for recipe example::default

    # The Inspec reference, with examples and extensive documentation, can be
    # found at http://inspec.io/docs/reference/resources/

    raise RuntimeError, 'Something went wrong'
    EOF
  end

  it 'should detect all files it needs to check' do
    FileUtils.mkdir_p 'test/smoke/default'
    FileUtils.mkdir_p 'test/smoke/other'
    FileUtils.mkdir_p 'test/smoke/profile/controls'
    FileUtils.mkdir_p 'test/smoke/profile/libraries'

    File.write('test/smoke/default/some_test.rb', '')
    File.write('test/smoke/other/some_other_test.rb', '')
    File.write('test/smoke/profile/inspec.yml', "---\n")
    File.write('test/smoke/profile/libraries/foo_lib.rb', '')
    File.write('test/smoke/profile/controls/awesome_stuff.rb', '')
    File.write('test/smoke/profile/some_random_file.rb', '')

    expect(files).not_to be_empty
    expect(files).to include 'test/smoke/default/some_test.rb'
    expect(files).to include 'test/smoke/other/some_other_test.rb'
    expect(files).not_to include 'test/smoke/profile/inspec.yml'
    expect(files).not_to include 'test/smoke/profile/libraries/foo_lib.rb'
    expect(files).to include 'test/smoke/profile/controls/awesome_stuff.rb'
    expect(files).not_to include 'test/smoke/profile/some_random_file.rb'
  end

  it 'displays files with absolute path' do
    expect(obj.files.all? { |f| f =~ %r{TEST_chef-repo/cookbooks/example/} }).to be_truthy
  end

  context 'when file exists but is empty' do
    before(:each) do
      FileUtils.mkdir_p 'test/smoke/default'
      File.write('test/smoke/default/some_test.rb', "\n\n\n")
    end

    it 'prints a failure message' do
      stdout, = capture_stdout_and_stderr { obj.call }

      expect(stdout).to match(%r{^.*test/smoke/default/some_test\.rb.+Failed.*$})
    end

    it 'prints the reason for the failure' do
      stdout, = capture_stdout_and_stderr { obj.call }

      expect(stdout).to match(%r{^.*test/smoke/default/some_test\.rb.+Failed.+missing_tests.*$})
    end
  end

  context 'when all files have tests' do
    before(:each) do
      FileUtils.mkdir_p 'test/smoke/default'
      File.write('test/smoke/default/some_test.rb', good_test)
      File.write('test/smoke/default/some_other_test.rb', good_test)
    end

    it 'prints a success message' do
      stdout, = capture_stdout_and_stderr { obj.call }

      expect(stdout).to match(%r{^.*test/smoke/default/some_test\.rb.+Passed.*$})
      expect(stdout).to match(%r{^.*test/smoke/default/some_other_test\.rb.+Passed.*$})
    end
  end

  context 'when checking the error count before running the linter' do
    it 'fails with a RuntimeError' do
      expect { obj.error_count }.to raise_error(RuntimeError, 'Accessing results before the task has executed')
    end
  end

  context 'when checking the error count after running the linter' do
    it 'gives an integer with the number of files errored' do
      FileUtils.mkdir_p 'test/smoke/default'
      File.write('test/smoke/default/some_test.rb', bad_test)
      File.write('test/smoke/default/some_other_test.rb', bad_test)

      capture_stdout_and_stderr { obj.call }

      expect { obj.error_count }.not_to raise_error
      expect(obj.error_count).to eq 2
    end
  end
end
