# frozen_string_literal: true

require './runner'
require 'set'

class Pattern
  def initialize(code_sets)
    code_to_digit = {}

    code_sets.each do |code|
      case code.length
      when 2
        code_to_digit[code] = 1
      when 3
        code_to_digit[code] = 7
      when 4
        code_to_digit[code] = 4
      when 7
        code_to_digit[code] = 8
      end
    end

    char_distribution = code_sets.map(&:to_a).flatten { |s| s.split('') }.tally

    code_for_nine = code_sets.find { |c| c.length == 6 && !c.include?(char_distribution.key(4)) }
    code_to_digit[code_for_nine] = 9

    code_for_two = code_sets.find { |c| c.length == 5 && !c.include?(char_distribution.key(9)) }
    code_to_digit[code_for_two] = 2

    code_for_three = (code_sets - code_to_digit.keys).find { |c| !c.include?(char_distribution.key(6)) }
    code_to_digit[code_for_three] = 3

    code_for_five = (code_sets - code_to_digit.keys).find { |c| c.length == 5 }
    code_to_digit[code_for_five] = 5

    code_for_zero = (code_sets - code_to_digit.keys).find do |c|
      code_to_digit.key(1).all? { |digit| c.include?(digit) }
    end
    code_to_digit[code_for_zero] = 0

    code_for_six = (code_sets - code_to_digit.keys).first
    code_to_digit[code_for_six] = 6

    @mapping = code_to_digit
  end

  def match(input_codes)
    input_codes.map { |c| @mapping[c] }.join.to_i
  end
end

# ===========================================
# Runner

class Day8 < Runner
  def do_puzzle1
    @input.flat_map { |row| row.split(' | ').last.split(' ') }
          .count { |word| [2, 3, 4, 7].include?(word.length) }
  end

  def do_puzzle2
    @input.sum do |row|
      pattern, input = row.split(' | ').map { |s| s.split(' ').map { |code| Set.new(code.split('')) } }
      Pattern.new(pattern).match(input)
    end
  end

  def parse(raw_input)
    raw_input
  end
end
