# config/tools/delphy_tool_gui.rb
# DELPHY Tool GUI for COSMOS v4 Deployment
# Provides a GUI interface for DELPHY operations using Tk toolkit

require 'tk'
require_relative '../../lib/delphy_tool'
require_relative '../../lib/delphy_constants'
require_relative '../../lib/delphy_errors'
require_relative '../../lib/delphy_helper'
require_relative '../../config/tools/delphy_tool_logger'

# --------------------------------------------
# DELPHY Tool GUI Class
# --------------------------------------------
class DelphyToolGUI
  include DelphyConstants

  def initialize
    @tool = DelphyTool.new
    @logger = DelphyToolLogger.new

    setup_gui
    Cosmos::Logger.info('[DELPHY_GUI] DELPHY Tool GUI Initialized')
  end

  # --------------------------------------------
  # GUI SETUP
  # --------------------------------------------
  def setup_gui
    @root = TkRoot.new { title 'DELPHY Tool GUI' }
    @root.geometry('800x600')

    # Status Frame
    status_frame = TkFrame.new(@root) { relief 'groove'; borderwidth 2 }.pack(fill: 'x')
    TkLabel.new(status_frame, text: 'DELPHY Tool Status:', font: 'Arial 12 bold').pack(side: 'left', padx: 5)
    @status_label = TkLabel.new(status_frame, text: 'Disconnected', fg: 'red').pack(side: 'left', padx: 5)

    # Command Frame
    command_frame = TkFrame.new(@root) { relief 'groove'; borderwidth 2 }.pack(fill: 'x')
    TkLabel.new(command_frame, text: 'Commands:', font: 'Arial 12 bold').pack(anchor: 'w', padx: 5)

    TkButton.new(command_frame, text: 'Connect', command: proc { connect }) \
      .pack(side: 'left', padx: 5, pady: 5)
    TkButton.new(command_frame, text: 'Disconnect', command: proc { disconnect }) \
      .pack(side: 'left', padx: 5, pady: 5)
    TkButton.new(command_frame, text: 'Run Script', command: proc { run_script }) \
      .pack(side: 'left', padx: 5, pady: 5)
    TkButton.new(command_frame, text: 'Send Message', command: proc { send_message }) \
      .pack(side: 'left', padx: 5, pady: 5)
    TkButton.new(command_frame, text: 'Reset System', command: proc { reset_system }) \
      .pack(side: 'left', padx: 5, pady: 5)

    # Telemetry Frame
    telemetry_frame = TkFrame.new(@root) { relief 'groove'; borderwidth 2 }.pack(fill: 'both', expand: true)
    TkLabel.new(telemetry_frame, text: 'Telemetry:', font: 'Arial 12 bold').pack(anchor: 'w', padx: 5)

    @telemetry_text = TkText.new(telemetry_frame, height: 15, wrap: 'word')
    @telemetry_text.pack(fill: 'both', expand: true, padx: 5, pady: 5)

    # Footer Frame
    footer_frame = TkFrame.new(@root) { relief 'groove'; borderwidth 2 }.pack(fill: 'x')
    TkButton.new(footer_frame, text: 'Exit', command: proc { exit_program }) \
      .pack(side: 'right', padx: 5, pady: 5)

    Tk.mainloop
  end

  # --------------------------------------------
  # GUI EVENT HANDLERS
  # --------------------------------------------

  def update_status(message, color = 'green')
    @status_label.text = message
    @status_label.fg = color
  end

  def append_telemetry(message)
    @telemetry_text.insert('end', "#{message}\n")
    @telemetry_text.see('end')
  end

  # --------------------------------------------
  # COMMAND METHODS
  # --------------------------------------------

  def connect
    begin
      @tool.connect
      update_status('Connected', 'green')
      @logger.info('Successfully connected to DELPHY interface')
    rescue DelphyError => e
      update_status('Connection Failed', 'red')
      @logger.error(e.message)
    end
  end

  def disconnect
    begin
      @tool.disconnect
      update_status('Disconnected', 'red')
      @logger.info('Successfully disconnected from DELPHY interface')
    rescue DelphyError => e
      update_status('Disconnection Failed', 'red')
      @logger.error(e.message)
    end
  end

  def run_script
    script_id = Tk.getOpenFile(title: 'Select Script ID', filetypes: [['Script ID', '.txt']])
    parameter = Tk.getOpenFile(title: 'Enter Parameter', filetypes: [['Parameter', '.txt']])

    if script_id.empty? || parameter.empty?
      @logger.warning('Script ID or Parameter not provided')
      return
    end

    begin
      @tool.run_script(script_id.to_i, parameter.to_f)
      append_telemetry("Script #{script_id} executed with parameter #{parameter}")
      @logger.info("Executed script with ID=#{script_id}, PARAMETER=#{parameter}")
    rescue DelphyError => e
      append_telemetry("Script execution failed: #{e.message}")
      @logger.error(e.message)
    end
  end

  def send_message
    message = Tk.getOpenFile(title: 'Enter Message', filetypes: [['Message', '.txt']])
    if message.empty?
      @logger.warning('Message not provided')
      return
    end

    begin
      @tool.send_message(0, message)
      append_telemetry("Message sent: #{message}")
      @logger.info("Sent message: #{message}")
    rescue DelphyError => e
      append_telemetry("Message failed: #{e.message}")
      @logger.error(e.message)
    end
  end

  def reset_system
    reason = Tk.getOpenFile(title: 'Enter Reset Reason', filetypes: [['Reason', '.txt']])
    if reason.empty?
      @logger.warning('Reset reason not provided')
      return
    end

    begin
      @tool.reset_system(0, reason)
      append_telemetry("System reset: #{reason}")
      @logger.info("System reset: #{reason}")
    rescue DelphyError => e
      append_telemetry("System reset failed: #{e.message}")
      @logger.error(e.message)
    end
  end

  def exit_program
    @tool.disconnect
    @logger.close_logger
    Tk.exit
  end
end

# --------------------------------------------
# MAIN GUI LAUNCHER
# --------------------------------------------
if __FILE__ == $PROGRAM_NAME
  begin
    DelphyToolGUI.new
  rescue StandardError => e
    puts "[DELPHY_GUI] GUI Launch Failed: #{e.message}"
  end
end
