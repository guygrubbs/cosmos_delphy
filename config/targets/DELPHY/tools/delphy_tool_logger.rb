#!/usr/bin/env ruby
# config/targets/DELPHY/tools/delphy_tool_logger.rb
# DELPHY Tool Logger for COSMOS v4 Deployment
# Provides centralized logging functionality for DELPHY operations

require 'cosmos'
require 'cosmos/logging/logger'
require 'fileutils'
require_relative '../../lib/delphy_constants'
require_relative '../../lib/delphy_errors'
require_relative '../../lib/delphy_logger'

# --------------------------------------------
# DELPHY Tool Logger Class
# --------------------------------------------
class DelphyToolLogger
  include DelphyConstants

  LOG_DIRECTORY = 'config/targets/DELPHY/tools/logs'.freeze
  LOG_FILE = "#{LOG_DIRECTORY}/delphy_tool.log".freeze

  def initialize
    @logger = DelphyToolLogger.new('config/targets/DELPHY/tools/logs/delphy_tool_logger.log', 'WARN')
    @logger.info('DELPHY_LOGGER initialized')
  end

  def log_test_message
    @logger.debug('This is a debug message.')
    @logger.info('This is an info message.')
    @logger.warn('This is a warning message.')
    @logger.error('This is an error message.')
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
    @logger.add_file_logger(@log_file_path)
    @logger.level = case @log_level.upcase
                    when 'DEBUG' then Cosmos::Logger::DEBUG
                    when 'INFO' then Cosmos::Logger::INFO
                    when 'WARN' then Cosmos::Logger::WARN
                    when 'ERROR' then Cosmos::Logger::ERROR
                    when 'FATAL' then Cosmos::Logger::FATAL
                    else Cosmos::Logger::INFO
                    end
    Cosmos::Logger.info("[DELPHY_LOGGER] Logging to file: #{@log_file_path}")
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
  def log_error(message, exception = nil)
    formatted_message = "[ERROR] #{message}"
    formatted_message += "\nTraceback: #{exception.full_message}" if exception
    begin
      @logger.error(formatted_message)
    rescue StandardError => e
      puts "Failed to write error log: #{e.message}"
      puts e.full_message
    end
  end

  # Log debug messages
  def log_debug(message)
    @logger.debug("[DELPHY_LOGGER] DEBUG: #{message}")
  rescue StandardError => e
    puts "[DELPHY_LOGGER] Failed to log DEBUG: #{e.message}"
  end

  # Log critical/fatal errors
  def log_critical(message, exception = nil)
    formatted_message = "[DELPHY_LOGGER] CRITICAL: #{message}"
    formatted_message += "\nTraceback: #{exception.full_message}" if exception
    @logger.fatal(formatted_message)
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
    logger.debug('This is a debug message')
    logger.critical('This is a critical error')

    # Test specialized logging
    logger.connection_event('Test Connection', 'Success')
    logger.command_event('RUN_TEST', { param1: 123, param2: 'abc' })
    logger.telemetry_event('HEALTH_PACKET', { status: 'OK', voltage: 3.3 })

    logger.close_logger
  rescue StandardError => e
    puts "Logger test failed: #{e.message}"
  end
end
