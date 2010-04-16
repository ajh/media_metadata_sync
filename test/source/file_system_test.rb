require 'test/helper.rb'

module Source
  class FileSystemTest < Test::Unit::TestCase

    context "uuids_of_paths" do

      should "return a hash of uuids for passed paths" do
        stub(FileSystem).shell do
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
        actual = Source::FileSystem.uuids_of_paths %w(path_1 pathb another/path)
        assert_equal expected, actual
      end

      should "send batches to external program" do
        stub(FileSystem).shell {"\n"}

        paths = ["path_name"] * Source::FileSystem::PATH_BATCH_SIZE * 3
        Source::FileSystem.uuids_of_paths paths

        assert_received(FileSystem) {|fs| fs.shell(anything).times(3)}
      end

      should "escape paths for shell" do
        stub(FileSystem).shell {"\n"}

        Source::FileSystem.uuids_of_paths ["01 a file!!!.mp3"]

        assert_received(FileSystem) {|fs| fs.shell %r/#{Regexp.escape('01\ a\ file\!\!\!.mp3')}/ }
      end
    end
  end
end
