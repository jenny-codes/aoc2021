# frozen_string_literal: true

require './runner'

class Day23 < Runner
  def do_puzzle1
    input = ['D C A B',
             'B C D A'].map { _1.split('') }.each_with_index.flat_map do |row, y_idx|
      row.each_with_index.filter_map do |val, x_idx|
        next if val.empty? || val == ' '

        [val, [x_idx, y_idx]]
      end
    end

    base_line = calculate_baseline(input, 1)

    # Manual calculation
    base_line + 20 + 4
  end

  def do_puzzle2
    input = ['D C A B',
             'D C B A',
             'D B A C',
             'B C D A'].map { _1.split('') }.each_with_index.flat_map do |row, y_idx|
      row.each_with_index.filter_map do |val, x_idx|
        next if val.empty? || val == ' '

        [val, [x_idx, y_idx]]
      end
    end

    base_line = calculate_baseline(input, 3)

    # Manual calculation
    base_line + 4 + 80 + 2 + 800 + 600 + 200 + 2000 + 4 + 2 + 20
  end

  def calculate_baseline(input, depth)
    input.sum do |val|
      char, pos = val
      case char
      when 'A'
        steps(pos, [0, depth]) * 1
      when 'B'
        steps(pos, [2, depth]) * 10
      when 'C'
        steps(pos, [4, depth]) * 100
      when 'D'
        steps(pos, [6, depth]) * 1000
      end
    end - 1111 * (1..depth).reduce(&:+)
  end

  def steps(a, b)
    if a[0] == b[0]
      (b[1] - a[1]).abs
    else
      (a[0] - b[0]).abs + (b[1] + a[1] + 2)
    end
  end

  def parse(raw_input)
    raw_input
  end
end
