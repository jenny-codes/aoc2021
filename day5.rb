# frozen_string_literal: true

require './lib/pipe'

Position = Struct.new(:x, :y)

Line = Struct.new(:from, :to) do
  def positions
    draw_vertical || draw_horizontal || draw_diagonal || draw_blank
  end

  def draw_vertical
    return unless vertical?

    x = from.x
    start_y, end_y = [from.y, to.y].minmax
    (start_y..end_y).map { |y| Position.new(x, y) }
  end

  def draw_horizontal
    return unless horizontal?

    y = from.y
    start_x, end_x = [from.x, to.x].minmax
    (start_x..end_x).map { |x| Position.new(x, y) }
  end

  def draw_diagonal
    return unless diagonal?

    x_dis = to.x - from.x
    y_dis = to.y - from.y
    x_vec = x_dis / x_dis.abs
    y_vec = y_dis / y_dis.abs
    steps = x_dis.abs

    (0..steps).map do |dis|
      Position.new(from.x + x_vec * dis, from.y + y_vec * dis)
    end
  end

  def draw_blank
    new([])
  end

  def vertical?
    from.x == to.x
  end

  def horizontal?
    from.y == to.y
  end

  def diagonal?
    (from.x - to.x).abs == (from.y - to.y).abs
  end
end

class Board
  def initialize
    @coordinates = {}
  end

  def draw(line)
    line.positions.each do |pos|
      @coordinates[pos] ||= 0
      @coordinates[pos] += 1
    end
  end

  def draw_vertical_or_horizontal(line)
    return unless line.vertical? || line.horizontal?

    draw(line)
  end

  def overlap_count
    @coordinates.values.count { |v| v > 1 }
  end
end

# ===========================================
# Main functions

do_puzzle1 = ->(input) {
  board = Board.new
  input.each { |line| board.draw_vertical_or_horizontal(line) }

  board.overlap_count
}

do_puzzle2 = ->(input) {
  board = Board.new
  input.each { |line| board.draw(line) }

  board.overlap_count
}

# ===========================================
# Adapter

parse = ->(input) {
  input.map do |row|
    row
      .split(' -> ')
      .map { |pair_str| Position.new(*pair_str.split(',').map(&:to_i)) }
      .then { |pair_pos| Line.new(*pair_pos) }
  end
}

# ===========================================
# IO Utils

read_input = ->(file_path) {
  File.readlines(file_path).map(&:strip)
}

print_output = ->(label) { ->(output) { puts "#{label}: #{output}" } }

# ===========================================
# Execution

Pipe['data/day5.txt'][read_input][parse][do_puzzle1][print_output['puzzle 1']].run
Pipe['data/day5.txt'][read_input][parse][do_puzzle2][print_output['puzzle 2']].run
