require_relative '../lib/rordan_gramsay/cli'

RSpec.describe RordanGramsay::CLI do
  let(:default_args) { %w[init rakefile --force] }
  let(:remaining_args) { default_args.dup }
  let(:cli) { described_class.new(remaining_args) }

  # We could either stub the write to the filesystem, or
  # create a temp directory to sandbox the writes. The
  # latter allows us to test the effects to the filesystem
  # so that seems like the better option.
  around(:example) do |example|
    tmpdir = "tmp-#{Process.pid}"
    FileUtils.mkdir_p(tmpdir)
    FileUtils.cd(tmpdir) do
      example.run
    end
    FileUtils.rm_r(tmpdir, force: true)
  end

  it 'should initialize without raising an error' do
    expect {
      capture_stdout_and_stderr { cli }
    }.not_to raise_error
  end

  context 'in parsing the given command line options' do
    it 'detects the subcommand' do
      expect(cli.send(:instance_variable_get, :@action)).to eq default_args[0]
    end

    it 'detects CLI flags' do
      expect(cli.opt.force).to eq default_args.include?('--force')
      expect(cli.opt.debug).to eq default_args.include?('--debug')
    end
  end

  context 'when an unknown subcommand is given' do
    let(:default_args) { %w[derpyflerp hoo-ah] }

    it 'prints an error message to STDERR' do
      expect { cli }.not_to raise_error

      stdout, stderr = capture_stdout_and_stderr { cli.call }

      expect(stderr).not_to be_empty
      expect(stdout).to be_empty
    end
  end

  context "when '--version' is given" do
    let(:default_args) { %w[init --version] }

    it 'does not process any subcommands' do
      capture_stdout_and_stderr { cli }
      expect(cli.send(:instance_variable_get, :@action_status)).to eq :complete

      stdout, stderr = capture_stdout_and_stderr { cli.call }

      expect(stdout).to be_empty
      expect(stderr).to be_empty
    end

    it 'prints the version number' do
      stdout, stderr = capture_stdout_and_stderr { cli.call }

      expect(stdout).to match(/^gramsay v\d+\.\d+\.\d+$/)
      expect(stderr).to be_empty
    end
  end

  context "when '--help' is given" do
    let(:default_args) { %w[init --help] }

    it 'does not process any subcommands' do
      capture_stdout_and_stderr { cli }
      expect(cli.send(:instance_variable_get, :@action_status)).to eq :complete

      stdout, stderr = capture_stdout_and_stderr { cli.call }

      expect(stdout).to be_empty
      expect(stderr).to be_empty
    end

    it 'prints the usage info' do
      stdout, stderr = capture_stdout_and_stderr { cli.call }

      expect(stdout).to match(/Usage:\s+gramsay/i)
      expect(stdout).to match(/--version\s+Show version/i)
      expect(stdout).to match(/--help\s+Show this message/i)
      expect(stderr).to be_empty
    end
  end
end
