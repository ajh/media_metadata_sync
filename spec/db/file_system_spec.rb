require 'helper'

describe MediaMetadataSync::DB::FileSystem do
  describe "#initialize" do
    it "should take a root path" do
      f = described_class.new 'a/library/path'
      f.root_path.should == Pathname.new('a/library/path')
    end
  end

  describe "#read" do
    it "should add records to the queue" do
      pending 'a working taglib client'
      f = described_class.new Pathname.new(__FILE__).dirname.join('../files')
      f.read Queue.new
    end
  end

  describe ".uuids_of_paths" do
    it "should return a hash of uuids for passed paths" do
      described_class.stub(:shell) do
        <<-OUTPUT
path_1 [http://musicbrainz.org] 345678
pathb [http://musicbrainz.org] 191919
another/path [http://musicbrainz.org] 000111
        OUTPUT
      end

      expected = {
        "path_1" => "345678",
        "pathb" => "191919",
        "another/path" => "000111",
      }
      actual = described_class.uuids_of_paths %w(path_1 pathb another/path)
      actual.should == expected
    end

    it "should send batches to external program" do
      with_batch_size(2) do
        described_class.should_receive(:shell).exactly(3).times {"\n"}
        paths = ["path_name"] * 6
        described_class.uuids_of_paths paths
      end
    end

    it "should escape paths for shell" do
      described_class.should_receive(:shell) do |arg|
        arg.should match(%r/#{Regexp.escape('01\ a\ file\!\!\!.mp3')}/)
        "\n"
      end
      described_class.uuids_of_paths ["01 a file!!!.mp3"]
    end

    private

    def with_batch_size(size, &block)
      old_size = described_class::PATH_BATCH_SIZE
      described_class.send(:remove_const, 'PATH_BATCH_SIZE')
      described_class.send(:const_set, 'PATH_BATCH_SIZE', size)

      yield
    ensure
      described_class.send(:remove_const, 'PATH_BATCH_SIZE') rescue nil
      described_class.send(:const_set, 'PATH_BATCH_SIZE', old_size)
    end
  end
end
