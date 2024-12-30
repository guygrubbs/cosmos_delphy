# config/tools/delphy_script.rb
# DELPHY Standalone Script for COSMOS v4 Deployment
# Provides command-line execution workflows for DELPHY operations

require 'cosmos'
require 'cosmos/logging/logger'
require_relative '../../lib/delphy_tool'
require_relative '../../lib/delphy_constants'
require_relative '../../lib/delphy_errors'
require_relative '../../lib/delphy_helper'
require_relative '../../config/tools/delphy_tool_logger'

# --------------------------------------------
# DELPHY Script Class
# --------------------------------------------
class DelphyScript
  include DelphyConstants
  include DelphyHelper

  def initialize
    @tool = DelphyTool.new
    @logger = DelphyToolLogger.new
    Cosmos::Logger.info('[DELPHY_SCRIPT] DELPHY Script Initialized')
  end

  # --------------------------------------------
  # MAIN PROCEDURES
  # --------------------------------------------

  # Connect to DELPHY
  def connect
    begin
      @logger.info('Attempting to connect to DELPHY...')
      @tool.connect
      @logger.info('Connected to DELPHY successfully.')
    rescue DelphyError => e
      @logger.error("Connection failed: #{e.message}")
      raise
    end
  end

  # Disconnect from DELPHY
  def disconnect
    begin
      @logger.info('Attempting to disconnect from DELPHY...')
      @tool.disconnect
      @logger.info('Disconnected from DELPHY successfully.')
    rescue DelphyError => e
      @logger.error("Disconnection failed: #{e.message}")
    end
  end

  # Run a DELPHY Script
  def run_script(script_id, parameter)
    begin
      @logger.info("Running script with ID=#{script_id} and PARAMETER=#{parameter}...")
      @tool.run_script(script_id, parameter)
      @logger.info('Script executed successfully.')
    rescue DelphyError => e
      @logger.error("Script execution failed: #{e.message}")
      raise
    end
  end

  # Send a Message
  def send_message(log_level, message)
    begin
      @logger.info("Sending message with LOG_LEVEL=#{log_level}: #{message}")
      @tool.send_message(log_level, message)
      @logger.info('Message sent successfully.')
    rescue DelphyError => e
      @logger.error("Message failed: #{e.message}")
      raise
    end
  end

  # Reset System
  def reset_system(reset_mode, reset_reason)
    begin
      @logger.info("Resetting system with MODE=#{RESET_MODES[reset_mode]} and REASON=#{reset_reason}")
      @tool.reset_system(reset_mode, reset_reason)
      @logger.info('System reset successfully.')
    rescue DelphyError => e
      @logger.error("System reset failed: #{e.message}")
      raise
    end
  end

  # Monitor Telemetry
  def monitor_telemetry(packet_type, timeout = TELEMETRY_TIMEOUT)
    begin
      @logger.info("Monitoring telemetry for TYPE=#{packet_type} with TIMEOUT=#{timeout}")
      packet = @tool.monitor_telemetry(packet_type, timeout)
      @logger.info("Telemetry received: #{packet.inspect}")
      return packet
    rescue DelphyError => e
      @logger.error("Telemetry monitoring failed: #{e.message}")
      raise
    end
  end

  # Execute Full Workflow
  def execute_full_workflow(script_id, parameter)
    begin
      @logger.info('Starting full DELPHY workflow...')
      connect
      run_script(script_id, parameter)
      monitor_telemetry(:complete, COMPLETE_TIMEOUT)
      reset_system(0, 'End of Workflow')
      @logger.info('Workflow completed successfully.')
    rescue DelphyError => e
      @logger.error("Workflow failed: #{e.message}")
    ensure
      disconnect
    end
  end

  # Perform Diagnostics
  def perform_diagnostics
    begin
      @logger.info('Performing diagnostics on DELPHY...')
      @tool.perform_diagnostics
      @logger.info('Diagnostics completed successfully.')
    rescue DelphyError => e
      @logger.error("Diagnostics failed: #{e.message}")
    end
  end

  # --------------------------------------------
  # COMMAND-LINE INTERFACE
  # --------------------------------------------
  def start_interactive_session
    puts '--- DELPHY Interactive Session ---'
    puts 'Available Commands:'
    puts '1. connect'
    puts '2. disconnect'
    puts '3. run_script [script_id] [parameter]'
    puts '4. send_message [log_level] [message]'
    puts '5. reset_system [reset_mode] [reason]'
    puts '6. monitor_telemetry [packet_type]'
    puts '7. execute_workflow [script_id] [parameter]'
    puts '8. diagnostics'
    puts '9. exit'

    loop do
      print '> '
      input = gets.chomp.split
      command = input.shift

      case command
      when 'connect'
        connect
      when 'disconnect'
        disconnect
      when 'run_script'
        run_script(input[0].to_i, input[1].to_f)
      when 'send_message'
        send_message(input[0].to_i, input[1..].join(' '))
      when 'reset_system'
        reset_system(input[0].to_i, input[1..].join(' '))
      when 'monitor_telemetry'
        monitor_telemetry(input[0].to_sym)
      when 'execute_workflow'
        execute_full_workflow(input[0].to_i, input[1].to_f)
      when 'diagnostics'
        perform_diagnostics
      when 'exit'
        disconnect
        puts 'Exiting...'
        break
      else
        puts 'Unknown command. Please try again.'
      end
    end
  rescue Interrupt
    puts "\nExiting session..."
    disconnect
  rescue StandardError => e
    @logger.error("Error in interactive session: #{e.message}")
    puts "Error: #{e.message}"
  ensure
    @logger.close_logger
  end
end

# --------------------------------------------
# MAIN SCRIPT EXECUTION
# --------------------------------------------
if __FILE__ == $PROGRAM_NAME
  script = DelphyScript.new
  if ARGV.empty?
    script.start_interactive_session
  else
    case ARGV[0]
    when 'workflow'
      script.execute_full_workflow(ARGV[1].to_i, ARGV[2].to_f)
    when 'diagnostics'
      script.perform_diagnostics
    else
      puts 'Usage:'
      puts '  ruby config/tools/delphy_script.rb workflow [script_id] [parameter]'
      puts '  ruby config/tools/delphy_script.rb diagnostics'
    end
  end
end
