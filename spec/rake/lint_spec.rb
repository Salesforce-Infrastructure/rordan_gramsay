RSpec.describe '[Cookbook] rake lint' do
  let(:cookbook_names) { %w[example other_example] }
  let(:all_tasks) do
    run_command('rake -AT').lines.map { |t| t.sub(/^\s*rake\s+([^\s]+)\s+#.*$/i, '\1').chomp }
  end
  let(:documented_tasks) do
    run_command('rake -T').lines.map { |t| t.sub(/^\s*rake\s+([^\s]+)\s+#.*$/i, '\1').chomp }
  end

  before(:all) do
    setup_monorepo! 'TEST_chef-repo'
  end
  after(:all) { teardown_monorepo! 'TEST_chef-repo' }

  around(:example) do |example|
    FileUtils.mkdir_p('TEST_chef-repo/cookbooks')
    FileUtils.cd('TEST_chef-repo/cookbooks') do
      %w[example other_example].each { |cookbook| setup_cookbook! cookbook }
    end

    with_monorepo('TEST_chef-repo') do
      cookbook_names.each do |cookbook|
        with_cookbook(cookbook) do
          example.run
        end
      end
    end

    FileUtils.rm_r('TEST_chef-repo/cookbooks', force: true)
  end

  context "with the rake task 'lint'" do
    it 'should be defined' do
      expect(all_tasks).to include 'lint'
    end

    it 'should be documented' do
      expect(documented_tasks).to include 'lint'
    end

    it "should defer to 'lint:all'" do
      out = run_command('rake --dry-run lint')
      expect(out).to include('lint:all')
    end
  end

  context "with the rake task 'lint:all'" do
    it 'should be defined' do
      expect(all_tasks).to include 'lint:all'
    end

    it 'should defer to a list of linting tasks' do
      out = run_command('rake --dry-run lint:all')
      %w[rubocop foodcritic comments tests kitchen].each do |subtask|
        expect(out).to include "lint:#{subtask}"
      end
    end
  end

  context "with the rake task 'lint:rubocop'" do
    it 'should be defined' do
      expect(all_tasks).to include 'lint:rubocop'
    end

    it 'should not raise exceptions' do
      out = run_command('rake --dry-run lint:rubocop')
      expect(out).not_to include 'rake aborted!'
    end
  end

  context "with the rake task 'lint:foodcritic'" do
    it 'should be defined' do
      expect(all_tasks).to include 'lint:foodcritic'
    end

    it 'should not raise exceptions' do
      out = run_command('rake --dry-run lint:foodcritic')
      expect(out).not_to include 'rake aborted!'
    end
  end

  context "with the rake task 'lint:comments'" do
    it 'should be defined' do
      expect(all_tasks).to include 'lint:comments'
    end

    it 'should not raise exceptions' do
      out = run_command('rake --dry-run lint:comments')
      expect(out).not_to include 'rake aborted!'
    end

    it 'should output successes in a meaningful way' do
      out = run_command('rake lint:comments')

      expect(out).to match(%r{^.*attributes/default\.rb.+Passed.*$}i)
      expect(out).to match(%r{^.*recipes/default\.rb.+Passed.*$}i)
      expect(out).not_to include 'rake aborted!'
    end

    it 'should output failures in a meaningful way' do
      File.write('attributes/default.rb', "# Some comment\nputs 'hello world!'\n" * 10)

      out = run_command('rake lint:comments')

      expect(out).to match(%r{^.*attributes/default\.rb.+Failed.*$}i)
      expect(out).to match(%r{^.*recipes/default\.rb.+Passed.*$}i)
    end
  end

  context "with the rake task 'lint:tests'" do
    let(:bad_test) do
      <<~INSPEC
        # The Inspec reference, with examples and extensive documentation, can be
        # found at http://inspec.io/docs/reference/resources/

        raise RuntimeError, 'Something went wrong'
      INSPEC
    end

    it 'should be defined' do
      expect(all_tasks).to include 'lint:tests'
    end

    it 'should not raise exceptions' do
      out = run_command('rake --dry-run lint:tests')
      expect(out).not_to include 'rake aborted!'
    end

    it 'should output successes in a meaningful way' do
      out = run_command('rake lint:tests')

      expect(out).to match(%r{^.*test/integration/(?:#{cookbook_names.map { |cb| Regexp.escape(cb) }.join('|')})/controls/default\.rb.+Passed.*$})
      expect(out).not_to include 'rake aborted!'
    end

    it 'should output failures in a meaningful way' do
      cookbook_names.each do |cb|
        next unless File.exist?(File.join('test', 'integration', cb))
        File.write(File.join('test', 'integration', cb, 'controls', 'default.rb'), bad_test)
      end

      out = run_command('rake lint:tests')

      expect(out).to match(%r{^.*test/integration/(?:#{cookbook_names.map { |cb| Regexp.escape(cb) }.join('|')})/controls/default\.rb.+Failed.*$})
      expect(out).to include 'rake aborted!'
    end
  end

  context "with the rake task 'lint:kitchen'" do
    let(:bad_kitchen) do
      <<~KITCHEN
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
      KITCHEN
    end

    it 'should be defined' do
      expect(all_tasks).to include 'lint:kitchen'
    end

    it 'should not raise exceptions' do
      out = run_command('rake --dry-run lint:kitchen')
      expect(out).not_to include 'rake aborted!'
    end

    it 'should output successes in a meaningful way' do
      out = run_command('rake lint:kitchen')

      expect(out).to match(/^.*\.kitchen\.yml.+Passed.*$/i)
      expect(out).not_to include 'rake aborted!'
    end

    it 'should output failures in a meaningful way' do
      File.write('.kitchen.yml', bad_kitchen)

      out = run_command('rake lint:kitchen')

      expect(out).to match(/^.*\.kitchen\.yml.+Failed.*$/i)
      expect(out).to include 'rake aborted!'
    end
  end
end
