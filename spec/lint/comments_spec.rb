require_relative '../../lib/rordan_gramsay/lint/cookbook_comments_checker'

RSpec.describe RordanGramsay::Lint::CookbookCommentsChecker do
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

  it 'should detect all files it needs to check' do
    File.write('attributes/default.rb', '')
    File.write('attributes/testing.json', "{\n  \"some_key\": \"some value\"\n}\n")

    expect(files).not_to be_empty
    expect(files).to include 'recipes/default.rb'
    expect(files).to include 'attributes/default.rb'
    expect(files).not_to include 'attributes/testing.json'
  end

  it 'displays files with absolute path' do
    expect(obj.files.all? { |f| f =~ %r{TEST_chef-repo/cookbooks/example/} }).to be_truthy
  end

  context 'when files have first 15 lines starting with "#"' do
    before(:each) do
      File.write('recipes/default.rb', "# some comment\n" * 15)
      File.write('libraries/foo_bar.rb', "# some other comment\n" * 15)
      File.write('attributes/testing.rb', "# some test comment\n" * 15)
    end

    it 'prints success message for each file' do
      stdout, = capture_stdout_and_stderr { obj.call }

      expect(stdout).to match(%r{^.*recipes/default\.rb.+Passed.*$})
      expect(stdout).to match(%r{^.*libraries/foo_bar\.rb.+Passed.*$})
      expect(stdout).to match(%r{^.*attributes/testing\.rb.+Passed.*$})
    end
  end

  context 'when file does not have sufficient comment lines' do
    before(:each) do
      File.write('recipes/default.rb', "# some comment\n" * 15)
      File.write('libraries/foo_bar.rb', ("# some other comment\n" * 2) + ("puts 'hello world'\n" * 3))
      File.write('attributes/testing.rb', "# some test comment\n" + ("puts 'no attributes to be found'\n" * 9))
    end

    it 'prints failure message for each affected file' do
      stdout, = capture_stdout_and_stderr { obj.call }

      expect(stdout).to match(%r{^.*recipes/default\.rb.+Passed.*$})
      expect(stdout).to match(%r{^.*libraries/foo_bar\.rb.+Failed.*$})
      expect(stdout).to match(%r{^.*attributes/testing\.rb.+Failed.*$})
    end

    it 'prints the reason for the failure' do
      stdout, = capture_stdout_and_stderr { obj.call }

      expect(stdout).to match(%r{^.*libraries/foo_bar\.rb.+Failed.+missing.+comments_at_top_of_file.*$})
      expect(stdout).to match(%r{^.*attributes/testing\.rb.+Failed.+missing.+comments_at_top_of_file.*$})
    end
  end

  context 'when checking the error count before running the linter' do
    it 'fails with a RuntimeError' do
      expect { obj.error_count }.to raise_error(RuntimeError, 'Accessing results before the task has executed')
    end
  end

  context 'when checking the error count after running the linter' do
    it 'gives an integer with the number of files errored' do
      File.write('recipes/default.rb', "# some comment\n" * 15)
      File.write('libraries/foo_bar.rb', ("# some other comment\n" * 2) + ("puts 'hello world'\n" * 3))
      File.write('attributes/testing.rb', "# some test comment\n" + ("puts 'no attributes to be found'\n" * 9))

      capture_stdout_and_stderr { obj.call }

      expect { obj.error_count }.not_to raise_error
      expect(obj.error_count).to eq 2
    end
  end
end
