# config/targets/DELPHY/procedures/delphy_procedure_2.rb
# DELPHY Procedure 2 Script for COSMOS v4 Deployment
# Executes custom workflows: advanced diagnostics, telemetry validation, and error recovery.

require 'cosmos'
require 'cosmos/logging/logger'
require_relative '../../../lib/delphy_tool'
require_relative '../../../lib/delphy_constants'
require_relative '../../../lib/delphy_errors'
require_relative '../../../lib/delphy_helper'
require_relative '../../../lib/delphy_packet_parser'
require_relative '../../../config/tools/delphy_tool_logger'

# --------------------------------------------
# DELPHY Procedure 2 Class
# --------------------------------------------
class DelphyProcedure2
  include DelphyConstants
  include DelphyHelper

  def initialize
    @tool = DelphyTool.new
    @logger = DelphyToolLogger.new
    Cosmos::Logger.info('[DELPHY_PROCEDURE_2] DELPHY Procedure 2 Initialized')
  end

  # --------------------------------------------
  # PROCEDURE TASKS
  # --------------------------------------------

  ## 1. Connection and Initialization
  def initialize_connection
    begin
      @logger.log_info('Initializing connection to DELPHY...')
      @tool.connect
      @logger.log_info('Connection initialization SUCCESSFUL.')
    rescue DelphyConnectionError => e
      @logger.log_error("Connection initialization FAILED: #{e.message}")
      raise
    end
  end

  ## 2. Execute Custom Script
  def execute_custom_script(script_id, parameter)
    begin
      @logger.log_info("Executing custom script ID=#{script_id} with PARAMETER=#{parameter}...")
      @tool.run_script(script_id, parameter)
      @logger.log_info('Custom script executed SUCCESSFULLY.')
    rescue DelphyCommandError => e
      @logger.log_error("Custom script execution FAILED: #{e.message}")
      raise
    end
  end

  ## 3. Validate Telemetry Data
  def validate_telemetry
    begin
      @logger.log_info('Validating telemetry packets (ACK, COMPLETE)...')
      ack_packet = @tool.monitor_telemetry(:ack, ACK_TIMEOUT)
      complete_packet = @tool.monitor_telemetry(:complete, COMPLETE_TIMEOUT)

      unless ack_packet[:response_code] == 0
        raise DelphyAcknowledgmentError, 'ACK telemetry response is invalid.'
      end

      unless complete_packet[:status_code] == 0
        raise DelphyAcknowledgmentError, 'COMPLETE telemetry response is invalid.'
      end

      @logger.log_info('Telemetry validation PASSED.')
    rescue DelphyTelemetryTimeoutError => e
      @logger.log_error("Telemetry validation FAILED: #{e.message}")
      raise
    end
  end

  ## 4. Advanced Diagnostics
  def perform_advanced_diagnostics
    begin
      @logger.log_info('Performing advanced diagnostics on DELPHY...')
      @tool.perform_diagnostics
      @logger.log_info('Advanced diagnostics completed SUCCESSFULLY.')
    rescue DelphyError => e
      @logger.log_error("Advanced diagnostics FAILED: #{e.message}")
      raise
    end
  end

  ## 5. Error Recovery Test
  def test_error_recovery
    begin
      @logger.log_info('Testing error recovery mechanism...')
      DelphyHelper.send_command(TARGET, 'INVALID_COMMAND')
    rescue DelphyCommandError => e
      @logger.log_info("Error recovery PASSED: #{e.message}")
    rescue StandardError => e
      @logger.log_error("Error recovery FAILED: #{e.message}")
      raise
    end
  end

  ## 6. System State Verification
  def verify_system_state
    begin
      @logger.log_info('Verifying DELPHY system state...')
      @tool.connect
      system_state = @tool.monitor_telemetry(:metadata, TELEMETRY_TIMEOUT)
      parsed_state = @tool.parse_telemetry(system_state)

      @logger.log_info("System State: #{parsed_state.inspect}")
      @logger.log_info('System state verification PASSED.')
    rescue DelphyError => e
      @logger.log_error("System state verification FAILED: #{e.message}")
      raise
    ensure
      @tool.disconnect
    end
  end

  ## 7. Graceful System Reset
  def graceful_reset
    begin
      @logger.log_info('Performing a graceful system reset...')
      @tool.reset_system(0, 'Graceful reset after Procedure 2')
      @logger.log_info('System reset completed SUCCESSFULLY.')
    rescue DelphyCommandError => e
      @logger.log_error("System reset FAILED: #{e.message}")
      raise
    end
  end

  # --------------------------------------------
  # WORKFLOW EXECUTION
  # --------------------------------------------
  def run_procedure
    @logger.log_info('Starting DELPHY Procedure 2...')
    begin
      initialize_connection
      execute_custom_script(2, 456.78)
      validate_telemetry
      perform_advanced_diagnostics
      test_error_recovery
      verify_system_state
      graceful_reset
      @logger.log_info('DELPHY Procedure 2 COMPLETED SUCCESSFULLY.')
    rescue DelphyError => e
      @logger.log_error("Procedure 2 FAILED: #{e.message}")
    ensure
      @tool.disconnect
      @logger.close_logger
    end
  end

  # --------------------------------------------
  # INTERACTIVE SESSION
  # --------------------------------------------
  def interactive_session
    puts '--- DELPHY Procedure 2 Interactive Session ---'
    puts 'Available Commands:'
    puts '1. initialize_connection'
    puts '2. execute_custom_script [script_id] [parameter]'
    puts '3. validate_telemetry'
    puts '4. perform_advanced_diagnostics'
    puts '5. test_error_recovery'
    puts '6. verify_system_state'
    puts '7. graceful_reset'
    puts '8. run_procedure'
    puts '9. exit'

    loop do
      print '> '
      input = gets.chomp.split
      command = input.shift

      case command
      when 'initialize_connection'
        initialize_connection
      when 'execute_custom_script'
        execute_custom_script(input[0].to_i, input[1].to_f)
      when 'validate_telemetry'
        validate_telemetry
      when 'perform_advanced_diagnostics'
        perform_advanced_diagnostics
      when 'test_error_recovery'
        test_error_recovery
      when 'verify_system_state'
        verify_system_state
      when 'graceful_reset'
        graceful_reset
      when 'run_procedure'
        run_procedure
      when 'exit'
        puts 'Exiting Procedure 2 Interactive Session...'
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
  procedure = DelphyProcedure2.new

  if ARGV.empty?
    procedure.interactive_session
  else
    case ARGV[0]
    when 'run'
      procedure.run_procedure
    else
      puts 'Usage:'
      puts '  ruby config/targets/DELPHY/procedures/delphy_procedure_2.rb run'
    end
  end
end
