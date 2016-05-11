require 'json'
require 'nokogiri'
load 'recognizer/utils.rb'
load 'recognizer/normalization.rb'
load 'recognizer/preprocessor.rb'
load 'recognizer/encoder.rb'

load 'recognizer/kvg_parser.rb'
load 'recognizer/datastore.rb'
load 'recognizer/trainer.rb'
load 'recognizer/template.rb'
load "recognizer/recognizer.rb"

task :init_datastore do
  datastore = JSONDatastore.new(ENV['SOURCE'])
  Template.parse_from_xml "kanjivg-20150615-2.xml", datastore
end

