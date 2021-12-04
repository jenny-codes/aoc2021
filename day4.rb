# frozen_string_literal: true

require './lib/pipe'

class Board
  attr_reader :unmarked_nums

  def initialize(raw)
    @data = {}
    @unmarked_nums = []
    @marked_positions = []

    raw.each_with_index do |row, y_idx|
      row.each_with_index do |num, x_idx|
        @data[num] = [x_idx, y_idx]
        @unmarked_nums << num
      end
    end
  end

  def mark_and_check(num)
    return false unless @data[num]

    @marked_positions << @data[num]
    @unmarked_nums.delete(num)

    bingo?
  end

  def bingo?
    @marked_positions.map(&:first).tally.values.include?(5) ||
      @marked_positions.map(&:last).tally.values.include?(5)
  end
end

# ===========================================
# Main functions

format_answer = ->(bingo_board, bingo_num) {
  bingo_board.unmarked_nums.map(&:to_i).sum * bingo_num.to_i
}

do_puzzle1 = ->(input) {
  numbers, boards = input

  numbers.each do |num|
    boards.each do |board|
      is_bingo = board.mark_and_check(num)

      return format_answer.(board, num) if is_bingo
    end
  end
}

do_puzzle2 = ->(input) {
  numbers, remaining_boards = input

  numbers.each do |num|
    to_delete = remaining_boards.map do |board|
      is_bingo = board.mark_and_check(num)
      next unless is_bingo
      return format_answer.(board, num) if remaining_boards.count == 1

      board
    end.compact
    remaining_boards -= to_delete
  end
}

# ===========================================
# Adapter

parse = ->(input) {
  numbers = input.shift.split(',')

  raw_boards = input.reduce([]) do |memo, row|
    if row.empty?
      memo << []
    else
      memo.last << row.split(' ')
      memo
    end
  end

  boards = raw_boards.map { |b| Board.new(b) }
  [numbers, boards]
}

# ===========================================
# IO Utils

read_input = ->(file_path) {
  File.readlines(file_path).map(&:strip)
}

print_output = ->(label) { ->(output) { puts "#{label}: #{output}" } }

# ===========================================
# Execution

Pipe['data/day4.txt'][read_input][parse][do_puzzle1][print_output['puzzle 1']].run
Pipe['data/day4.txt'][read_input][parse][do_puzzle2][print_output['puzzle 2']].run
