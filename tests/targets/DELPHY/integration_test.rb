#!/usr/bin/env ruby
# tests/targets/DELPHY/integration_test.rb
require 'cosmos'
require_relative '../../../config/targets/DELPHY/tools/delphy_script'
require_relative '../../../config/targets/DELPHY/tools/delphy_tool_test'
require_relative '../../../config/targets/DELPHY/tools/delphy_tool_logger'

# Integration Test Suite for DELPHY Tools
class DelphyIntegrationTest
  def initialize
    @script = DelphyScript.new
    @test = DelphyToolTest.new
    @logger = DelphyToolLogger.new('config/targets/DELPHY/tools/logs/integration_test.log', 'DEBUG')
    @logger.log_info('DELPHY Integration Test Initialized')
  end

  def test_connection
    @logger.log_info('Testing connection...')
    @script.connect
    @script.disconnect
  end

  def test_command_execution
    @logger.log_info('Testing command execution...')
    @script.run_script(1, 123.45)
    @script.reset_system(0, 'Integration Test Reset')
  end

  def test_telemetry
    @logger.log_info('Testing telemetry monitoring...')
    @test.test_telemetry_ack
    @test.test_telemetry_complete
  end

  def test_workflow
    @logger.log_info('Testing full workflow...')
    @script.execute_full_workflow(1, 123.45)
  end

  def run_all
    test_connection
    test_command_execution
    test_telemetry
    test_workflow
    @logger.log_info('All integration tests completed successfully')
  end
end

# Run Integration Tests
if __FILE__ == $PROGRAM_NAME
  test_suite = DelphyIntegrationTest.new
  test_suite.run_all
end
