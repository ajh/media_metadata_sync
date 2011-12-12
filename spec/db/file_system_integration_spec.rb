require 'helper'

describe MediaMetadataSync::DB::FileSystem, :integration do
  context "when working against a real filesystem" do
    describe "#read" do
      it "should add records to the queue" do
        pending 'parser work'
        f = described_class.new Pathname.new(__FILE__).dirname.join('../files')
        q = Queue.new
        f.read q

        while record = q.pop
          puts record.inspect
        end
      end
    end
  end
end
