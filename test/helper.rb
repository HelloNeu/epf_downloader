require 'bundler'
Bundler.setup

$LOAD_PATH << File.dirname(__FILE__) + "/../lib"

require 'minitest/autorun'
require 'webmock/minitest'
require 'mocha/mini_test'
require 'timecop'
require 'tmpdir'

require 'epf_downloader'

require 'active_support/testing/autorun'