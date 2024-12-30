#!/usr/bin/env ruby
# config/targets/DELPHY/tools/delphy_script.rb
# DELPHY Standalone Script for COSMOS v4 Deployment
# Provides command-line execution workflows for DELPHY operations

require 'cosmos'
require 'cosmos/logging/logger'
require_relative '../../lib/delphy_tool'
require_relative '../../lib/delphy_constants'
require_relative '../../lib/delphy_errors'
require_relative '../../lib/delphy_helper'
require_relative '../../lib/delphy_logger'
require_relative 'delphy_tool_logger'

# --------------------------------------------
# DELPHY Script Class
# --------------------------------------------
class DelphyScript
  def initialize
    @logger = DelphyToolLogger.new('config/targets/DELPHY/tools/logs/delphy_script.log', 'INFO')
    @logger.info('DELPHY_SCRIPT initialized')
  end

  # Connect to DELPHY
  def connect
    @logger.info('Attempting to connect to DELPHY...')
    begin
      @tool.connect
      @logger.info('Connected to DELPHY successfully.')
    rescue DelphyConnectionError => e
      @logger.error("Connection failed: #{e.message}")
      raise
    rescue StandardError => e
      @logger.error("Unexpected error during connection: #{e.message}")
      @logger.error(e.full_message)
      raise
    end
  end

  # Disconnect from DELPHY
  def disconnect
    @logger.info('Attempting to disconnect from DELPHY...')
    @tool.disconnect
    @logger.info('Disconnected from DELPHY successfully.')
  rescue DelphyError => e
    @logger.error("Disconnection failed: #{e.message}")
  end

  # Run a DELPHY Script
  def run_script(script_id, parameter)
    @logger.info("Executing script with ID=#{script_id} and PARAMETER=#{parameter}")
    begin
      raise DelphyCommandError, 'Script ID cannot be nil' if script_id.nil?
      @tool.run_script(script_id, parameter)
      @logger.info('Script executed successfully.')
    rescue DelphyCommandError => e
      @logger.error("Command execution failed: #{e.message}")
      raise
    rescue StandardError => e
      @logger.error("Unexpected error during script execution: #{e.message}")
      @logger.error(e.full_message)
      raise
    end
  end

  # Send a Message
  def send_message(log_level, message)
    @logger.info("Sending message with LOG_LEVEL=#{log_level}: #{message}")
    @tool.send_message(log_level, message)
    @logger.info('Message sent successfully.')
  rescue DelphyError => e
    @logger.error("Message failed: #{e.message}")
    raise
  end

  # Reset System
  def reset_system(reset_mode, reset_reason)
    @logger.info("Resetting system with MODE=#{RESET_MODES[reset_mode]} and REASON=#{reset_reason}")
    @tool.reset_system(reset_mode, reset_reason)
    @logger.info('System reset successfully.')
  rescue DelphyError => e
    @logger.error("System reset failed: #{e.message}")
    raise
  end

  # Monitor Telemetry
  def monitor_telemetry(packet_type, timeout = TELEMETRY_TIMEOUT)
    @logger.info("Monitoring telemetry for TYPE=#{packet_type} with TIMEOUT=#{timeout}")
    packet = @tool.monitor_telemetry(packet_type, timeout)
    @logger.info("Telemetry received: #{packet.inspect}")
    packet
  rescue DelphyError => e
    @logger.error("Telemetry monitoring failed: #{e.message}")
    raise
  end

  # Execute Full Workflow
  def execute_full_workflow(script_id, parameter)
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

  # Perform Diagnostics
  def perform_diagnostics
    @logger.info('Performing diagnostics on DELPHY...')
    @tool.perform_diagnostics
    @logger.info('Diagnostics completed successfully.')
  rescue DelphyError => e
    @logger.error("Diagnostics failed: #{e.message}")
  end

  # Command-Line Interface
  def start_interactive_session
    puts '--- DELPHY Interactive Session ---'
    puts 'Available Commands: connect, disconnect, run_script, reset_system, diagnostics, exit'

    loop do
      print '> '
      input = gets.chomp.split
      command = input.shift

      case command
      when 'connect' then connect
      when 'disconnect' then disconnect
      when 'run_script' then run_script(input[0].to_i, input[1].to_f)
      when 'reset_system' then reset_system(input[0].to_i, input[1..].join(' '))
      when 'diagnostics' then perform_diagnostics
      when 'exit'
        disconnect
        break
      else
        puts 'Unknown command.'
      end
    end
  rescue Interrupt
    disconnect
  ensure
    @logger.info('Interactive session closed.')
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
      puts 'Usage: ruby delphy_script.rb workflow [script_id] [parameter]'
    end
  end
end
