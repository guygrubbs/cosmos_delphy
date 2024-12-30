# lib/delphy_logger.rb
# Standardized Logger for DELPHY Tools

require 'logger'
require 'fileutils'

class DelphyToolLogger
  LOG_DIRECTORY = 'config/targets/DELPHY/tools/logs'.freeze
  DEFAULT_LOG_FILE = "#{LOG_DIRECTORY}/delphy_tool.log".freeze

  LOG_LEVELS = {
    'DEBUG' => Logger::DEBUG,
    'INFO'  => Logger::INFO,
    'WARN'  => Logger::WARN,
    'ERROR' => Logger::ERROR,
    'FATAL' => Logger::FATAL
  }.freeze

  def initialize(log_file = DEFAULT_LOG_FILE, log_level = 'DEBUG')
    setup_log_directory
    @logger = Logger.new(log_file, 'daily')
    @logger.level = LOG_LEVELS[log_level.upcase] || Logger::DEBUG
    @logger.datetime_format = '%Y-%m-%d %H:%M:%S'
    @logger.formatter = proc do |severity, datetime, progname, msg|
      "[#{datetime.strftime('%Y-%m-%d %H:%M:%S')}][#{severity}][#{progname}] #{msg}\n"
    end
  end

  def setup_log_directory
    FileUtils.mkdir_p(LOG_DIRECTORY) unless Dir.exist?(LOG_DIRECTORY)
  rescue StandardError => e
    puts "[ERROR] Failed to create log directory: #{e.message}"
    raise
  end

  def debug(message, source = 'DELPHY')
    @logger.debug(source) { message }
  end

  def info(message, source = 'DELPHY')
    @logger.info(source) { message }
  end

  def warn(message, source = 'DELPHY')
    @logger.warn(source) { message }
  end

  def error(message, source = 'DELPHY')
    @logger.error(source) { message }
  end

  def fatal(message, source = 'DELPHY')
    @logger.fatal(source) { message }
  end

  def close
    @logger.close
  end
end
