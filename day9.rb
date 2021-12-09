# frozen_string_literal: true

require './runner'

Point = Struct.new(:position, :value) do
  def valid?
    x, y = position
    x >= 0 && y >= 0
  end
end

Line = Struct.new(:points) do
  def low_points
    direction = :desc
    result = []
    points.each_cons(2) do |pair|
      if pair[0].value < pair[1].value && direction == :desc
        direction = :asc
        result << pair[0]
      elsif pair[0].value > pair[1].value && direction == :asc
        direction = :desc
      end
    end
    result << points[-1] if points[-1].value < points[-2].value
    result
  end
end

class Board
  def initialize(input)
    @data = input.each_with_index.map do |row, y_idx|
      row.split('').map(&:to_i).each_with_index.map do |val, x_idx|
        Point.new([x_idx, y_idx], val)
      end
    end
    @x_boundry = @data[0].count - 1
    @y_boundry = @data.count - 1
  end

  def each_row(&block)
    @data.map(&block)
  end

  def each_col(&block)
    @data.transpose.map(&block)
  end

  def all_points
    @data.flatten
  end

  def neighbors_for(point)
    x, y = point.position

    right = @data[y][x + 1] if x < @x_boundry
    left = @data[y][x - 1] if x > 0
    up = @data[y + 1][x] if y < @y_boundry
    down = @data[y - 1][x] if y > 0

    [right, left, up, down].compact
  end
end

# ===========================================
# Runner

class Day9 < Runner
  def do_puzzle1
    board = Board.new(@input)
    rows = board.each_row { |row| Line.new(row).low_points }.flatten
    cols = board.each_col { |col| Line.new(col).low_points }.flatten
    (rows & cols).sum { |point| point.value + 1 }
  end

  def do_puzzle2
    board = Board.new(@input)
    rem = board.all_points
    basins = []
    basins << count_neigbors(board, rem, rem[0]) while rem.any?
    basins.sort.last(3).reduce(&:*)
  end

  def count_neigbors(board, rem, current_point)
    return 0 unless current_point.valid?
    return 0 unless rem.delete(current_point)
    return 0 if current_point.value == 9

    1 + board.neighbors_for(current_point).sum do |n|
      count_neigbors(board, rem, n)
    end
  end

  def parse(raw_input)
    raw_input
  end
end
