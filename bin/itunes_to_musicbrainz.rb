#!/usr/bin/ruby

$: << File.expand_path(File.dirname(__FILE__) + '/../lib')
require 'media_metadata_sync'

Script::ItunesToMusicbrainz.run
