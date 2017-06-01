require_relative '../../lib/rordan_gramsay/lint/kitchen_checker'

RSpec.describe RordanGramsay::Lint::KitchenChecker do
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

  let(:good_yml) do
    <<-EOF
    ---
    driver:
      name: vagrant
      customize:
        memory: 4096

    provisioner:
      name: chef_zero

    verifier:
      name: inspec

    platforms:
      - name: salesforce/server2016
        transport:
          name: winrm
        driver:
          gui: false

    suites:
      - name: default
        run_list:
          - recipe[example::default]
    EOF
  end
  let(:bad_yml) do
    <<-EOF
    ---
    driver:
      name: vagrant
      customize:
        memory: 4096

    provisioner:
      name: chef_solo

    verifier:
      name: serverspec

    platforms:
      - name: salesforce/server2016
        transport:
          name: winrm

    suites:
      - name: default
        run_list:
          - recipe[example::default]
    EOF
  end

  it 'should detect all files it needs to check' do
    FileUtils.mkdir_p '.kitchen'
    File.write('.kitchen.yml', good_yml)
    File.write('.kitchen.local.yml', bad_yml)
    File.write('.kitchen/foo.json', "{\n  \"some_key\": \"some value\"\n}\n")

    expect(files).not_to be_empty
    expect(files).to include '.kitchen.yml'
    expect(files).not_to include '.kitchen.local.yml'
    expect(files).not_to include '.kitchen/foo.json'
  end

  it 'displays files with absolute path' do
    expect(obj.files.all? { |f| f =~ %r{TEST_chef-repo/cookbooks/example/} }).to be_truthy
  end

  context "when the verifier is set to 'inspec'" do
    before(:each) do
      File.write('.kitchen.yml', good_yml)
    end

    it 'prints success message' do
      stdout, = capture_stdout_and_stderr { obj.call }

      expect(stdout).to match(/^.*\.kitchen\.yml.+Passed.*$/)
    end
  end

  context "when the verifier is set to 'serverspec'" do
    before(:each) do
      File.write('.kitchen.yml', bad_yml)
    end

    it 'prints failure message' do
      stdout, = capture_stdout_and_stderr { obj.call }

      expect(stdout).to match(/^.*\.kitchen\.yml.+Failed.*$/)
    end

    it 'prints the reason for the failure' do
      stdout, = capture_stdout_and_stderr { obj.call }

      expect(stdout).to match(/^.*\.kitchen\.yml.+Failed.+missing_inspec_verifier.*$/)
    end
  end

  context 'when the verifier is not set' do
    before(:each) do
      File.write('.kitchen.yml', "---\n")
    end

    it 'prints a failure message' do
      stdout, = capture_stdout_and_stderr { obj.call }

      expect(stdout).to match(/^.*\.kitchen\.yml.+Failed.*$/)
    end

    it 'prints the reason for the failure' do
      stdout, = capture_stdout_and_stderr { obj.call }

      expect(stdout).to match(/^.*\.kitchen\.yml.+Failed.+missing_inspec_verifier.*$/)
    end
  end

  context 'when checking the error count before running the linter' do
    it 'fails with a RuntimeError' do
      expect { obj.error_count }.to raise_error(RuntimeError, 'Accessing results before the task has executed')
    end
  end

  context 'when checking the error count after running the linter' do
    it 'gives an integer with the number of files errored' do
      File.write('.kitchen.yml', bad_yml)

      capture_stdout_and_stderr { obj.call }

      expect { obj.error_count }.not_to raise_error
      expect(obj.error_count).to eq 1
    end
  end
end
