# frozen_string_literal: true

require './runner'

# MOdel Number Automatic Detector program
class Program
  def self.compile(instructions)
    insts = instructions.map { _1.split(' ') }
    segments = 14.times.map { build_segment(insts.shift(18)) }
    new(segments)
  end

  def initialize(segments)
    @segments = segments
  end

  def execute(seg, z, w)
    @segments[seg].call(z, w)
  end

  def self.build_segment(insts)
    var1 = insts[4][2].to_i
    var2 = insts[5][2].to_i
    var3 = insts[15][2].to_i

    ->(z, w) {
      # It's only possible for x to be when if var2 < 10 because of the input limit.
      # And we need x to be 0 7 times to balance off the 7 times it's multiplied.
      # Hence we know it would not be a valid number if var2 < 10 but x is still 1.

      x = (z % 26 + var2) == w ? 0 : 1
      return false if var2 <= 9 && x == 1

      z /= var1
      z *= (25 * x + 1)
      z + (w + var3) * x
    }
  end

  def scan_range(range)
    scan(range, 0, 0, [])
    @scan_result
  end

  def scan(range, z, curr_seg, acc)
    range.find do |w|
      next_acc = acc.dup << w
      next_z = execute(curr_seg, z, w)
      next unless next_z

      is_finished = curr_seg == 13
      return @scan_result = next_acc.join.to_i if is_finished && next_z.zero?
      next if is_finished

      scan(range, next_z, curr_seg + 1, next_acc)
    end
  end
end

class Day24 < Runner
  def do_puzzle1
    range = (1..9).to_a.reverse
    Program.compile(@input).scan_range(range)
  end

  def do_puzzle2
    range = (1..9).to_a
    Program.compile(@input).scan_range(range)
  end

  def parse(raw_input)
    raw_input
  end
end

