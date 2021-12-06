# frozen_string_literal: true

require './runner'

Population = Struct.new(:distribution) do
  def grow
    new_dist = distribution.reduce(Hash.new(0)) do |memo, dist|
      phase, size = dist
      if phase == 0 # If hitting the end of cycle
        memo[8] = size # Generate a new batch of lantern fish
        memo[6] += size # Previous batch starts a new cycle
      else
        memo[phase - 1] += size # Others simply move on to the next phase
      end

      memo
    end

    Population.new(new_dist)
  end

  def total_size
    distribution.values.sum
  end
end

# ===========================================
# Runner

class Day6 < Runner
  def do_puzzle1
    80.times.reduce(@input) { |population, _| population.grow }.total_size
  end

  def do_puzzle2
    256.times.reduce(@input) { |population, _| population.grow }.total_size
  end

  def parse(raw_input)
    distribution = raw_input[0].split(',').map(&:to_i).tally
    Population.new(distribution)
  end
end

# ==========================================
# Honorable mention: First attempt

Fish = Struct.new(:phase) do
  def cycle
    if phase > 0
      [Fish.new(phase - 1)]
    else
      [Fish.new(6), Fish.new(8)]
    end
  end
end

# Usage
#
# @input.tally.reduce(0) do |memo, slice|
#   fish, n = slice
#   memo += n * (80.times.reduce([fish]) { |memo, _| memo.flat_map(&:cycle) }.count)
# end
