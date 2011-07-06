$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'ap'
require 'rspec'
require 'ircd_slim'

RSpec.configure do |config|
end
