# tests/targets/DELPHY/test_helper.rb
require 'rspec'
require 'cosmos'
require_relative '../../../config/targets/DELPHY/tools/delphy_script'
require_relative '../../../config/targets/DELPHY/tools/delphy_tool_gui'
require_relative '../../../config/targets/DELPHY/tools/delphy_tool_logger'
require_relative '../../../config/targets/DELPHY/tools/delphy_tool_test'
require_relative '../../../lib/delphy_constants'
require_relative '../../../lib/delphy_helper'

RSpec.configure do |config|
  config.before(:each) do
    # Common setup for all tests
    @logger = DelphyToolLogger.new('config/targets/DELPHY/tools/logs/test_log.log', 'DEBUG')
  end

  config.after(:each) do
    # Cleanup resources after tests
    @logger.close_logger
  end
end
