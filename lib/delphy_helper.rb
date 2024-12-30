# lib/delphy_helper.rb
# Utility and Helper Functions for DELPHY Interface in COSMOS v4
# Provides common reusable methods for DELPHY commands, telemetry, and debugging.

require 'cosmos'
require 'cosmos/logging/logger'
require_relative 'delphy_constants'
require_relative 'delphy_errors'

module DelphyHelper
  include DelphyConstants

  # --------------------------------------------
  # CONNECTION UTILITIES
  # --------------------------------------------

  # Verify if the DELPHY interface is connected
  def self.verify_connection(target, interface)
    status = Cosmos.run_command("#{target} #{interface} STATUS")
    if status == 'CONNECTED'
      Cosmos::Logger.info("[DELPHY_HELPER] Connection verified for #{target}:#{interface}")
      true
    else
      raise DelphyConnectionError, "Unable to verify connection for #{target}:#{interface}"
    end
  rescue StandardError => e
    Cosmos::Logger.error("[DELPHY_HELPER] Connection verification failed: #{e.message}")
    raise
  end

  # Establish a connection to DELPHY
  def self.connect_to_delphy(target, interface)
    begin
      Cosmos.run_command("#{target} #{interface} CONNECT")
      Cosmos::Logger.info("[DELPHY_HELPER] Connected to #{target}:#{interface}")
    rescue StandardError => e
      raise DelphyConnectionError, "Failed to connect to #{target}:#{interface} - #{e.message}"
    end
  end

  # Disconnect from DELPHY
  def self.disconnect_from_delphy(target, interface)
    begin
      Cosmos.run_command("#{target} #{interface} DISCONNECT")
      Cosmos::Logger.info("[DELPHY_HELPER] Disconnected from #{target}:#{interface}")
    rescue StandardError => e
      Cosmos::Logger.error("[DELPHY_HELPER] Disconnection failed: #{e.message}")
    end
  end

  # --------------------------------------------
  # COMMAND UTILITIES
  # --------------------------------------------

  # Send a command to DELPHY
  def self.send_command(target, command, params = {})
    begin
      Cosmos::Logger.info("[DELPHY_HELPER] Sending Command: #{command} with Params: #{params.inspect}")
      cmd_string = "#{target} #{command}"
      params.each do |key, value|
        cmd_string += " #{key.upcase}:#{value}"
      end
      Cosmos.run_command(cmd_string)
    rescue StandardError => e
      raise DelphyCommandError, "Failed to send command #{command}: #{e.message}"
    end
  end

  # Validate command response
  def self.validate_command_response(packet)
    if packet[:type] == 'ACK' && packet[:response_code] == 0
      Cosmos::Logger.info('[DELPHY_HELPER] Command executed successfully.')
      true
    else
      raise DelphyAcknowledgmentError, 'ACK not received or response code invalid.'
    end
  end

  # --------------------------------------------
  # TELEMETRY UTILITIES
  # --------------------------------------------

  # Monitor telemetry for specific packet type
  def self.monitor_telemetry(target, telemetry_packet, timeout)
    start_time = Time.now
    loop do
      break if Time.now - start_time > timeout

      packet = Cosmos::PacketLog.read_packet(target, telemetry_packet)
      unless packet.nil?
        Cosmos::Logger.info("[DELPHY_HELPER] Telemetry Packet Received: #{packet.inspect}")
        return packet
      end

      sleep(0.5)
    end
    raise DelphyTelemetryTimeoutError, "Telemetry packet #{telemetry_packet} not received within timeout."
  end

  # Extract field value from a telemetry packet
  def self.extract_field(packet, field)
    if packet.has_field?(field)
      value = packet.read(field)
      Cosmos::Logger.info("[DELPHY_HELPER] Extracted Field #{field}: #{value}")
      return value
    else
      raise DelphyPacketError, "Field #{field} not found in the telemetry packet."
    end
  end

  # --------------------------------------------
  # LOGGING UTILITIES
  # --------------------------------------------

  # Log a standard message
  def self.log_message(level, message)
    if LOG_LEVELS.key?(level)
      case level
      when 0 then Cosmos::Logger.info("[DELPHY_LOG] #{message}")
      when 1 then Cosmos::Logger.warn("[DELPHY_LOG] #{message}")
      when 2 then Cosmos::Logger.error("[DELPHY_LOG] #{message}")
      when 3 then Cosmos::Logger.debug("[DELPHY_LOG] #{message}")
      when 4 then Cosmos::Logger.info("[DELPHY_LOG_JOURNAL] #{message}")
      end
    else
      raise DelphyCommandError, "Invalid log level: #{level}"
    end
  end

  # Generate and log diagnostics
  def self.log_diagnostics(target)
    begin
      status = Cosmos.run_command("#{target} DIAGNOSTICS")
      Cosmos::Logger.info("[DELPHY_HELPER] Diagnostics: #{status}")
    rescue StandardError => e
      Cosmos::Logger.error("[DELPHY_HELPER] Diagnostics failed: #{e.message}")
    end
  end

  # --------------------------------------------
  # VALIDATION UTILITIES
  # --------------------------------------------

  # Validate parameter range
  def self.validate_parameter(value, min, max)
    if value.between?(min, max)
      Cosmos::Logger.info("[DELPHY_HELPER] Parameter #{value} is within range (#{min} - #{max})")
      true
    else
      raise DelphyConfigurationError, "Parameter #{value} out of range (#{min} - #{max})"
    end
  end

  # Check for valid packet sync code
  def self.validate_packet_sync(sync)
    unless sync == PACKET_SYNC
      raise DelphyPacketError, "Invalid packet sync code: #{sync}"
    end
    Cosmos::Logger.info('[DELPHY_HELPER] Valid packet sync code detected.')
    true
  end
end

# Test Cases (Run Directly)
if __FILE__ == $PROGRAM_NAME
  include DelphyHelper

  begin
    # Test Connection
    DelphyHelper.connect_to_delphy('DELPHY', 'DELPHY_INT')
    DelphyHelper.verify_connection('DELPHY', 'DELPHY_INT')

    # Test Command
    DelphyHelper.send_command('DELPHY', 'RUN_SCRIPT', { SCRIPT_ID: 1, PARAMETER: 123.45 })

    # Test Telemetry
    packet = DelphyHelper.monitor_telemetry('DELPHY', 'ACK', 5)
    DelphyHelper.validate_command_response(packet)

    # Test Logging
    DelphyHelper.log_message(0, 'Test informational log message.')

    # Test Validation
    DelphyHelper.validate_parameter(25.5, 0, 100)
    DelphyHelper.validate_packet_sync(0xDEADBEEF)

    # Test Diagnostics
    DelphyHelper.log_diagnostics('DELPHY')

  rescue DelphyError => e
    Cosmos::Logger.error("[DELPHY_HELPER_TEST] #{e.message}")
  ensure
    DelphyHelper.disconnect_from_delphy('DELPHY', 'DELPHY_INT')
  end
end
