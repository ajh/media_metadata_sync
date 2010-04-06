def run
  system "./mb_track_id sample_file.mp3"
end

watch( 'mb_track_id' ) {|md| run }

Signal.trap('INT') { run }
