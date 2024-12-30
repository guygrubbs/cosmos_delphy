# config/tools/delphy_tool_logger.rb
# DELPHY Tool Logger for COSMOS v4 Deployment
# Provides centralized logging functionality for DELPHY operations

require 'cosmos'
require 'cosmos/logging/logger'
require 'fileutils'
require_relative '../../lib/delphy_constants'
require_relative '../../lib/delphy_errors'

# --------------------------------------------
# DELPHY Tool Logger Class
# --------------------------------------------
class DelphyToolLogger
  include DelphyConstants

  LOG_DIRECTORY = 'config/targets/DELPHY/tools/logs'.freeze
  LOG_FILE = "#{LOG_DIRECTORY}/delphy_tool.log".freeze

  def initialize
    setup_log_directory
    setup_logger
    Cosmos::Logger.info('[DELPHY_LOGGER] DELPHY Tool Logger Initialized')
  end

  # --------------------------------------------
  # LOGGING SETUP
  # --------------------------------------------
  def setup_log_directory
    unless Dir.exist?(LOG_DIRECTORY)
      FileUtils.mkdir_p(LOG_DIRECTORY)
      puts "[DELPHY_LOGGER] Created log directory at #{LOG_DIRECTORY}"
    end
  end

  def setup_logger
    @logger = Cosmos::Logger.new
    @logger.add_file_logger(LOG_FILE)
    @logger.level = Cosmos::Logger::INFO
    Cosmos::Logger.info("[DELPHY_LOGGER] Logging to file: #{LOG_FILE}")
  rescue StandardError => e
    puts "[DELPHY_LOGGER] Failed to set up logger: #{e.message}"
    raise DelphyConfigurationError, 'Logger initialization failed.'
  end

  # --------------------------------------------
  # LOGGING METHODS
  # --------------------------------------------

  # Log informational messages
  def log_info(message)
    @logger.info("[DELPHY_LOGGER] INFO: #{message}")
  rescue StandardError => e
    puts "[DELPHY_LOGGER] Failed to log INFO: #{e.message}"
  end

  # Log warning messages
  def log_warning(message)
    @logger.warn("[DELPHY_LOGGER] WARNING: #{message}")
  rescue StandardError => e
    puts "[DELPHY_LOGGER] Failed to log WARNING: #{e.message}"
  end

  # Log error messages
  def log_error(message)
    @logger.error("[DELPHY_LOGGER] ERROR: #{message}")
  rescue StandardError => e
    puts "[DELPHY_LOGGER] Failed to log ERROR: #{e.message}"
  end

  # Log debug messages
  def log_debug(message)
    @logger.debug("[DELPHY_LOGGER] DEBUG: #{message}")
  rescue StandardError => e
    puts "[DELPHY_LOGGER] Failed to log DEBUG: #{e.message}"
  end

  # Log critical/fatal errors
  def log_critical(message)
    @logger.fatal("[DELPHY_LOGGER] CRITICAL: #{message}")
  rescue StandardError => e
    puts "[DELPHY_LOGGER] Failed to log CRITICAL: #{e.message}"
  end

  # --------------------------------------------
  # SPECIALIZED LOGGING METHODS
  # --------------------------------------------

  # Log a connection event
  def log_connection_event(event, status)
    message = "Connection Event: #{event}, Status: #{status}"
    @logger.info("[DELPHY_LOGGER] #{message}")
  rescue StandardError => e
    puts "[DELPHY_LOGGER] Failed to log Connection Event: #{e.message}"
  end

  # Log a command event
  def log_command_event(command, parameters = {})
    message = "Command Sent: #{command}, Parameters: #{parameters.inspect}"
    @logger.info("[DELPHY_LOGGER] #{message}")
  rescue StandardError => e
    puts "[DELPHY_LOGGER] Failed to log Command Event: #{e.message}"
  end

  # Log a telemetry event
  def log_telemetry_event(packet_type, packet_data)
    message = "Telemetry Received: Type=#{packet_type}, Data=#{packet_data.inspect}"
    @logger.info("[DELPHY_LOGGER] #{message}")
  rescue StandardError => e
    puts "[DELPHY_LOGGER] Failed to log Telemetry Event: #{e.message}"
  end

  # Log an error event
  def log_error_event(error)
    message = "Error Occurred: #{error.class.name}, Message: #{error.message}"
    @logger.error("[DELPHY_LOGGER] #{message}")
  rescue StandardError => e
    puts "[DELPHY_LOGGER] Failed to log Error Event: #{e.message}"
  end

  # --------------------------------------------
  # LOGGING CLEANUP
  # --------------------------------------------
  def close_logger
    @logger.close
    Cosmos::Logger.info('[DELPHY_LOGGER] Logger closed successfully')
  rescue StandardError => e
    puts "[DELPHY_LOGGER] Failed to close logger: #{e.message}"
  end
end

# --------------------------------------------
# TEST CASES (Run Directly)
# --------------------------------------------
if __FILE__ == $PROGRAM_NAME
  begin
    logger = DelphyToolLogger.new

    # Test general logging
    logger.info('This is an informational message')
    logger.warning('This is a warning message')
    logger.error('This is an error message')
    logger.debug('This is a debug
