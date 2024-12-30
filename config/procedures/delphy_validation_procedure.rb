# config/procedures/delphy_validation_procedure.rb
# DELPHY Validation Procedure Script for COSMOS v4 Deployment
# Ensures interface integrity, command validation, telemetry checks, and error handling.

require 'cosmos'
require 'cosmos/logging/logger'
require_relative '../../lib/delphy_tool'
require_relative '../../lib/delphy_constants'
require_relative '../../lib/delphy_errors'
require_relative '../../lib/delphy_helper'
require_relative '../../config/tools/delphy_tool_logger'

# --------------------------------------------
# DELPHY Validation Procedure Class
# --------------------------------------------
class DelphyValidationProcedure
  include DelphyConstants
  include DelphyHelper

  def initialize
    @tool = DelphyTool.new
    @logger = DelphyToolLogger.new
    Cosmos::Logger.info('[DELPHY_VALIDATION] DELPHY Validation Procedure Initialized')
  end

  # --------------------------------------------
  # VALIDATION TASKS
  # --------------------------------------------

  # 1. Validate Connection
  def validate_connection
    begin
      @logger.info('Validating DELPHY connection...')
      @tool.connect
      @logger.info('Connection validation PASSED.')
    rescue DelphyError => e
      @logger.error("Connection validation FAILED: #{e.message}")
      raise
    ensure
      @tool.disconnect
    end
  end

  # 2. Validate Command Execution
  def validate_command_execution
    begin
      @logger.info('Validating RUN_SCRIPT command...')
      @tool.connect
      @tool.run_script(1, 123.45)
      @logger.info('RUN_SCRIPT command validation PASSED.')

      @logger.info('Validating SEND_MESSAGE command...')
      @tool.send_message(0, 'Validation message from DELPHY_VALIDATION')
      @logger.info('SEND_MESSAGE command validation PASSED.')
    rescue DelphyError => e
      @logger.error("Command validation FAILED: #{e.message}")
      raise
    ensure
      @tool.disconnect
    end
  end

  # 3. Validate Telemetry
  def validate_telemetry
    begin
      @logger.info('Validating telemetry reception...')
      @tool.connect
      ack_packet = @tool.monitor_telemetry(:ack, ACK_TIMEOUT)
      complete_packet = @tool.monitor_telemetry(:complete, COMPLETE_TIMEOUT)

      if ack_packet[:response_code] != 0
        raise DelphyAcknowledgmentError, 'Invalid ACK telemetry response.'
      end

      if complete_packet[:status_code] != 0
        raise DelphyAcknowledgmentError, 'Invalid COMPLETE telemetry response.'
      end

      @logger.info('Telemetry validation PASSED.')
    rescue DelphyError => e
      @logger.error("Telemetry validation FAILED: #{e.message}")
      raise
    ensure
      @tool.disconnect
    end
  end

  # 4. Validate Error Handling
  def validate_error_handling
    begin
      @logger.info('Validating invalid command handling...')
      @tool.connect
      DelphyHelper.send_command(TARGET, 'INVALID_COMMAND')
    rescue DelphyCommandError => e
      @logger.info("Invalid command handling validation PASSED: #{e.message}")
    rescue StandardError => e
      @logger.error("Invalid command handling validation FAILED: #{e.message}")
      raise
    ensure
      @tool.disconnect
    end
  end

  # 5. Validate System Reset
  def validate_system_reset
    begin
      @logger.info('Validating system reset command...')
      @tool.connect
      @tool.reset_system(0, 'Validation Reset')
      @logger.info('System reset validation PASSED.')
    rescue DelphyError => e
      @logger.error("System reset validation FAILED: #{e.message}")
      raise
    ensure
      @tool.disconnect
    end
  end

  # 6. Validate Diagnostics
  def validate_diagnostics
    begin
      @logger.info('Validating diagnostics command...')
      @tool.connect
      @tool.perform_diagnostics
      @logger.info('Diagnostics validation PASSED.')
    rescue DelphyError => e
      @logger.error("Diagnostics validation FAILED: #{e.message}")
      raise
    ensure
      @tool.disconnect
    end
  end

  # 7. Validate Configuration
  def validate_configuration
    begin
      @logger.info('Validating DELPHY system configuration parameters...')
      @tool.connect
      DelphyHelper.validate_parameter(50.0, 0.0, 100.0)
      @logger.info('System configuration validation PASSED.')
    rescue DelphyError => e
      @logger.error("Configuration validation FAILED: #{e.message}")
      raise
    ensure
      @tool.disconnect
    end
  end

  # --------------------------------------------
  # VALIDATION WORKFLOW
  # --------------------------------------------
  def perform_validation
    @logger.info('Starting DELPHY Validation Procedure...')
    begin
      validate_connection
      validate_command_execution
      validate_telemetry
      validate_error_handling
      validate_system_reset
      validate_diagnostics
      validate_configuration
      @logger.info('DELPHY Validation Procedure COMPLETED successfully.')
    rescue DelphyError => e
      @logger.error("Validation Procedure FAILED: #{e.message}")
    ensure
      @tool.disconnect
      @logger.close_logger
    end
  end

  # --------------------------------------------
  # INTERACTIVE SESSION
  # --------------------------------------------
  def interactive_session
    puts '--- DELPHY Validation Interactive Session ---'
    puts 'Available Validation Tasks:'
    puts '1. validate_connection'
    puts '2. validate_command_execution'
    puts '3. validate_telemetry'
    puts '4. validate_error_handling'
    puts '5. validate_system_reset'
    puts '6. validate_diagnostics'
    puts '7. validate_configuration'
    puts '8. perform_validation'
    puts '9. exit'

    loop do
      print '> '
      input = gets.chomp

      case input
      when 'validate_connection'
        validate_connection
      when 'validate_command_execution'
        validate_command_execution
      when 'validate_telemetry'
        validate_telemetry
      when 'validate_error_handling'
        validate_error_handling
      when 'validate_system_reset'
        validate_system_reset
      when 'validate_diagnostics'
        validate_diagnostics
      when 'validate_configuration'
        validate_configuration
      when 'perform_validation'
        perform_validation
      when 'exit'
        puts 'Exiting validation session...'
        break
      else
        puts 'Unknown command. Please try again.'
      end
    end
  rescue Interrupt
    puts "\nExiting session..."
    @tool.disconnect
  rescue StandardError => e
    @logger.error("Interactive session encountered an error: #{e.message}")
    puts "Error: #{e.message}"
  ensure
    @logger.close_logger
  end
end

# --------------------------------------------
# MAIN PROCEDURE EXECUTION
# --------------------------------------------
if __FILE__ == $PROGRAM_NAME
  validator = DelphyValidationProcedure.new

  if ARGV.empty?
    validator.interactive_session
  else
    case ARGV[0]
    when 'validate'
      validator.perform_validation
    else
      puts 'Usage:'
      puts '  ruby config/procedures/delphy_validation_procedure.rb validate'
    end
  end
end
