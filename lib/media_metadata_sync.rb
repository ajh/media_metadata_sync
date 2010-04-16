require 'rubygems'
require 'active_support'

$: << File.expand_path(File.dirname(__FILE__) + '/../lib')
require 'source/file_system'
require 'source/itunes'
require 'source/mb'
require 'script/itunes_to_musicbrainz'
