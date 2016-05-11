require 'bundler'
Bundler.require

RECOGNIZER_DIR = File.expand_path('../recognizer', __FILE__)
require "#{RECOGNIZER_DIR}/utils.rb"
require "#{RECOGNIZER_DIR}/normalization.rb"
require "#{RECOGNIZER_DIR}/preprocessor.rb"
require "#{RECOGNIZER_DIR}/encoder.rb"

require "#{RECOGNIZER_DIR}/kvg_parser.rb"
require "#{RECOGNIZER_DIR}/datastore.rb"
require "#{RECOGNIZER_DIR}/trainer.rb"
require "#{RECOGNIZER_DIR}/template.rb"

require 'levenshtein'
include Levenshtein
require "#{RECOGNIZER_DIR}/recognizer.rb"

require 'pry'

API_DIR = File.expand_path('../app/api', __FILE__)

%w(defaults.rb version1.rb base.rb).each do |file|
  require "#{API_DIR}/#{file}"
end

DATASTORE = JSONDatastore.new('character_codes.json')
