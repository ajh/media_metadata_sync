require 'appscript'

module ITunes

  def self.run
    app = Appscript.app('iTunes')

    info = {}
    %w(album_rating rating location).each do |attr|
      app.file_tracks[1,10].send(attr).get.each_with_index do |val, i|
        (info[i] ||= {})[attr] = val
      end
    end

    puts info.inspect
  end
end

ITunes.run
