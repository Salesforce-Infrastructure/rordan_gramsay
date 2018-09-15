require_relative '../../lib/rordan_gramsay/cli'

RSpec.describe RordanGramsay::CLI do
  let(:default_args) { %w[init rakefile] }
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

  context "with 'init rakefile' commands" do
    it 'should create a Rakefile' do
      rakefile_contents = '# cookbook rakefile'
      allow(cli).to receive(:cookbook_rakefile_contents).and_return(rakefile_contents)

      stdout, _stderr = capture_stdout_and_stderr { cli.call }

      expect(File.read('Rakefile')).to eq rakefile_contents
      expect(stdout).to match(/cookbook/i)
      expect(stdout).to match(/^created rakefile/i)
    end

    context 'when Rakefile already exists' do
      before(:each) do
        File.write('Rakefile', '# Some rakefile contents')
      end

      it 'should display an error message' do
        rakefile_contents = '# cookbook rakefile'
        allow(cli).to receive(:cookbook_rakefile_contents).and_return(rakefile_contents)

        stdout, _stderr = capture_stdout_and_stderr { cli.call }

        expect(stdout).to include 'Rakefile'
        expect(stdout).to include 'already exists'
      end

      it 'should not modify the rakefile' do
        expect {
          capture_stdout_and_stderr { cli.call }
        }.not_to(change {
          File.read('Rakefile')
        })
      end
    end
  end

  context "with 'init rakefile --force'" do
    let(:default_args) { %w[init rakefile --force] }

    it 'should create a Rakefile' do
      rakefile_contents = '# cookbook rakefile'
      allow(cli).to receive(:cookbook_rakefile_contents).and_return(rakefile_contents)

      stdout, _stderr = capture_stdout_and_stderr { cli.call }

      expect(File.read('Rakefile')).to eq rakefile_contents
      expect(stdout).to match(/cookbook/i)
      expect(stdout).to match(/^created rakefile/i)
    end

    context 'when Rakefile already exists' do
      before(:each) do
        File.write('Rakefile', '# Some rakefile contents')
      end

      it 'should overwrite the existing Rakefile' do
        rakefile_contents = '# cookbook rakefile'
        allow(cli).to receive(:cookbook_rakefile_contents).and_return(rakefile_contents)

        stdout, _stderr = capture_stdout_and_stderr { cli.call }

        expect(File.read('Rakefile')).to eq rakefile_contents
        expect(stdout).to match(/overwriting/i)
        expect(stdout).to match(/cookbook/i)
        expect(stdout).to match(/^created rakefile/i)
      end
    end
  end
end
