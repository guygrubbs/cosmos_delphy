# tests/targets/DELPHY/test_delphy_tool_test.rb
require_relative 'test_helper'

RSpec.describe DelphyToolTest do
  before(:each) do
    @test = DelphyToolTest.new
  end

  it 'tests connection successfully' do
    expect { @test.test_connection }.not_to raise_error
    @logger.log_info('Connection test passed')
  end

  it 'tests RUN_SCRIPT command successfully' do
    expect { @test.test_run_script }.not_to raise_error
    @logger.log_info('RUN_SCRIPT command test passed')
  end

  it 'tests telemetry acknowledgment successfully' do
    expect { @test.test_telemetry_ack }.not_to raise_error
    @logger.log_info('Telemetry ACK test passed')
  end

  it 'handles invalid command gracefully' do
    expect { @test.test_invalid_command }.not_to raise_error
    @logger.log_info('Invalid command test passed')
  end

  after(:each) do
    @test.test_connection
  end
end
