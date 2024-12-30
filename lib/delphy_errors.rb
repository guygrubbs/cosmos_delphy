# lib/delphy_errors.rb
# Custom Error Classes for DELPHY Interface in COSMOS v4
# Handles specific error conditions related to DELPHY communication and operations.

require 'cosmos'
require 'cosmos/logging/logger'

# Base class for all DELPHY-related errors
class DelphyError < StandardError
  def initialize(msg = 'An unknown error occurred in DELPHY operation.')
    super("[DELPHY_ERROR] #{msg}")
    Cosmos::Logger.error("[DELPHY_ERROR] #{msg}")
  end
end

# Error for connection issues
class DelphyConnectionError < DelphyError
  def initialize(msg = 'Failed to establish or maintain connection with DELPHY interface.')
    super(msg)
  end
end

# Error for invalid packet structure
class DelphyPacketError < DelphyError
  def initialize(msg = 'Malformed or invalid packet received from DELPHY interface.')
    super(msg)
  end
end

# Error for acknowledgment failure
class DelphyAcknowledgmentError < DelphyError
  def initialize(msg = 'ACK packet was not received or had an invalid response code.')
    super(msg)
  end
end

# Error for script execution failure
class DelphyScriptExecutionError < DelphyError
  def initialize(msg = 'Script execution on DELPHY interface failed.')
    super(msg)
  end
end

# Error for telemetry timeout
class DelphyTelemetryTimeoutError < DelphyError
  def initialize(msg = 'Telemetry response timeout occurred.')
    super(msg)
  end
end

# Error for invalid commands
class DelphyCommandError < DelphyError
  def initialize(msg = 'The command sent to DELPHY was invalid or improperly formatted.')
    super(msg)
  end
end

# Error for invalid configuration
class DelphyConfigurationError < DelphyError
  def initialize(msg = 'DELPHY configuration parameters are invalid or missing.')
    super(msg)
  end
end

# Error for unknown response
class DelphyUnknownResponseError < DelphyError
  def initialize(msg = 'Received an unknown or unhandled response from DELPHY interface.')
    super(msg)
  end
end

# Utility Module for Error Handling
module DelphyErrorHandler
  # Gracefully handle errors and log them
  def self.handle_error(error)
    case error
    when DelphyConnectionError
      Cosmos::Logger.error("[DELPHY_ERROR_HANDLER] Connection Error: #{error.message}")
    when DelphyPacketError
      Cosmos::Logger.error("[DELPHY_ERROR_HANDLER] Packet Error: #{error.message}")
    when DelphyAcknowledgmentError
      Cosmos::Logger.error("[DELPHY_ERROR_HANDLER] ACK Error: #{error.message}")
    when DelphyScriptExecutionError
      Cosmos::Logger.error("[DELPHY_ERROR_HANDLER] Script Execution Error: #{error.message}")
    when DelphyTelemetryTimeoutError
      Cosmos::Logger.error("[DELPHY_ERROR_HANDLER] Telemetry Timeout: #{error.message}")
    when DelphyCommandError
      Cosmos::Logger.error("[DELPHY_ERROR_HANDLER] Command Error: #{error.message}")
    when DelphyConfigurationError
      Cosmos::Logger.error("[DELPHY_ERROR_HANDLER] Configuration Error: #{error.message}")
    when DelphyUnknownResponseError
      Cosmos::Logger.error("[DELPHY_ERROR_HANDLER] Unknown Response: #{error.message}")
    else
      Cosmos::Logger.error("[DELPHY_ERROR_HANDLER] General Error: #{error.message}")
    end

    # Optionally re-raise the error to halt execution
    raise error
  end
end

# Test Cases (Run Directly)
if __FILE__ == $PROGRAM_NAME
  begin
    # Simulating Errors
    raise DelphyConnectionError, 'Unable to connect to 129.162.153.79:5000'
  rescue DelphyError => e
    DelphyErrorHandler.handle_error(e)
  end

  begin
    raise DelphyPacketError, 'Packet header validation failed'
  rescue DelphyError => e
    DelphyErrorHandler.handle_error(e)
  end

  begin
    raise DelphyAcknowledgmentError, 'ACK response code was not SUCCESS'
  rescue DelphyError => e
    DelphyErrorHandler.handle_error(e)
  end

  begin
    raise DelphyTelemetryTimeoutError, 'Telemetry response not received in 10 seconds'
  rescue DelphyError => e
    DelphyErrorHandler.handle_error(e)
  end

  puts '[INFO] All error tests completed successfully.'
end
