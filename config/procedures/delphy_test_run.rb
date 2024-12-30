# config/procedures/delphy_test_run.rb
# DELPHY Test Procedure Script for COSMOS v4 Deployment
# Validates DELPHY operations including connections, commands, telemetry, and error handling.

require 'cosmos'
require 'cosmos/logging/logger'
require_relative '../../lib/delphy_tool'
require_relative '../../lib/delphy_constants'
require_relative '../../lib/delphy_errors'
require_relative '../../lib/delphy_helper'
require_relative '../../config/tools/delphy_tool_logger'

# --------------------------------------------
# DELPHY Test Run Procedure Class
# --------------------------------------------
class DelphyTestRun
  include DelphyConstants
  include DelphyHelper

  def initialize
    @tool = DelphyTool.new
    @logger = DelphyToolLogger.new
    Cosmos::Logger.info('[DELPHY_TEST_RUN] Initialized DELPHY Test Run Procedure')
  end

  # --------------------------------------------
  # TEST CASES
  # --------------------------------------------

  # Test Connection to DELPHY
  def test_connection
    begin
      @logger.info('Testing connection to DELPHY...')
      @tool.connect
      @logger.info('Connection test PASSED.')
    rescue DelphyError => e
      @logger.error("Connection test FAILED: #{e.message}")
      raise
    ensure
      @tool.disconnect
    end
  end

  # Test RUN_SCRIPT Command
  def test_run_script
    begin
      @logger.info('Testing RUN_SCRIPT command...')
      @tool.connect
      @tool.run_script(1, 123.45)
      @logger.info('RUN_SCRIPT command test PASSED.')
    rescue DelphyError => e
      @logger.error("RUN_SCRIPT command test FAILED: #{e.message}")
      raise
    ensure
      @tool.disconnect
    end
  end

  # Test SEND_MESSAGE Command
  def test_send_message
    begin
      @logger.info('Testing SEND_MESSAGE command...')
      @tool.connect
      @tool.send_message(0, 'Test message from DELPHY_TEST_RUN')
      @logger.info('SEND_MESSAGE command test PASSED.')
    rescue DelphyError => e
      @logger.error("SEND_MESSAGE command test FAILED: #{e.message}")
      raise
    ensure
      @tool.disconnect
    end
  end

  # Test RESET_SYSTEM Command
  def test_reset_system
    begin
      @logger.info('Testing RESET_SYSTEM command...')
      @tool.connect
      @tool.reset_system(0, 'Routine maintenance reset')
      @logger.info('RESET_SYSTEM command test PASSED.')
    rescue DelphyError => e
      @logger.error("RESET_SYSTEM command test FAILED: #{e.message}")
      raise
    ensure
      @tool.disconnect
    end
  end

  # Test Telemetry ACK
  def test_telemetry_ack
    begin
      @logger.info('Testing ACK telemetry...')
      @tool.connect
      packet = @tool.monitor_telemetry(:ack, ACK_TIMEOUT)
      if packet[:response_code] == 0
        @logger.info('ACK telemetry test PASSED.')
      else
        raise DelphyAcknowledgmentError, 'Invalid ACK response code received.'
      end
    rescue DelphyError => e
      @logger.error("ACK telemetry test FAILED: #{e.message}")
      raise
    ensure
      @tool.disconnect
    end
  end

  # Test Full Workflow
  def test_full_workflow
    begin
      @logger.info('Testing full DELPHY workflow...')
      @tool.execute_full_workflow(1, 456.78)
      @logger.info('Full workflow test PASSED.')
    rescue DelphyError => e
      @logger.error("Full workflow test FAILED: #{e.message}")
      raise
    ensure
      @tool.disconnect
    end
  end

  # Test Invalid Command Handling
  def test_invalid_command
    begin
      @logger.info('Testing invalid command handling...')
      @tool.connect
      DelphyHelper.send_command(TARGET, 'INVALID_COMMAND')
    rescue DelphyCommandError => e
      @logger.info("Invalid command test PASSED: #{e.message}")
    rescue StandardError => e
      @logger.error("Invalid command test FAILED: #{e.message}")
    ensure
      @tool.disconnect
    end
  end

  # --------------------------------------------
  # RUN ALL TESTS
  # --------------------------------------------
  def run_all_tests
    @logger.info('Starting DELPHY Test Run Procedure...')
    begin
      test_connection
      test_run_script
      test_send_message
      test_reset_system
      test_telemetry_ack
      test_invalid_command
      test_full_workflow
      @logger.info('All DELPHY tests PASSED successfully.')
    rescue DelphyError => e
      @logger.error("Test suite encountered an error: #{e.message}")
    ensure
      @tool.disconnect
      @logger.close_logger
    end
  end
end

# --------------------------------------------
# MAIN PROCEDURE EXECUTION
# --------------------------------------------
if __FILE__ == $PROGRAM_NAME
  tester = DelphyTestRun.new

  if ARGV.empty?
    tester.run_all_tests
  else
    case ARGV[0]
    when 'connection'
      tester.test_connection
    when 'run_script'
      tester.test_run_script
    when 'send_message'
      tester.test_send_message
    when 'reset_system'
      tester.test_reset_system
    when 'ack'
      tester.test_telemetry_ack
    when 'workflow'
      tester.test_full_workflow
    when 'invalid_command'
      tester.test_invalid_command
    else
      puts 'Usage:'
      puts '  ruby config/procedures/delphy_test_run.rb'
      puts '  ruby config/procedures/delphy_test_run.rb connection'
      puts '  ruby config/procedures/delphy_test_run.rb run_script'
      puts '  ruby config/procedures/delphy_test_run.rb send_message'
      puts '  ruby config/procedures/delphy_test_run.rb reset_system'
      puts '  ruby config/procedures/delphy_test_run.rb ack'
      puts '  ruby config/procedures/delphy_test_run.rb workflow'
      puts '  ruby config/procedures/delphy_test_run.rb invalid_command'
    end
  end
end
