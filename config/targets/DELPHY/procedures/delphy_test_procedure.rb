# config/targets/DELPHY/procedures/delphy_test_procedure.rb
# DELPHY Test Procedure Script for COSMOS v4 Deployment
# Validates system health, connectivity, command execution, telemetry monitoring, and error handling.

require 'cosmos'
require 'cosmos/logging/logger'
require_relative '../../../lib/delphy_tool'
require_relative '../../../lib/delphy_constants'
require_relative '../../../lib/delphy_errors'
require_relative '../../../lib/delphy_helper'
require_relative '../../../lib/delphy_packet_parser'
require_relative '../../../config/tools/delphy_tool_logger'

# --------------------------------------------
# DELPHY Test Procedure Class
# --------------------------------------------
class DelphyTestProcedure
  include DelphyConstants
  include DelphyHelper

  def initialize
    @tool = DelphyTool.new
    @logger = DelphyToolLogger.new
    Cosmos::Logger.info('[DELPHY_TEST_PROCEDURE] DELPHY Test Procedure Initialized')
  end

  # --------------------------------------------
  # TEST CASES
  # --------------------------------------------

  ## 1. Connectivity Test
  def test_connectivity
    begin
      @logger.info('Testing DELPHY connectivity...')
      @tool.connect
      @logger.info('Connectivity test PASSED.')
    rescue DelphyConnectionError => e
      @logger.error("Connectivity test FAILED: #{e.message}")
      raise
    ensure
      @tool.disconnect
    end
  end

  ## 2. Command Execution Test
  def test_command_execution
    begin
      @logger.info('Testing command execution...')
      @tool.connect
      @tool.run_script(1, 42.0)
      @tool.send_message(0, 'Command execution test message')
      @logger.info('Command execution test PASSED.')
    rescue DelphyCommandError => e
      @logger.error("Command execution test FAILED: #{e.message}")
      raise
    ensure
      @tool.disconnect
    end
  end

  ## 3. Telemetry Test
  def test_telemetry
    begin
      @logger.info('Testing telemetry reception...')
      @tool.connect
      ack_packet = @tool.monitor_telemetry(:ack, ACK_TIMEOUT)
      complete_packet = @tool.monitor_telemetry(:complete, COMPLETE_TIMEOUT)

      if ack_packet[:response_code] != 0
        raise DelphyAcknowledgmentError, 'Invalid ACK telemetry response.'
      end

      if complete_packet[:status_code] != 0
        raise DelphyAcknowledgmentError, 'Invalid COMPLETE telemetry response.'
      end

      @logger.info('Telemetry test PASSED.')
    rescue DelphyTelemetryTimeoutError => e
      @logger.error("Telemetry test FAILED: #{e.message}")
      raise
    ensure
      @tool.disconnect
    end
  end

  ## 4. System Reset Test
  def test_system_reset
    begin
      @logger.info('Testing system reset...')
      @tool.connect
      @tool.reset_system(0, 'System reset during test')
      @logger.info('System reset test PASSED.')
    rescue DelphyCommandError => e
      @logger.error("System reset test FAILED: #{e.message}")
      raise
    ensure
      @tool.disconnect
    end
  end

  ## 5. Error Handling Test
  def test_error_handling
    begin
      @logger.info('Testing error handling with invalid command...')
      @tool.connect
      DelphyHelper.send_command(TARGET, 'INVALID_COMMAND')
    rescue DelphyCommandError => e
      @logger.info("Error handling test PASSED: #{e.message}")
    rescue StandardError => e
      @logger.error("Error handling test FAILED: #{e.message}")
      raise
    ensure
      @tool.disconnect
    end
  end

  ## 6. Diagnostics Test
  def test_diagnostics
    begin
      @logger.info('Testing diagnostics...')
      @tool.connect
      @tool.perform_diagnostics
      @logger.info('Diagnostics test PASSED.')
    rescue DelphyError => e
      @logger.error("Diagnostics test FAILED: #{e.message}")
      raise
    ensure
      @tool.disconnect
    end
  end

  ## 7. Configuration Validation Test
  def test_configuration
    begin
      @logger.info('Validating configuration parameters...')
      @tool.connect
      DelphyHelper.validate_parameter(50.0, 0.0, 100.0)
      @logger.info('Configuration validation PASSED.')
    rescue DelphyConfigurationError => e
      @logger.error("Configuration validation FAILED: #{e.message}")
      raise
    ensure
      @tool.disconnect
    end
  end

  # --------------------------------------------
  # FULL TEST SUITE
  # --------------------------------------------
  def run_all_tests
    @logger.info('Starting DELPHY Full Test Suite...')
    begin
      test_connectivity
      test_command_execution
      test_telemetry
      test_system_reset
      test_error_handling
      test_diagnostics
      test_configuration
      @logger.info('DELPHY Full Test Suite COMPLETED successfully.')
    rescue DelphyError => e
      @logger.error("Test suite FAILED: #{e.message}")
    ensure
      @tool.disconnect
      @logger.close_logger
    end
  end

  # --------------------------------------------
  # INTERACTIVE SESSION
  # --------------------------------------------
  def interactive_session
    puts '--- DELPHY Test Procedure Interactive Session ---'
    puts 'Available Test Commands:'
    puts '1. test_connectivity'
    puts '2. test_command_execution'
    puts '3. test_telemetry'
    puts '4. test_system_reset'
    puts '5. test_error_handling'
    puts '6. test_diagnostics'
    puts '7. test_configuration'
    puts '8. run_all_tests'
    puts '9. exit'

    loop do
      print '> '
      input = gets.chomp

      case input
      when 'test_connectivity'
        test_connectivity
      when 'test_command_execution'
        test_command_execution
      when 'test_telemetry'
        test_telemetry
      when 'test_system_reset'
        test_system_reset
      when 'test_error_handling'
        test_error_handling
      when 'test_diagnostics'
        test_diagnostics
      when 'test_configuration'
        test_configuration
      when 'run_all_tests'
        run_all_tests
      when 'exit'
        puts 'Exiting test session...'
        break
      else
        puts 'Unknown command. Please try again.'
      end
    end
  rescue Interrupt
    puts "\nExiting session..."
    @tool.disconnect
  rescue StandardError => e
    @logger.error("Interactive session error: #{e.message}")
    puts "Error: #{e.message}"
  ensure
    @logger.close_logger
  end
end

# --------------------------------------------
# MAIN PROCEDURE EXECUTION
# --------------------------------------------
if __FILE__ == $PROGRAM_NAME
  tester = DelphyTestProcedure.new

  if ARGV.empty?
    tester.interactive_session
  else
    case ARGV[0]
    when 'run_all'
      tester.run_all_tests
    else
      puts 'Usage:'
      puts '  ruby config/targets/DELPHY/procedures/delphy_test_procedure.rb run_all'
    end
  end
end
