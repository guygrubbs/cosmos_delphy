# lib/delphy_packet_parser.rb
# Packet Parser for DELPHY Interface in COSMOS v4
# Handles encoding and decoding of DELPHY protocol packets based on the PCS Network Specification.

require 'cosmos'
require 'cosmos/logging/logger'
require 'socket'

class DelphyPacketParser
  # Packet Sync Constant
  PACKET_SYNC = 0xDEADBEEF

  # Packet Types (as per PCS Specification)
  PACKET_TYPES = {
    0 => 'ACK',
    6 => 'SCRIPT',
    8 => 'CONTROL',
    10 => 'IDENTITY',
    12 => 'COMPLETE'
  }.freeze

  # Header Structure
  HEADER_FORMAT = 'L>L>L>F>F>L>'
  HEADER_SIZE = 28 # Sync (4) + Type (4) + ID (4) + Session Time (8) + Packet Time (8) + Length (4)

  def initialize
    Cosmos::Logger.info('[DELPHY_PACKET_PARSER] Initialized Packet Parser')
  end

  # Encode a Packet
  def encode_packet(packet_type, packet_id, session_time, data)
    raise ArgumentError, 'Invalid packet type' unless PACKET_TYPES.key?(packet_type)

    packet_time = Time.now.to_f
    data_length = data.bytesize

    header = [
      PACKET_SYNC,
      packet_type,
      packet_id,
      session_time,
      packet_time,
      data_length
    ].pack(HEADER_FORMAT)

    Cosmos::Logger.info("[DELPHY_PACKET_PARSER] Encoding Packet: Type=#{packet_type}, ID=#{packet_id}, Length=#{data_length}")

    header + data
  end

  # Decode a Packet
  def decode_packet(packet)
    raise ArgumentError, 'Packet is too short to decode' if packet.bytesize < HEADER_SIZE

    header = packet[0...HEADER_SIZE]
    data = packet[HEADER_SIZE..-1]

    sync, packet_type, packet_id, session_time, packet_time, length = header.unpack(HEADER_FORMAT)

    unless sync == PACKET_SYNC
      raise StandardError, 'Invalid packet sync code'
    end

    if length != data.bytesize
      raise StandardError, "Data length mismatch: Expected=#{length}, Actual=#{data.bytesize}"
    end

    packet_info = {
      sync: sync,
      type: PACKET_TYPES[packet_type] || "UNKNOWN (#{packet_type})",
      id: packet_id,
      session_time: session_time,
      packet_time: packet_time,
      length: length,
      data: data
    }

    Cosmos::Logger.info("[DELPHY_PACKET_PARSER] Decoded Packet: #{packet_info.inspect}")

    packet_info
  end

  # Parse ACK Packet
  def parse_ack_packet(data)
    raise ArgumentError, 'Invalid ACK packet size' if data.bytesize < 8

    original_id, response_code = data.unpack('L>L>')
    message_length = data.bytesize - 8
    message = data[8, message_length]

    ack_info = {
      original_id: original_id,
      response_code: response_code,
      message: message.force_encoding('UTF-8')
    }

    Cosmos::Logger.info("[DELPHY_PACKET_PARSER] Parsed ACK Packet: #{ack_info.inspect}")
    ack_info
  end

  # Parse COMPLETE Packet
  def parse_complete_packet(data)
    raise ArgumentError, 'Invalid COMPLETE packet size' if data.bytesize < 8

    code, message_length = data.unpack('L>L>')
    message = data[8, message_length]

    complete_info = {
      code: code,
      message: message.force_encoding('UTF-8')
    }

    Cosmos::Logger.info("[DELPHY_PACKET_PARSER] Parsed COMPLETE Packet: #{complete_info.inspect}")
    complete_info
  end

  # Parse IDENTITY Packet
  def parse_identity_packet(data)
    raise ArgumentError, 'Invalid IDENTITY packet size' if data.bytesize < 4

    machine_id = data.unpack('L>').first
    identity_info = {
      machine_id: machine_id
    }

    Cosmos::Logger.info("[DELPHY_PACKET_PARSER] Parsed IDENTITY Packet: #{identity_info.inspect}")
    identity_info
  end

  # Parse CONTROL Packet
  def parse_control_packet(data)
    raise ArgumentError, 'Invalid CONTROL packet size' if data.bytesize < 4

    control_code = data.unpack('L>').first
    control_info = {
      control_code: control_code,
      message: data[4..-1].force_encoding('UTF-8')
    }

    Cosmos::Logger.info("[DELPHY_PACKET_PARSER] Parsed CONTROL Packet: #{control_info.inspect}")
    control_info
  end

  # Parse Generic Data Packet
  def parse_generic_packet(packet)
    parsed_packet = decode_packet(packet)
    data = parsed_packet[:data]

    case parsed_packet[:type]
    when 'ACK'
      parse_ack_packet(data)
    when 'COMPLETE'
      parse_complete_packet(data)
    when 'IDENTITY'
      parse_identity_packet(data)
    when 'CONTROL'
      parse_control_packet(data)
    else
      Cosmos::Logger.warn("[DELPHY_PACKET_PARSER] Unrecognized Packet Type: #{parsed_packet[:type]}")
      { raw_data: data }
    end
  end
end

# Test Case for Parser (Run Directly)
if __FILE__ == $PROGRAM_NAME
  parser = DelphyPacketParser.new
  session_time = Time.now.to_f

  # Test Encoding
  test_data = "Test packet data"
  encoded_packet = parser.encode_packet(0, 1, session_time, test_data)
  puts "Encoded Packet: #{encoded_packet.unpack('H*')}"

  # Test Decoding
  decoded_packet = parser.decode_packet(encoded_packet)
  puts "Decoded Packet: #{decoded_packet.inspect}"

  # Test Parsing ACK Packet
  ack_data = [1, 0].pack('L>L>') + "Acknowledgment".encode('UTF-8')
  ack_packet = parser.encode_packet(0, 2, session_time, ack_data)
  parsed_ack = parser.parse_ack_packet(ack_data)
  puts "Parsed ACK Packet: #{parsed_ack.inspect}"
end
