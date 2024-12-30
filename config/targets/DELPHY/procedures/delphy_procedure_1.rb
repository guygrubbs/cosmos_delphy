# config/targets/DELPHY/procedures/delphy_procedure_1.rb
# DELPHY Procedure 1 Script for COSMOS v4 Deployment
# Executes a predefined workflow: connection, script execution, telemetry monitoring, diagnostics, and reset.

require 'cosmos'
require 'cosmos/logging/logger'
require_relative '../../../lib/delphy_tool'
require_relative '../../../lib/delphy_constants'
require_relative '../../../lib/delphy_errors'
require_relative '../../../lib/delphy_helper'
require_relative '../../../lib/delphy_packet_parser'
require_relative '../../../config/tools/delphy_tool_logger'

# --------------------------------------------
# DELPHY Procedure 1 Class
# --------------------------------------------
class DelphyProcedure1
  include DelphyConstants
  include DelphyHelper

  def initialize
    @tool = DelphyTool.new
    @logger = DelphyToolLogger.new
    Cosmos::Logger.info('[DELPHY_PROCEDURE_1] DELPHY Procedure 1 Initialized')
  end

  # --------------------------------------------
  # PROCEDURE TASKS
  # --------------------------------------------

  ## 1. Establish Connection
  def establish_connection
    begin
      @logger.log_info('Establishing connection to DELPHY...')
      @tool.connect
      @logger.log_info('Connection established successfully.')
    rescue DelphyConnectionError => e
      @logger.log_error("Connection establishment FAILED: #{e.message}")
      raise
    end
  end

  ## 2. Execute Predefined Script
  def execute_script
    begin
      @logger.log_info('Executing predefined script on DELPHY...')
      @tool.run_script(1, 123.45)
      @logger.log_info('Script executed successfully.')
    rescue DelphyCommandError => e
      @logger.log_error("Script execution FAILED: #{e.message}")
      raise
    end
  end

  ## 3. Monitor Telemetry
  def monitor_telemetry
    begin
      @logger.log_info('Monitoring telemetry for ACK and COMPLETE packets...')
      ack_packet = @tool.monitor_telemetry(:ack, ACK_TIMEOUT)
      complete_packet = @tool.monitor_telemetry(:complete, COMPLETE_TIMEOUT)

      if ack_packet[:response_code] != 0
        raise DelphyAcknowledgmentError, 'Invalid ACK telemetry response.'
      end

      if complete_packet[:status_code] != 0
        raise DelphyAcknowledgmentError, 'Invalid COMPLETE telemetry response.'
      end

      @logger.log_info('Telemetry monitoring PASSED.')
    rescue DelphyTelemetryTimeoutError => e
      @logger.log_error("Telemetry monitoring FAILED: #{e.message}")
      raise
    end
  end

  ## 4. Perform Diagnostics
  def perform_diagnostics
    begin
      @logger.log_info('Performing system diagnostics...')
      @tool.perform_diagnostics
      @logger.log_info('Diagnostics completed successfully.')
    rescue DelphyError => e
      @logger.log_error("Diagnostics FAILED: #{e.message}")
      raise
    end
  end

  ## 5. Error Handling Check
  def check_error_handling
    begin
      @logger.log_info('Validating error handling with an invalid command...')
      DelphyHelper.send_command(TARGET, 'INVALID_COMMAND')
    rescue DelphyCommandError => e
      @logger.log_info("Error handling validation PASSED: #{e.message}")
    rescue StandardError => e
      @logger.log_error("Error handling validation FAILED: #{e.message}")
      raise
    end
  end

  ## 6. Reset System
  def reset_system
    begin
      @logger.log_info('Resetting DELPHY system after procedure completion...')
      @tool.reset_system(0, 'Procedure 1 reset')
      @logger.log_info('System reset successfully.')
    rescue DelphyCommandError => e
      @logger.log_error("System reset FAILED: #{e.message}")
      raise
    end
  end

  # --------------------------------------------
  # WORKFLOW EXECUTION
  # --------------------------------------------
  def run_procedure
    @logger.log_info('Starting DELPHY Procedure 1...')
    begin
      establish_connection
      execute_script
      monitor_telemetry
      perform_diagnostics
      check_error_handling
      reset_system
      @logger.log_info('DELPHY Procedure 1 COMPLETED successfully.')
    rescue DelphyError => e
      @logger.log_error("Procedure 1 FAILED: #{e.message}")
    ensure
      @tool.disconnect
      @logger.close_logger
    end
  end

  # --------------------------------------------
  # INTERACTIVE SESSION
  # --------------------------------------------
  def interactive_session
    puts '--- DELPHY Procedure 1 Interactive Session ---'
    puts 'Available Commands:'
    puts '1. establish_connection'
    puts '2. execute_script'
    puts '3. monitor_telemetry'
    puts '4. perform_diagnostics'
    puts '5. check_error_handling'
    puts '6. reset_system'
    puts '7. run_procedure'
    puts '8. exit'

    loop do
      print '> '
      input = gets.chomp

      case input
      when 'establish_connection'
        establish_connection
      when 'execute_script'
        execute_script
      when 'monitor_telemetry'
        monitor_telemetry
      when 'perform_diagnostics'
        perform_diagnostics
      when 'check_error_handling'
        check_error_handling
      when 'reset_system'
        reset_system
      when 'run_procedure'
        run_procedure
      when 'exit'
        puts 'Exiting Procedure 1 Interactive Session...'
        break
      else
        puts 'Unknown command. Please try again.'
      end
    end
  rescue Interrupt
    puts "\nExiting session..."
    @tool.disconnect
  rescue StandardError => e
    @logger.log_error("Interactive session error: #{e.message}")
    puts "Error: #{e.message}"
  ensure
    @logger.close_logger
  end
end

# --------------------------------------------
# MAIN PROCEDURE EXECUTION
# --------------------------------------------
if __FILE__ == $PROGRAM_NAME
  procedure = DelphyProcedure1.new

  if ARGV.empty?
    procedure.interactive_session
  else
    case ARGV[0]
    when 'run'
      procedure.run_procedure
    else
      puts 'Usage:'
      puts '  ruby config/targets/DELPHY/procedures/delphy_procedure_1.rb run'
    end
  end
end
