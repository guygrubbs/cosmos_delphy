# tests/targets/DELPHY/integration_test.rb
# DELPHY Integration Test Suite for COSMOS Environment

require 'rspec'
require 'cosmos'
require_relative '../../../config/targets/DELPHY/tools/delphy_script'
require_relative '../../../config/targets/DELPHY/tools/delphy_tool_logger'
require_relative '../../../config/targets/DELPHY/tools/delphy_tool_test'
require_relative '../../../lib/delphy_constants'
require_relative '../../../lib/delphy_helper'

RSpec.describe 'DELPHY Integration Tests' do
  before(:all) do
    @logger = DelphyToolLogger.new('config/targets/DELPHY/tools/logs/integration_test.log', 'DEBUG')
    @script = DelphyScript.new
    @test = DelphyToolTest.new
    @logger.info('Integration tests initialized.')
  end

  after(:all) do
    @script.disconnect
    @logger.info('Integration tests completed.')
    @logger.close_logger
  end

  # --------------------------------------------
  # 1. CONNECTION AND DISCONNECTION
  # --------------------------------------------
  it 'establishes and disconnects a connection successfully' do
    expect { @script.connect }.not_to raise_error
    @logger.info('Connection established successfully.')
    expect { @script.disconnect }.not_to raise_error
    @logger.info('Connection disconnected successfully.')
  end

  # --------------------------------------------
  # 2. COMMAND EXECUTION
  # --------------------------------------------
  it 'executes RUN_SCRIPT command successfully' do
    @script.connect
    expect { @script.run_script(1, 123.45) }.not_to raise_error
    @logger.info('RUN_SCRIPT command executed successfully.')
    @script.disconnect
  end

  it 'executes RESET_SYSTEM command successfully' do
    @script.connect
    expect { @script.reset_system(0, 'Integration Test Reset') }.not_to raise_error
    @logger.info('RESET_SYSTEM command executed successfully.')
    @script.disconnect
  end

  # --------------------------------------------
  # 3. TELEMETRY MONITORING
  # --------------------------------------------
  it 'receives ACK telemetry successfully' do
    @script.connect
    telemetry = @script.monitor_telemetry(:ack, 10)
    expect(telemetry[:response_code]).to eq(0)
    @logger.info('ACK telemetry received and validated successfully.')
    @script.disconnect
  end

  it 'receives COMPLETE telemetry successfully' do
    @script.connect
    telemetry = @script.monitor_telemetry(:complete, 10)
    expect(telemetry[:status_code]).to eq(0)
    @logger.info('COMPLETE telemetry received and validated successfully.')
    @script.disconnect
  end

  # --------------------------------------------
  # 4. WORKFLOW VALIDATION
  # --------------------------------------------
  it 'executes a full workflow successfully' do
    expect { @script.execute_full_workflow(1, 123.45) }.not_to raise_error
    @logger.info('Full workflow executed successfully.')
  end

  # --------------------------------------------
  # 5. ERROR HANDLING VALIDATION
  # --------------------------------------------
  it 'handles invalid command gracefully' do
    @script.connect
    expect { @script.run_script(nil, nil) }.to raise_error(StandardError)
    @logger.info('Invalid command was handled gracefully.')
    @script.disconnect
  end
end
