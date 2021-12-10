# frozen_string_literal: true

require './runner'

class SyntaxChecker
  CHUNKS = {
    '(' => ')',
    '[' => ']',
    '{' => '}',
    '<' => '>'
  }

  def self.find_corrupted(chars)
    chars.each_with_object([]) do |char, memo|
      next memo << char if CHUNKS.keys.include?(char)
      return char unless CHUNKS[memo.pop] == char
    end

    nil
  end

  def self.ckeck_incomplete(chars)
    result = chars.each_with_object([]) do |char, memo|
      next memo << char if CHUNKS.keys.include?(char)
      return nil unless CHUNKS[memo.pop] == char
    end

    result.map { |open| CHUNKS[open] }.reverse
  end
end

# ===========================================
# Runner

class Day10 < Runner
  def do_puzzle1
    points = {
      ')' => 3,
      ']' => 57,
      '}' => 1197,
      '>' => 25_137
    }

    @input
      .filter_map { |line| SyntaxChecker.find_corrupted(line) }
      .sum { |error| points[error] }
  end

  def do_puzzle2
    points = {
      ')' => 1,
      ']' => 2,
      '}' => 3,
      '>' => 4
    }

    count_points = ->(chars) {
      chars.reduce(0) do |memo, char|
        memo * 5 + points[char]
      end
    }

    @input
      .filter_map { |line| SyntaxChecker.ckeck_incomplete(line) }
      .map(&count_points)
      .sort
      .then { |ordered_points| ordered_points[ordered_points.count / 2] }
  end

  def parse(raw_input)
    raw_input.map { |line| line.split('') }
  end
end
