# frozen_string_literal: true

require './runner'

Octopus = Struct.new(:energy, :is_flashed) do
  def increase_energy(n)
    return self if flashed?

    Octopus.new(energy + n, false)
  end

  def should_flash?
    !flashed? && energy > 9
  end

  def flash
    Octopus.new(0, true)
  end

  def flashed?
    is_flashed
  end

  def reset_flash
    Octopus.new(energy, false)
  end
end

class Board
  attr_reader :data

  def initialize(data)
    @data = data.each_with_index.each_with_object({}) do |y, memo|
      y[0].each_with_index.map do |val, x_idx|
        key = [x_idx, y[1]]
        memo[key] = Octopus.new(val, false)
      end
    end
  end

  def step
    reset_octopus_states
    increase_energies_at(@data.keys)
    count_flashed_octopus
  end

  def increase_energies_at(positions)
    neighbors = positions.tally.reduce([]) do |memo, spot|
      pos, n = spot
      new_oct = @data[pos].increase_energy(n)
      if new_oct.should_flash?
        put_octopus_at(pos, new_oct.flash)
        memo + Board.neighbors_of(pos)
      else
        put_octopus_at(pos, new_oct)
        memo
      end
    end

    increase_energies_at(neighbors) if neighbors.any?
  end

  def put_octopus_at(pos, oct)
    @data[pos] = oct
  end

  def reset_octopus_states
    @data.transform_values!(&:reset_flash)
  end

  def count_flashed_octopus
    @data.values.inspect
    @data.values.count(&:flashed?)
  end

  def get_octopus_at(pos)
    @data[pos]
  end

  def self.neighbors_of(pos)
    x, y = pos
    [
      [x, y + 1], [x - 1, y],
      [x, y - 1], [x + 1, y],
      [x + 1, y + 1], [x - 1, y - 1],
      [x - 1, y + 1], [x + 1, y - 1]
    ].reject { |posi| posi[0] < 0 || posi[1] < 0 || posi[0] > 9 || posi[1] > 9 }
  end

  def inspect
    @data.map do |pos, oct|
      [pos, oct.energy]
    end.inspect
  end
end

# ===========================================
# Runner

class Day11 < Runner
  def do_puzzle1
    board = Board.new(@input)
    count = 0
    100.times { count += board.step }
    count
  end

  def do_puzzle2
    board = Board.new(@input)
    count = 1
    count += 1 until board.step == 100
    count
  end

  def parse(raw_input)
    raw_input.map { |row| row.split('').map(&:to_i) }
  end
end
