RSpec.describe '[Cookbook] rake kitchen' do
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

  context "with the rake task 'kitchen'" do
    it 'should be defined' do
      expect(all_tasks).to include 'kitchen'
    end

    it 'should be documented' do
      expect(documented_tasks).to include 'kitchen'
    end
  end

  context "with the rake task 'kitchen:create'" do
    it 'should be defined' do
      expect(all_tasks).to include 'kitchen:create'
    end
  end

  context "with the rake task 'kitchen:converge'" do
    it 'should be defined' do
      expect(all_tasks).to include 'kitchen:converge'
    end
  end

  context "with the rake task 'kitchen:verify'" do
    it 'should be defined' do
      expect(all_tasks).to include 'kitchen:verify'
    end
  end

  context "with the rake task 'kitchen:lint'" do
    it 'should be defined' do
      expect(all_tasks).to include 'kitchen:test'
    end

    it "should defer to 'lint:kitchen'" do
      out = run_command('rake --dry-run kitchen:lint')
      expect(out).to include('lint:kitchen')
    end
  end

  context "with the rake task 'kitchen:test'" do
    it 'should be defined' do
      expect(all_tasks).to include 'kitchen:test'
    end
  end

  # context "with the rake task 'kitchen:TASK'" do
  #   it 'should be defined' do
  #     expect(all_tasks).to include 'kitchen:TASK'
  #   end

  #   it 'should be documented' do
  #     expect(documented_tasks).to include 'kitchen:TASK'
  #   end
  # end
end
