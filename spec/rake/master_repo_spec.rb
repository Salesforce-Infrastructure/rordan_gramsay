RSpec.describe 'Mono-Repo' do
  let(:cookbook_names) { %w[example other_example] }
  let(:all_tasks) do
    `rake -AT`.lines.map { |t| t.sub(/^\s*rake\s+([^\s]+)\s+#.*$/i, '\1').chomp }
  end
  let(:documented_tasks) do
    `rake -T`.lines.map { |t| t.sub(/^\s*rake\s+([^\s]+)\s+#.*$/i, '\1').chomp }
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
      example.run
    end
  end

  context 'when setting up RSpec tests' do
    it 'should generate some cookbooks' do
      names = Dir.glob('./cookbooks/*')
                 .select { |d| File.directory? d }
                 .map { |d| File.basename(d) }

      expect(names).to match_array cookbook_names
    end

    it 'should have fully-structured dummy cookbooks' do
      cookbook_names.each do |cookbook|
        with_cookbook(cookbook) do
          expect(File.file?('Berksfile')).to be_truthy
          expect(File.file?('metadata.rb')).to be_truthy
          expect(File.file?('.kitchen.yml')).to be_truthy
          expect(File.directory?('test')).to be_truthy
          expect(File.file?('recipes/default.rb')).to be_truthy
        end
      end
    end
  end

  context "with the rake task 'kitchen'" do
    it 'should be defined' do
      expect(all_tasks).to include 'kitchen'
    end
  end

  context "with the rake task 'lint'" do
    it 'should be defined' do
      expect(all_tasks).to include 'lint'
    end

    it 'should be documented' do
      expect(documented_tasks).to include 'lint'
    end
  end

  context "with the rake task 'test'" do
    it 'should be defined' do
      expect(all_tasks).to include 'test'
    end

    it 'should be documented' do
      expect(documented_tasks).to include 'test'
    end
  end
end
