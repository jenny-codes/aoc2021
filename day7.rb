# frozen_string_literal: true

require './runner'

class Day7 < Runner
  def do_puzzle1
    dist = @input.tally
    ((@input.min)..(@input.max)).map do |idx|
      dist.map { |pos, count| (idx - pos).abs * count }.sum
    end.min
  end

  def do_puzzle2
    dist = @input.tally
    multiplier = ->(n) { n * (n + 1) / 2 }

    ((@input.min)..(@input.max)).map do |idx|
      dist.map { |pos, count| multiplier[(idx - pos).abs] * count }.sum
    end.min
  end

  def parse(raw_input)
    raw_input[0].split(',').map(&:to_i)
  end
end
