RSpec.describe '[Cookbook] rake test' do
  let(:cookbook_names) { %w[example other_example] }
  let(:all_tasks) do
    run_command('rake -AT').lines.map { |t| t.sub(/^\s*rake\s+([^\s]+)\s+#.*$/i, '\1').chomp }
  end
  let(:documented_tasks) do
    run_command('rake -T').lines.map { |t| t.sub(/^\s*rake\s+([^\s]+)\s+#.*$/i, '\1').chomp }
  end

  before(:all) do
    setup_monorepo! 'TEST_chef-repo'
    FileUtils.cd('TEST_chef-repo/cookbooks') do
      %w[example other_example].each { |cookbook| setup_cookbook! cookbook }
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

  context "with the rake task 'test'" do
    it 'should be defined' do
      expect(all_tasks).to include 'test'
    end

    it 'should be documented' do
      expect(documented_tasks).to include 'test'
    end

    it "should defer to 'test:all'" do
      out = run_command('rake --dry-run test')
      expect(out).to include('test:all')
    end
  end

  context "with the rake task 'test:quick'" do
    it 'should be defined' do
      expect(all_tasks).to include 'test:quick'
    end

    it "should defer to 'lint:all' and 'dependency:check'" do
      out = run_command('rake --dry-run test:quick')
      expect(out).to include 'lint:all'
      expect(out).to include 'dependency:check'
    end
  end

  context "with the rake task 'test:slow'" do
    it 'should be defined' do
      expect(all_tasks).to include 'test:slow'
    end

    it "should defer to 'kitchen:test'" do
      out = run_command('rake --dry-run test:slow')
      expect(out).to include('kitchen:test')
    end
  end

  context "with the rake task 'test:all'" do
    it 'should be defined' do
      expect(all_tasks).to include 'test:all'
    end

    it "should defer to 'test:quick' and 'test:slow'" do
      out = run_command('rake --dry-run test:all')
      expect(out).to include('test:quick')
      expect(out).to include('test:slow')
    end
  end
end
