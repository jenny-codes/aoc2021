# # frozen_string_literal: true

require './runner'

Packet = Struct.new(:version, :type_id, :value)

class LiteralPacket < Packet; end

class OperatorPacket < Packet; end

class Transmission
  attr_reader :root_packet, :version_id_sum

  def initialize(bits)
    @version_id_sum = 0
    _, @root_packet = parse(bits)
  end

  def calculate
    recurse_calculate([root_packet])[0]
  end

  def parse(bits)
    version = bits.slice!(0..2).to_i(2)
    @version_id_sum += version

    type_id = bits.slice!(0..2).to_i(2)
    packet = if type_id == 4
               num_in_bits = ''
               num_in_bits += bits.slice!(0..3) while bits.slice!(0) == '1'
               num_in_bits += bits.slice!(0..3)
               num = num_in_bits.to_i(2)
               LiteralPacket.new(version, type_id, num)
             else
               length_type_id = bits.slice!(0).to_i(2)
               case length_type_id
               when 0
                 total_length_in_bits = bits.slice!(0..14).to_i(2)
                 subpackets = parse_fixed_length(bits.slice!(0...total_length_in_bits))
                 OperatorPacket.new(version, type_id, subpackets)
               when 1
                 subpacket_count = bits.slice!(0..10).to_i(2)
                 bits, subpackets = parse_with_count(bits, subpacket_count)
                 OperatorPacket.new(version, type_id, subpackets)
               else
                 raise "#{total_length_in_bits} should be either 0 or 1"
               end
             end
    raise('Certainly packet should not be nil?') unless packet

    [bits, packet]
  end

  private

  def parse_fixed_length(bits)
    packets = []
    while bits.length > 6
      bits, packet = parse(bits)
      packets << packet
    end
    packets
  end

  def parse_with_count(bits, count)
    packets = []
    count.times do |_i|
      bits, packet = parse(bits)
      packets << packet
    end

    [bits, packets]
  end

  def recurse_calculate(packets)
    packets.map do |packet|
      next packet.value if packet.is_a?(LiteralPacket)

      case packet.type_id
      when 0
        recurse_calculate(packet.value).reduce(&:+)
      when 1
        recurse_calculate(packet.value).reduce(&:*)
      when 2
        recurse_calculate(packet.value).min
      when 3
        recurse_calculate(packet.value).max
      when 5
        a, b = recurse_calculate(packet.value)
        a > b ? 1 : 0
      when 6
        a, b = recurse_calculate(packet.value)
        a < b ? 1 : 0
      when 7
        a, b = recurse_calculate(packet.value)
        a == b ? 1 : 0
      end
    end
  end
end

class Day16 < Runner
  def do_puzzle1
    @transmission ||= Transmission.new(@input)
    @transmission.version_id_sum
  end

  def do_puzzle2
    @transmission ||= Transmission.new(@input)
    @transmission.calculate
  end

  def parse(raw_input)
    raw_input[0].split('').map { |i| i.hex.to_s(2).rjust(i.size * 4, '0') }.join
  end
end
