# frozen_string_literal: true

require './runner'

Point = Struct.new(:x, :y) do
  def fold_along(direction, value)
    if direction == 'x'
      raise 'How to handle point on the line?' if x == value
      return self if x < value

      Point.new(2 * value - x, y)
    elsif direction == 'y'
      raise 'How to handle point on the line?' if y == value
      return self if y < value

      Point.new(x, 2 * value - y)
    else
      raise "Unknown direction #{direction}"
    end
  end

  def valid?
    raise "#{self} is out of boundary?" unless x >= 0 && y >= 0

    x >= 0 && y >= 0
  end
end

Instruction = Struct.new(:direction, :value)

Paper = Struct.new(:points) do
  def fold(instructions)
    new_points = instructions.reduce(points) do |memo, inst|
      memo.reduce([]) do |acc, point|
        new_point = point.fold_along(inst.direction, inst.value)
        next acc unless new_point.valid?

        acc << new_point
      end.uniq
    end

    Paper.new(new_points)
  end

  def draw
    current_y = 0
    points.group_by(&:y).sort_by { |y, _| y }.each do |y, points|
      until current_y == y
        current_y += 1
        puts ''
      end

      current_y += 1

      current_x = 0
      str = points.sort_by(&:x).map(&:x).reduce('') do |memo, x|
        until current_x == x
          memo += ' '
          current_x += 1
        end

        current_x += 1
        memo += '#'
      end
      puts str
    end

    nil
  end

  def count_points
    points.count
  end
end

class Day13 < Runner
  def do_puzzle1
    paper, instructions = @input
    paper.fold(instructions.first(1)).count_points
  end

  def do_puzzle2
    paper, instructions = @input
    paper.fold(instructions).draw
  end

  def parse(raw_input)
    # raw_input = %w[
    # 6,10
    # 0,14
    # 9,10
    # 0,3
    # 10,4
    # 4,11
    # 6,0
    # 6,12
    # 4,1
    # 0,13
    # 10,12
    # 3,4
    # 3,0
    # 8,4
    # 1,10
    # 2,14
    # 8,10
    # 9,0
    # ] << 'fold along y=7' << 'fold along x=5'

    paper = Paper.new([])
    instructions = []
    raw_input.each do |line|
      next if line.empty?

      if line.start_with?('fold')
        direction, value = line.split(' ').last.split('=')
        instructions << Instruction.new(direction, value.to_i)
      else
        paper.points << Point.new(*line.split(',').map(&:to_i))
      end
    end

    [paper, instructions]
  end
end
