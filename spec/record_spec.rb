require 'helper'

describe MediaMetadataSync::Record do
  attrs = %w(
    album_rating
    location
    name
    rating
    music_brainz_id
  )

  attrs.each do |attr|
    it "should accept #{attr}" do
      expect {
        described_class.new attr => 'a value'
      }.to_not raise_error(ArgumentError)
    end
  end
end
