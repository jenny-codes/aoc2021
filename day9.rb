# frozen_string_literal: true

require './runner'

Point = Struct.new(:position, :value, :is_traversed) do
  def marked?
    value == 9 || is_traversed
  end

  def mark
    self.is_traversed = true
  end

  def valid?
    x, y = position
    x >= 0 && y >= 0
  end
end

Line = Struct.new(:points) do
  def low_points_in_line
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
        Point.new([x_idx, y_idx], val, false)
      end
    end
    @x_boundry = @data[0].count - 1
    @y_boundry = @data.count - 1
  end

  def low_points
    rows = each_row { |row| Line.new(row).low_points_in_line }.flatten
    cols = each_col { |col| Line.new(col).low_points_in_line }.flatten
    rows & cols
  end

  def calculate_basins
    low_points.map { |point| count_neigbors(point) }
  end

  def count_neigbors(point)
    return 0 if point.marked?

    point.mark
    1 + neighbors_for(point).sum { |n| count_neigbors(n) }
  end

  private

  def each_row(&block)
    @data.map(&block)
  end

  def each_col(&block)
    @data.transpose.map(&block)
  end

  def neighbors_for(point)
    x, y = point.position

    up = @data[y + 1][x] if y < @y_boundry
    right = @data[y][x + 1] if x < @x_boundry
    down = @data[y - 1][x] if y > 0
    left = @data[y][x - 1] if x > 0

    [right, left, up, down].compact
  end
end

# ===========================================
# Runner

class Day9 < Runner
  def do_puzzle1
    Board.new(@input).low_points.sum { |point| point.value + 1 }
  end

  def do_puzzle2
    basins = Board.new(@input).calculate_basins
    basins.sort.last(3).reduce(&:*)
  end

  def parse(raw_input)
    raw_input
  end
end
