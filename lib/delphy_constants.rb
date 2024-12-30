# lib/delphy_constants.rb
# Centralized Constants for DELPHY Interface in COSMOS v4
# Ensures consistency across DELPHY tools and scripts

require 'cosmos'
require 'cosmos/logging/logger'

# -------------------------------
# PACKET DEFINITIONS
# -------------------------------

module DelphyConstants
  # Packet Sync Code
  PACKET_SYNC = 0xDEADBEEF

  # Packet Types
  PACKET_TYPES = {
    0 => 'ACK',
    4 => 'MESSAGE',
    6 => 'SCRIPT',
    8 => 'CONTROL',
    10 => 'IDENTITY',
    12 => 'COMPLETE'
  }.freeze

  # Packet Sizes (Header + Minimum Data Size)
  HEADER_FORMAT = 'L>L>L>F>F>L>'
  HEADER_SIZE = 28 # Sync (4) + Type (4) + ID (4) + Session Time (8) + Packet Time (8) + Length (4)

  # Packet Response Codes
  RESPONSE_CODES = {
    0 => 'SUCCESS',
    1 => 'ABORTED',
    2 => 'EXCEPTION',
    3 => 'INVALID_COMMAND',
    4 => 'TIMEOUT',
    5 => 'UNKNOWN_ERROR'
  }.freeze

  # Default Port and IP for DELPHY Interface
  DEFAULT_IP = '129.162.153.79'
  DEFAULT_PORT = 14670

  # Default Timeouts (in seconds)
  CONNECTION_TIMEOUT = 10
  ACK_TIMEOUT = 10
  COMPLETE_TIMEOUT = 20
  TELEMETRY_TIMEOUT = 5

  # Log Levels
  LOG_LEVELS = {
    0 => 'OUTPUT',
    1 => 'WARNING',
    2 => 'ERROR',
    3 => 'DEBUG',
    4 => 'JOURNAL'
  }.freeze

  # Hardware Modes
  HARDWARE_MODES = {
    0 => 'SAFE',
    1 => 'SIMULATION',
    2 => 'OPERATIONAL'
  }.freeze

  # Reset Modes
  RESET_MODES = {
    0 => 'SOFT_RESET',
    1 => 'HARD_RESET'
  }.freeze

  # Control Codes
  CONTROL_CODES = {
    0 => 'REQUEST_CONTROL',
    1 => 'RELEASE_CONTROL',
    2 => 'FORCE_CONTROL'
  }.freeze

  # Event Interrupt Flags
  EVENT_INTERRUPT = {
    0 => 'NON_INTERRUPT',
    1 => 'INTERRUPT'
  }.freeze

  # Maximum Allowed Packet Sizes
  MAX_PACKET_SIZE = 4096
  MAX_MESSAGE_LENGTH = 128
  MAX_PROPERTY_NAME_LENGTH = 64
  MAX_METADATA_FIELDS = 10

  # Default Values
  DEFAULT_SCRIPT_ID = 1
  DEFAULT_PARAMETER = 0.0

  # Error Messages
  ERROR_MESSAGES = {
    connection_failed: 'Failed to connect to DELPHY interface.',
    invalid_packet: 'Received an invalid packet structure.',
    telemetry_timeout: 'Telemetry timeout reached.',
    ack_timeout: 'ACK packet timeout.',
    complete_timeout: 'COMPLETE packet timeout.',
    unknown_response: 'Received an unknown response type.'
  }.freeze

  # -------------------------------
  # COMMAND IDENTIFIERS
  # -------------------------------
  COMMANDS = {
    run_script: 'RUN_SCRIPT',
    send_message: 'SEND_MESSAGE',
    reset_system: 'RESET_SYSTEM',
    control: 'CONTROL',
    capture_data: 'CAPTURE_DATA',
    disconnect: 'DISCONNECT'
  }.freeze

  # -------------------------------
  # TELEMETRY IDENTIFIERS
  # -------------------------------
  TELEMETRY = {
    ack: 'ACK',
    complete: 'COMPLETE',
    message: 'MESSAGE',
    monitor: 'MONITOR',
    metadata: 'METADATA',
    capture: 'CAPTURE',
    identity: 'IDENTITY',
    reset: 'RESET'
  }.freeze

  # -------------------------------
  # VALIDATION METHODS
  # -------------------------------

  # Validate Packet Type
  def self.valid_packet_type?(type)
    PACKET_TYPES.key?(type)
  end

  # Validate Response Code
  def self.valid_response_code?(code)
    RESPONSE_CODES.key?(code)
  end

  # Validate Log Level
  def self.valid_log_level?(level)
    LOG_LEVELS.key?(level)
  end

  # Validate Hardware Mode
  def self.valid_hardware_mode?(mode)
    HARDWARE_MODES.key?(mode)
  end

  # Validate Reset Mode
  def self.valid_reset_mode?(mode)
    RESET_MODES.key?(mode)
  end

  # Log a constant initialization summary
  def self.log_initialization
    Cosmos::Logger.info('[DELPHY_CONSTANTS] DELPHY Constants Initialized:')
    Cosmos::Logger.info("Default IP: #{DEFAULT_IP}")
    Cosmos::Logger.info("Default Port: #{DEFAULT_PORT}")
    Cosmos::Logger.info("ACK Timeout: #{ACK_TIMEOUT}")
    Cosmos::Logger.info("COMPLETE Timeout: #{COMPLETE_TIMEOUT}")
    Cosmos::Logger.info("Max Packet Size: #{MAX_PACKET_SIZE}")
  end
end

# Initialize and Log Constants (if run directly)
if __FILE__ == $PROGRAM_NAME
  include DelphyConstants

  puts '--- DELPHY Constants Test ---'
  puts "Packet Sync Code: #{DelphyConstants::PACKET_SYNC}"
  puts "Packet Types: #{DelphyConstants::PACKET_TYPES}"
  puts "Default IP: #{DelphyConstants::DEFAULT_IP}"
  puts "Default Port: #{DelphyConstants::DEFAULT_PORT}"
  puts "Valid Packet Type (6): #{DelphyConstants.valid_packet_type?(6)}"
  puts "Valid Response Code (0): #{DelphyConstants.valid_response_code?(0)}"
  puts "Valid Log Level (2): #{DelphyConstants.valid_log_level?(2)}"
  puts "Valid Reset Mode (1): #{DelphyConstants.valid_reset_mode?(1)}"

  DelphyConstants.log_initialization
end
