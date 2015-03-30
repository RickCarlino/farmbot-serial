require 'simplecov'

SimpleCov.start do
  add_filter "/spec/"
end
require 'pry'
require 'farmbot-serial'

RSpec.configure do |config|
end
