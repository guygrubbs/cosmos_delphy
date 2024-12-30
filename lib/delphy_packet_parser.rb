# lib/delphy_packet_parser.rb
# DELPHY Packet Parser
# Enhancements: Robust error handling, alignment with PCS Network Specification,
# synchronization validation logic, and improved error messaging.

class DelphyPacketParser
  PACKET_SYNC_WORD = 0xDEADBEEF
  RESPONSE_CODES = {
    0 => 'Success',
    1 => 'Malformed Packet',
    2 => 'Incomplete Packet',
    3 => 'Synchronization Error',
    4 => 'Unknown Error'
  }

  attr_reader :last_error

  def initialize
    @last_error = nil
  end

  # Parse a raw packet string and return a structured hash
  def parse(packet)
    begin
      validate_packet(packet)
      header = extract_header(packet)
      body = extract_body(packet)

      case header[:type]
      when 'CONFIGURATION'
        parse_configuration_packet(body)
      when 'CAPTURE'
        parse_capture_packet(body)
      else
        raise StandardError, "Unknown packet type: #{header[:type]}"
      end
    rescue StandardError => e
      @last_error = e.message
      log_error(e.message)
      { status: 'ERROR', code: error_code_from_message(e.message), message: e.message }
    end
  end

  private

  # Validate packet structure and synchronization
  def validate_packet(packet)
    raise StandardError, RESPONSE_CODES[1] if packet.nil? || packet.empty?
    raise StandardError, RESPONSE_CODES[2] if packet.length < minimum_packet_length

    sync_word = packet[0, 4].unpack1('L>')
    raise StandardError, RESPONSE_CODES[3] unless sync_word == PACKET_SYNC_WORD
  end

  # Extract packet header
  def extract_header(packet)
    {
      sync_word: packet[0, 4].unpack1('L>'),
      length: packet[4, 2].unpack1('S>'),
      type: packet[6, 10].strip
    }
  rescue => e
    raise StandardError, "Header parsing failed: #{e.message}"
  end

  # Extract packet body
  def extract_body(packet)
    length = packet[4, 2].unpack1('S>')
    packet[16, length]
  rescue => e
    raise StandardError, "Body parsing failed: #{e.message}"
  end

  # Parse Configuration Packet
  def parse_configuration_packet(body)
    configuration = {
      parameter_id: body[0, 2].unpack1('S>'),
      value: body[2, 4].unpack1('f'),
      timestamp: body[6, 8].unpack1('Q>')
    }
    validate_configuration_packet(configuration)
    configuration
  rescue => e
    raise StandardError, "Configuration packet parsing failed: #{e.message}"
  end

  # Validate Configuration Packet
  def validate_configuration_packet(config)
    raise StandardError, 'Invalid Configuration Parameter ID' unless (0..65535).include?(config[:parameter_id])
    raise StandardError, 'Invalid Timestamp' if config[:timestamp] <= 0
  end

  # Parse Capture Packet
  def parse_capture_packet(body)
    capture = {
      frame_id: body[0, 2].unpack1('S>'),
      data: body[2..-1]
    }
    validate_capture_packet(capture)
    capture
  rescue => e
    raise StandardError, "Capture packet parsing failed: #{e.message}"
  end

  # Validate Capture Packet
  def validate_capture_packet(capture)
    raise StandardError, 'Invalid Frame ID' unless (0..65535).include?(capture[:frame_id])
    raise StandardError, 'Empty Capture Data' if capture[:data].nil? || capture[:data].empty?
  end

  # Return minimum valid packet length
  def minimum_packet_length
    16 # Header size + at least minimal body
  end

  # Map error messages to response codes
  def error_code_from_message(message)
    case message
    when /Malformed Packet/ then 1
    when /Incomplete Packet/ then 2
    when /Synchronization Error/ then 3
    else 4
    end
  end

  # Log errors for debugging and monitoring
  def log_error(message)
    puts "[ERROR] Packet Parsing: #{message}"
  end
end