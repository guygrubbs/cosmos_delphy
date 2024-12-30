#!/usr/bin/env ruby
# config/targets/DELPHY/tools/delphy_tool_gui.rb
# DELPHY Graphical User Interface for Monitoring and Controlling DELPHY System

require 'cosmos'
require 'cosmos/gui/qt_tool'
require 'cosmos/script'
require_relative 'delphy_tool_logger'
require_relative '../../lib/delphy_constants'
require_relative '../../lib/delphy_helper'
require_relative 'configs/tool_config'

# --------------------------------------------
# DELPHY GUI Tool Class
# --------------------------------------------
class DelphyToolGUI < Cosmos::QtTool
  include DelphyConstants
  include DelphyHelper

  def initialize
    super()
    @logger = DelphyToolLogger.new('config/targets/DELPHY/tools/logs/delphy_gui.log', 'INFO')
    @logger.info('DELPHY GUI Tool Initialized')

    setup_ui
    setup_signals
  end

  # --------------------------------------------
  # GUI Setup
  # --------------------------------------------
  def setup_ui
    setWindowTitle('DELPHY GUI Tool')
    resize(600, 400)

    @connect_button = Qt::PushButton.new('Connect')
    @disconnect_button = Qt::PushButton.new('Disconnect')
    @run_script_button = Qt::PushButton.new('Run Script')
    @monitor_button = Qt::PushButton.new('Monitor Telemetry')
    @reset_button = Qt::PushButton.new('Reset System')
    @diagnostics_button = Qt::PushButton.new('Run Diagnostics')
    @exit_button = Qt::PushButton.new('Exit')

    @log_area = Qt::TextEdit.new
    @log_area.readOnly = true

    layout = Qt::VBoxLayout.new
    layout.addWidget(@connect_button)
    layout.addWidget(@disconnect_button)
    layout.addWidget(@run_script_button)
    layout.addWidget(@monitor_button)
    layout.addWidget(@reset_button)
    layout.addWidget(@diagnostics_button)
    layout.addWidget(@log_area)
    layout.addWidget(@exit_button)

    setLayout(layout)
  end

  # --------------------------------------------
  # Signal Handlers
  # --------------------------------------------
  def setup_signals
    connect(@connect_button, SIGNAL('clicked()')) { handle_connect }
    connect(@disconnect_button, SIGNAL('clicked()')) { handle_disconnect }
    connect(@run_script_button, SIGNAL('clicked()')) { handle_run_script }
    connect(@monitor_button, SIGNAL('clicked()')) { handle_monitor_telemetry }
    connect(@reset_button, SIGNAL('clicked()')) { handle_reset_system }
    connect(@diagnostics_button, SIGNAL('clicked()')) { handle_diagnostics }
    connect(@exit_button, SIGNAL('clicked()')) { handle_exit }
  end

  # --------------------------------------------
  # Button Handlers
  # --------------------------------------------
  def handle_connect
    begin
      @tool.connect
      @logger.info('GUI: Connected to DELPHY successfully.')
    rescue DelphyConnectionError => e
      @logger.error("GUI: Connection error - #{e.message}")
      display_error("Connection Error: #{e.message}")
    rescue StandardError => e
      @logger.error("GUI: Unexpected connection error - #{e.message}")
      @logger.error(e.full_message)
      display_error('Unexpected error occurred during connection.')
    end
  end

  def handle_disconnect
    @logger.info('Attempting to disconnect via GUI...')
    begin
      cmd('DELPHY', 'DISCONNECT')
      @log_area.append('Disconnected from DELPHY successfully.')
      @logger.info('Disconnected successfully.')
    rescue StandardError => e
      @log_area.append("Disconnection failed: #{e.message}")
      @logger.error("Disconnection failed: #{e.message}", e)
    end
  end

  def handle_run_script
    script_id = Qt::InputDialog.getInt(self, 'Script ID', 'Enter Script ID:')
    parameter = Qt::InputDialog.getDouble(self, 'Parameter', 'Enter Parameter:')
    @logger.info("Running script with ID=#{script_id}, Parameter=#{parameter}")
    begin
      cmd('DELPHY', 'RUN_SCRIPT', 'SCRIPT_ID' => script_id, 'PARAMETER' => parameter)
      @log_area.append("Script #{script_id} executed successfully with parameter #{parameter}.")
      @logger.info("Script executed successfully.")
    rescue StandardError => e
      @log_area.append("Script execution failed: #{e.message}")
      @logger.error("Script execution failed: #{e.message}", e)
    end
  end

  def handle_monitor_telemetry
    @logger.info('Monitoring telemetry via GUI...')
    begin
      wait_check('DELPHY METADATA SYSTEM_STATE == "NOMINAL"', 10)
      @log_area.append('Telemetry monitoring successful: SYSTEM_STATE is NOMINAL.')
      @logger.info('Telemetry monitoring successful.')
    rescue StandardError => e
      @log_area.append("Telemetry monitoring failed: #{e.message}")
      @logger.error("Telemetry monitoring failed: #{e.message}", e)
    end
  end

  def handle_reset_system
    begin
      @tool.reset_system(0, 'GUI Reset Command')
      @logger.info('GUI: Reset command executed successfully.')
    rescue DelphyCommandError => e
      @logger.error("GUI: Reset command failed - #{e.message}")
      display_error("Reset Command Error: #{e.message}")
    rescue StandardError => e
      @logger.error("GUI: Unexpected reset error - #{e.message}")
      @logger.error(e.full_message)
      display_error('Unexpected error occurred during reset.')
    end
  end

  def handle_diagnostics
    @logger.info('Running diagnostics via GUI...')
    begin
      cmd('DELPHY', 'RUN_DIAGNOSTICS')
      @log_area.append('Diagnostics completed successfully.')
      @logger.info('Diagnostics completed successfully.')
    rescue StandardError => e
      @log_area.append("Diagnostics failed: #{e.message}")
      @logger.error("Diagnostics failed: #{e.message}", e)
    end
  end

  def handle_exit
    @logger.info('Exiting GUI...')
    close
  end
end

# --------------------------------------------
# MAIN GUI EXECUTION
# --------------------------------------------
if __FILE__ == $PROGRAM_NAME
  app = Qt::Application.new(ARGV)
  gui = DelphyToolGUI.new
  gui.show
  app.exec
end
