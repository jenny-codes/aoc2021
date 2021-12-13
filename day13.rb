# frozen_string_literal: true

require './runner'

Point = Struct.new(:x, :y) do
  def mirror_on(direction, value)
    if direction == 'x'
      return self if x < value

      Point.new(2 * value - x, y)
    elsif direction == 'y'
      return self if y < value

      Point.new(x, 2 * value - y)
    else
      raise "Unknown direction #{direction}"
    end
  end
end

Instruction = Struct.new(:direction, :value)

Paper = Struct.new(:points) do
  def fold(instructions)
    folded_points = instructions.reduce(points) do |memo, inst|
      memo.map { |point| point.mirror_on(inst.direction, inst.value) }.uniq
    end

    Paper.new(folded_points)
  end

  def draw
    lines = points.group_by(&:y)
    "\n" + (0..(lines.keys.max)).map do |y_index|
      next "\n" unless lines[y_index]

      cols = lines[y_index].sort_by(&:x).map(&:x)
      (0..(cols.max)).map { |x_index| cols.include?(x_index) ? '#' : ' ' }.join + "\n"
    end.join
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
