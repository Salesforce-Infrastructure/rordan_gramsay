RSpec.describe '[Cookbook] rake lint' do
  let(:cookbook_names) { %w(example other_example) }
  let(:all_tasks) do
    run_command('rake -AT').lines.map { |t| t.sub(/^\s*rake\s+([^\s]+)\s+#.*$/i, '\1').chomp }
  end
  let(:documented_tasks) do
    run_command('rake -T').lines.map { |t| t.sub(/^\s*rake\s+([^\s]+)\s+#.*$/i, '\1').chomp }
  end

  before(:all) do
    setup_monorepo! 'TEST_chef-repo'
    FileUtils.cd('TEST_chef-repo/cookbooks') do
      %w(example other_example).each { |cookbook| setup_cookbook! cookbook }
    end
  end
  after(:all) { teardown_monorepo! 'TEST_chef-repo' }

  around(:example) do |example|
    with_monorepo('TEST_chef-repo') do
      cookbook_names.each do |cookbook|
        with_cookbook(cookbook) do
          example.run
        end
      end
    end
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
      %w(rubocop foodcritic comments tests kitchen).each do |subtask|
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
      File.write('attributes/default.rb', "# Some other comment\n" * 10)
      File.write('recipes/default.rb', "# some comment\n" * 20)

      out = run_command('rake lint:comments')

      expect(out).to match(%r{^.*attributes/default\.rb.+Passed.*$}i)
      expect(out).to match(%r{^.*recipes/default\.rb.+Passed.*$}i)
      expect(out).not_to include 'rake aborted!'
    end

    it 'should output failures in a meaningful way' do
      File.write('attributes/default.rb', "# Some comment\nputs 'hello world!'\n" * 10)
      File.write('recipes/default.rb', "# some comment\n" * 20)

      out = run_command('rake lint:comments')

      expect(out).to match(%r{^.*attributes/default\.rb.+Failed.*$}i)
      expect(out).to match(%r{^.*recipes/default\.rb.+Passed.*$}i)
    end
  end

  context "with the rake task 'lint:tests'" do
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
      # The Inspec reference, with examples and extensive documentation, can be
      # found at http://inspec.io/docs/reference/resources/

      raise RuntimeError, 'Something went wrong'
      EOF
    end

    it 'should be defined' do
      expect(all_tasks).to include 'lint:tests'
    end

    it 'should not raise exceptions' do
      out = run_command('rake --dry-run lint:tests')
      expect(out).not_to include 'rake aborted!'
    end

    it 'should output successes in a meaningful way' do
      FileUtils.mkdir_p 'test/smoke/default'
      File.write('test/smoke/default/some_random_file.rb', good_test)

      out = run_command('rake lint:tests')

      expect(out).to match(%r{^.*test/smoke/default/some_random_file\.rb.+Passed.*$})
      expect(out).not_to include 'rake aborted!'
    end

    it 'should output failures in a meaningful way' do
      FileUtils.mkdir_p 'test/smoke/default'
      File.write('test/smoke/default/some_random_file.rb', bad_test)

      out = run_command('rake lint:tests')

      expect(out).to match(%r{^.*test/smoke/default/some_random_file\.rb.+Failed.*$})
      expect(out).to include 'rake aborted!'
    end
  end

  context "with the rake task 'lint:kitchen'" do
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

    it 'should be defined' do
      expect(all_tasks).to include 'lint:kitchen'
    end

    it 'should not raise exceptions' do
      out = run_command('rake --dry-run lint:kitchen')
      expect(out).not_to include 'rake aborted!'
    end

    it 'should output successes in a meaningful way' do
      File.write('.kitchen.yml', good_yml)

      out = run_command('rake lint:kitchen')

      expect(out).to match(/^.*\.kitchen\.yml.+Passed.*$/i)
      expect(out).not_to include 'rake aborted!'
    end

    it 'should output failures in a meaningful way' do
      File.write('.kitchen.yml', bad_yml)

      out = run_command('rake lint:kitchen')

      expect(out).to match(/^.*\.kitchen\.yml.+Failed.*$/i)
      expect(out).to include 'rake aborted!'
    end
  end
end
