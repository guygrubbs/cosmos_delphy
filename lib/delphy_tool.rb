# lib/delphy_tool.rb
# Main DELPHY Tool Class for COSMOS v4 Deployment
# Manages connections, commands, telemetry, and error handling for DELPHY

require 'cosmos'
require 'cosmos/interfaces/tcpip_interface'
require 'cosmos/script'
require 'cosmos/logging/logger'

require_relative 'delphy_constants'
require_relative 'delphy_errors'
require_relative 'delphy_helper'
require_relative 'delphy_packet_parser'

# Main Class for DELPHY Tool
class DelphyTool
  include DelphyConstants
  include DelphyHelper

  attr_accessor :session_id, :connected

  def initialize
    @session_id = 1
    @connected = false
    @parser = DelphyPacketParser.new
    Cosmos::Logger.info('[DELPHY_TOOL] DELPHY Tool Initialized')
  end

  # --------------------------------------------
  # CONNECTION MANAGEMENT
  # --------------------------------------------

  # Connect to DELPHY interface
  def connect
    DelphyHelper.connect_to_delphy(TARGET, INTERFACE)
    DelphyHelper.verify_connection(TARGET, INTERFACE)
    @connected = true
    Cosmos::Logger.info("[DELPHY_TOOL] Connected to DELPHY at #{DEFAULT_IP}:#{DEFAULT_PORT}")
  rescue DelphyError => e
    DelphyErrorHandler.handle_error(e)
  end

  # Disconnect from DELPHY interface
  def disconnect
    DelphyHelper.disconnect_from_delphy(TARGET, INTERFACE)
    @connected = false
    Cosmos::Logger.info('[DELPHY_TOOL] Disconnected from DELPHY')
  rescue DelphyError => e
    DelphyErrorHandler.handle_error(e)
  end

  # --------------------------------------------
  # COMMAND MANAGEMENT
  # --------------------------------------------

  # Run a script on DELPHY
  def run_script(script_id, parameter)
    raise DelphyConnectionError, 'Not connected to DELPHY' unless @connected

    DelphyHelper.send_command(TARGET, COMMANDS[:run_script], SCRIPT_ID: script_id, PARAMETER: parameter)
    packet = DelphyHelper.monitor_telemetry(TARGET, TELEMETRY[:ack], ACK_TIMEOUT)
    DelphyHelper.validate_command_response(packet)
    Cosmos::Logger.info("[DELPHY_TOOL] Script (ID=#{script_id}) executed with PARAMETER=#{parameter}")
  rescue DelphyError => e
    DelphyErrorHandler.handle_error(e)
  end

  # Send a generic message to DELPHY
  def send_message(log_level, message)
    raise DelphyConnectionError, 'Not connected to DELPHY' unless @connected

    DelphyHelper.send_command(TARGET, COMMANDS[:send_message], LOG_LEVEL: log_level, MESSAGE: message)
    Cosmos::Logger.info("[DELPHY_TOOL] Sent message: #{message} with level: #{log_level}")
  rescue DelphyError => e
    DelphyErrorHandler.handle_error(e)
  end

  # Reset DELPHY system
  def reset_system(reset_mode, reset_reason)
    raise DelphyConnectionError, 'Not connected to DELPHY' unless @connected

    DelphyHelper.send_command(TARGET, COMMANDS[:reset_system], RESET_MODE: reset_mode, RESET_REASON: reset_reason)
    packet = DelphyHelper.monitor_telemetry(TARGET, TELEMETRY[:reset], COMPLETE_TIMEOUT)
    Cosmos::Logger.info("[DELPHY_TOOL] System reset executed. Mode=#{RESET_MODES[reset_mode]}, Reason=#{reset_reason}")
  rescue DelphyError => e
    DelphyErrorHandler.handle_error(e)
  end

  # --------------------------------------------
  # TELEMETRY MANAGEMENT
  # --------------------------------------------

  # Monitor and log a specific telemetry packet
  def monitor_telemetry(telemetry_type, timeout = TELEMETRY_TIMEOUT)
    raise DelphyConnectionError, 'Not connected to DELPHY' unless @connected

    packet = DelphyHelper.monitor_telemetry(TARGET, TELEMETRY[telemetry_type], timeout)
    Cosmos::Logger.info("[DELPHY_TOOL] Telemetry Received: #{packet.inspect}")
    packet
  rescue DelphyError => e
    DelphyErrorHandler.handle_error(e)
  end

  # Parse raw telemetry packet
  def parse_telemetry(packet)
    parsed_data = @parser.parse_generic_packet(packet)
    Cosmos::Logger.info("[DELPHY_TOOL] Parsed Telemetry: #{parsed_data.inspect}")
    parsed_data
  rescue DelphyError => e
    DelphyErrorHandler.handle_error(e)
  end

  # --------------------------------------------
  # WORKFLOWS
  # --------------------------------------------

  # Full workflow example
  def execute_full_workflow(script_id, parameter)
    connect
    run_script(script_id, parameter)
    packet = monitor_telemetry(:complete, COMPLETE_TIMEOUT)
    parsed_packet = parse_telemetry(packet)
    Cosmos::Logger.info("[DELPHY_TOOL] Workflow complete: #{parsed_packet.inspect}")
  rescue DelphyError => e
    DelphyErrorHandler.handle_error(e)
  ensure
    disconnect
  end

  # Perform system diagnostics
  def perform_diagnostics
    raise DelphyConnectionError, 'Not connected to DELPHY' unless @connected

    DelphyHelper.log_diagnostics(TARGET)
    Cosmos::Logger.info('[DELPHY_TOOL] Diagnostics executed successfully')
  rescue DelphyError => e
    DelphyErrorHandler.handle_error(e)
  end
end

# --------------------------------------------
# MAIN EXECUTION FOR TESTING
# --------------------------------------------

if __FILE__ == $PROGRAM_NAME
  tool = DelphyTool.new
  begin
    tool.connect
    tool.run_script(1, 123.45)
    tool.send_message(0, 'Test message from DELPHY_TOOL')
    tool.monitor_telemetry(:ack)
    tool.reset_system(0, 'Routine maintenance')
    tool.perform_diagnostics
    tool.execute_full_workflow(1, 456.78)
  rescue DelphyError => e
    Cosmos::Logger.error("[DELPHY_MAIN] #{e.message}")
  ensure
    tool.disconnect
  end
end
