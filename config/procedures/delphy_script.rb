# config/procedures/delphy_script.rb
# DELPHY General Procedure Script for COSMOS v4 Deployment
# Provides command execution, telemetry monitoring, diagnostics, and automated workflows.

require 'cosmos'
require 'cosmos/logging/logger'
require_relative '../../lib/delphy_tool'
require_relative '../../lib/delphy_constants'
require_relative '../../lib/delphy_errors'
require_relative '../../lib/delphy_helper'
require_relative '../../lib/delphy_packet_parser'
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
  # COMMAND EXECUTION
  # --------------------------------------------

  # Run a DELPHY Script
  def run_script(script_id, parameter)
    begin
      @logger.info("Running Script ID=#{script_id} with PARAMETER=#{parameter}...")
      @tool.connect
      @tool.run_script(script_id, parameter)
      @logger.info('Script executed successfully.')
    rescue DelphyError => e
      @logger.error("Script execution failed: #{e.message}")
      raise
    ensure
      @tool.disconnect
    end
  end

  # Send a Message to DELPHY
  def send_message(log_level, message)
    begin
      @logger.info("Sending message at LOG_LEVEL=#{log_level}: #{message}")
      @tool.connect
      @tool.send_message(log_level, message)
      @logger.info('Message sent successfully.')
    rescue DelphyError => e
      @logger.error("Message failed: #{e.message}")
      raise
    ensure
      @tool.disconnect
    end
  end

  # Reset DELPHY System
  def reset_system(mode, reason)
    begin
      @logger.info("Resetting system in MODE=#{RESET_MODES[mode]} with REASON=#{reason}")
      @tool.connect
      @tool.reset_system(mode, reason)
      @logger.info('System reset successfully.')
    rescue DelphyError => e
      @logger.error("System reset failed: #{e.message}")
      raise
    ensure
      @tool.disconnect
    end
  end

  # --------------------------------------------
  # TELEMETRY MONITORING
  # --------------------------------------------

  # Monitor Telemetry
  def monitor_telemetry(packet_type, timeout = TELEMETRY_TIMEOUT)
    begin
      @logger.info("Monitoring telemetry for TYPE=#{packet_type} with TIMEOUT=#{timeout}")
      @tool.connect
      packet = @tool.monitor_telemetry(packet_type, timeout)
      @logger.info("Telemetry Packet Received: #{packet.inspect}")
      return packet
    rescue DelphyError => e
      @logger.error("Telemetry monitoring failed: #{e.message}")
      raise
    ensure
      @tool.disconnect
    end
  end

  # Parse Telemetry
  def parse_telemetry(packet)
    begin
      @logger.info('Parsing telemetry packet...')
      parsed = @tool.parse_telemetry(packet)
      @logger.info("Parsed Telemetry: #{parsed.inspect}")
      return parsed
    rescue DelphyError => e
      @logger.error("Telemetry parsing failed: #{e.message}")
      raise
    end
  end

  # --------------------------------------------
  # SYSTEM DIAGNOSTICS
  # --------------------------------------------

  # Perform Diagnostics
  def perform_diagnostics
    begin
      @logger.info('Performing diagnostics on DELPHY...')
      @tool.connect
      @tool.perform_diagnostics
      @logger.info('Diagnostics completed successfully.')
    rescue DelphyError => e
      @logger.error("Diagnostics failed: #{e.message}")
      raise
    ensure
      @tool.disconnect
    end
  end

  # --------------------------------------------
  # WORKFLOWS
  # --------------------------------------------

  # Full Automated Workflow
  def execute_full_workflow(script_id, parameter)
    begin
      @logger.info('Starting full automated DELPHY workflow...')
      @tool.connect
      @tool.run_script(script_id, parameter)
      telemetry_packet = @tool.monitor_telemetry(:complete, COMPLETE_TIMEOUT)
      parsed_packet = @tool.parse_telemetry(telemetry_packet)
      @tool.reset_system(0, 'End of workflow reset')
      @logger.info("Workflow completed successfully: #{parsed_packet.inspect}")
    rescue DelphyError => e
      @logger.error("Workflow failed: #{e.message}")
      raise
    ensure
      @tool.disconnect
    end
  end

  # --------------------------------------------
  # INTERACTIVE SESSION
  # --------------------------------------------

  def interactive_session
    puts '--- DELPHY Interactive Session ---'
    puts 'Available Commands:'
    puts '1. run_script [script_id] [parameter]'
    puts '2. send_message [log_level] [message]'
    puts '3. reset_system [mode] [reason]'
    puts '4. monitor_telemetry [packet_type]'
    puts '5. perform_diagnostics'
    puts '6. execute_full_workflow [script_id] [parameter]'
    puts '7. exit'

    loop do
      print '> '
      input = gets.chomp.split
      command = input.shift

      case command
      when 'run_script'
        run_script(input[0].to_i, input[1].to_f)
      when 'send_message'
        send_message(input[0].to_i, input[1..].join(' '))
      when 'reset_system'
        reset_system(input[0].to_i, input[1..].join(' '))
      when 'monitor_telemetry'
        monitor_telemetry(input[0].to_sym)
      when 'perform_diagnostics'
        perform_diagnostics
      when 'execute_full_workflow'
        execute_full_workflow(input[0].to_i, input[1].to_f)
      when 'exit'
        puts 'Exiting interactive session...'
        break
      else
        puts 'Unknown command. Please try again.'
      end
    end
  rescue Interrupt
    puts "\nExiting session..."
    @tool.disconnect
  rescue StandardError => e
    @logger.error("Interactive session error: #{e.message}")
    puts "Error: #{e.message}"
  ensure
    @logger.close_logger
  end
end

# --------------------------------------------
# MAIN PROCEDURE EXECUTION
# --------------------------------------------
if __FILE__ == $PROGRAM_NAME
  script = DelphyScript.new

  if ARGV.empty?
    script.interactive_session
  else
    case ARGV[0]
    when 'workflow'
      script.execute_full_workflow(ARGV[1].to_i, ARGV[2].to_f)
    when 'diagnostics'
      script.perform_diagnostics
    else
      puts 'Usage:'
      puts '  ruby config/procedures/delphy_script.rb workflow [script_id] [parameter]'
      puts '  ruby config/procedures/delphy_script.rb diagnostics'
    end
  end
end
