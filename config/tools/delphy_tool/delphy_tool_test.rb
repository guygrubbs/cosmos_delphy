# config/tools/delphy_tool_test.rb
# DELPHY Tool Test Suite for COSMOS v4 Deployment
# Validates connection, commands, telemetry, and error handling.

require 'cosmos'
require 'cosmos/logging/logger'
require_relative '../../lib/delphy_tool'
require_relative '../../lib/delphy_constants'
require_relative '../../lib/delphy_errors'
require_relative '../../lib/delphy_helper'
require_relative '../../lib/delphy_packet_parser'

# --------------------------------------------
# DELPHY Tool Test Class
# --------------------------------------------
class DelphyToolTest
  include DelphyConstants
  include DelphyHelper

  def initialize
    @tool = DelphyTool.new
    Cosmos::Logger.info('[DELPHY_TOOL_TEST] DELPHY Tool Test Initialized')
  end

  # --------------------------------------------
  # Connection Tests
  # --------------------------------------------
  def test_connection
    begin
      Cosmos::Logger.info('[DELPHY_TOOL_TEST] Testing Connection...')
      @tool.connect
      Cosmos::Logger.info('[DELPHY_TOOL_TEST] Connection Test PASSED')
    rescue DelphyError => e
      Cosmos::Logger.error("[DELPHY_TOOL_TEST] Connection Test FAILED: #{e.message}")
    ensure
      @tool.disconnect
    end
  end

  # --------------------------------------------
  # Command Tests
  # --------------------------------------------
  def test_run_script
    begin
      Cosmos::Logger.info('[DELPHY_TOOL_TEST] Testing RUN_SCRIPT Command...')
      @tool.connect
      @tool.run_script(1, 123.45)
      Cosmos::Logger.info('[DELPHY_TOOL_TEST] RUN_SCRIPT Test PASSED')
    rescue DelphyError => e
      Cosmos::Logger.error("[DELPHY_TOOL_TEST] RUN_SCRIPT Test FAILED: #{e.message}")
    ensure
      @tool.disconnect
    end
  end

  def test_send_message
    begin
      Cosmos::Logger.info('[DELPHY_TOOL_TEST] Testing SEND_MESSAGE Command...')
      @tool.connect
      @tool.send_message(0, 'Test Message from Tool Test')
      Cosmos::Logger.info('[DELPHY_TOOL_TEST] SEND_MESSAGE Test PASSED')
    rescue DelphyError => e
      Cosmos::Logger.error("[DELPHY_TOOL_TEST] SEND_MESSAGE Test FAILED: #{e.message}")
    ensure
      @tool.disconnect
    end
  end

  def test_reset_system
    begin
      Cosmos::Logger.info('[DELPHY_TOOL_TEST] Testing RESET_SYSTEM Command...')
      @tool.connect
      @tool.reset_system(0, 'Routine system reset')
      Cosmos::Logger.info('[DELPHY_TOOL_TEST] RESET_SYSTEM Test PASSED')
    rescue DelphyError => e
      Cosmos::Logger.error("[DELPHY_TOOL_TEST] RESET_SYSTEM Test FAILED: #{e.message}")
    ensure
      @tool.disconnect
    end
  end

  # --------------------------------------------
  # Telemetry Tests
  # --------------------------------------------
  def test_telemetry_ack
    begin
      Cosmos::Logger.info('[DELPHY_TOOL_TEST] Testing ACK Telemetry...')
      @tool.connect
      packet = @tool.monitor_telemetry(:ack, ACK_TIMEOUT)
      raise DelphyAcknowledgmentError, 'ACK telemetry validation failed' unless packet[:response_code] == 0
      Cosmos::Logger.info('[DELPHY_TOOL_TEST] ACK Telemetry Test PASSED')
    rescue DelphyError => e
      Cosmos::Logger.error("[DELPHY_TOOL_TEST] ACK Telemetry Test FAILED: #{e.message}")
    ensure
      @tool.disconnect
    end
  end

  def test_telemetry_complete
    begin
      Cosmos::Logger.info('[DELPHY_TOOL_TEST] Testing COMPLETE Telemetry...')
      @tool.connect
      packet = @tool.monitor_telemetry(:complete, COMPLETE_TIMEOUT)
      raise DelphyAcknowledgmentError, 'COMPLETE telemetry validation failed' unless packet[:status_code] == 0
      Cosmos::Logger.info('[DELPHY_TOOL_TEST] COMPLETE Telemetry Test PASSED')
    rescue DelphyError => e
      Cosmos::Logger.error("[DELPHY_TOOL_TEST] COMPLETE Telemetry Test FAILED: #{e.message}")
    ensure
      @tool.disconnect
    end
  end

  # --------------------------------------------
  # Error Handling Tests
  # --------------------------------------------
  def test_invalid_command
    begin
      Cosmos::Logger.info('[DELPHY_TOOL_TEST] Testing INVALID Command Handling...')
      @tool.connect
      DelphyHelper.send_command(TARGET, 'INVALID_COMMAND')
    rescue DelphyCommandError => e
      Cosmos::Logger.info("[DELPHY_TOOL_TEST] INVALID Command Handling Test PASSED: #{e.message}")
    rescue StandardError => e
      Cosmos::Logger.error("[DELPHY_TOOL_TEST] INVALID Command Handling Test FAILED: #{e.message}")
    ensure
      @tool.disconnect
    end
  end

  # --------------------------------------------
  # Workflow Test
  # --------------------------------------------
  def test_full_workflow
    begin
      Cosmos::Logger.info('[DELPHY_TOOL_TEST] Testing Full Workflow...')
      @tool.execute_full_workflow(1, 456.78)
      Cosmos::Logger.info('[DELPHY_TOOL_TEST] Full Workflow Test PASSED')
    rescue DelphyError => e
      Cosmos::Logger.error("[DELPHY_TOOL_TEST] Full Workflow Test FAILED: #{e.message}")
    ensure
      @tool.disconnect
    end
  end

  # --------------------------------------------
  # Run All Tests
  # --------------------------------------------
  def run_all_tests
    Cosmos::Logger.info('[DELPHY_TOOL_TEST] Starting DELPHY Tool Test Suite...')
    test_connection
    test_run_script
    test_send_message
    test_reset_system
    test_telemetry_ack
    test_telemetry_complete
    test_invalid_command
    test_full_workflow
    Cosmos::Logger.info('[DELPHY_TOOL_TEST] DELPHY Tool Test Suite COMPLETED')
  rescue StandardError => e
    Cosmos::Logger.error("[DELPHY_TOOL_TEST] Test Suite FAILED: #{e.message}")
  end
end

# --------------------------------------------
# MAIN EXECUTION BLOCK
# --------------------------------------------
if __FILE__ == $PROGRAM_NAME
  tester = DelphyToolTest.new
  tester.run_all_tests
end
