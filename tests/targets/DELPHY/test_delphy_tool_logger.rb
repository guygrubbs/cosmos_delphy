# tests/targets/DELPHY/test_delphy_tool_logger.rb
require_relative 'test_helper'

RSpec.describe DelphyToolLogger do
  before(:each) do
    @logger = DelphyToolLogger.new('config/targets/DELPHY/tools/logs/test_logger.log', 'DEBUG')
  end

  it 'logs info messages correctly' do
    expect { @logger.log_info('Info log test') }.not_to raise_error
  end

  it 'logs error messages correctly' do
    expect { @logger.log_error('Error log test') }.not_to raise_error
  end

  it 'handles invalid log levels gracefully' do
    expect { @logger.log_debug(nil) }.not_to raise_error
  end

  after(:each) do
    @logger.close_logger
  end
end
