# frozen_string_literal: true

require './runner'

class Day14 < Runner
  def do_puzzle1
    template, rules = @input
    add_new_elements(
      rules,
      template.each_cons(2).tally,
      template.tally,
      10
    ).map { |v| v[1] }.minmax.reduce(:-).abs
  end

  def do_puzzle2
    template, rules = @input
    add_new_elements(
      rules,
      template.each_cons(2).tally,
      template.tally,
      40
    ).map { |v| v[1] }.minmax.reduce(:-).abs
  end

  def add_new_elements(rules, pairs, result, countdown)
    return result if countdown.zero?

    new_pairs = pairs.each_with_object(Hash.new(0)) do |value, memo|
      pair, count = value
      element = rules[pair]
      result[element] ? result[element] += count : result[element] = count

      memo[[pair.first, element]] += count
      memo[[element, pair.last]] += count
    end

    add_new_elements(rules, new_pairs, result, countdown - 1)
  end

  def parse(raw_input)
    template = raw_input.shift.split('')
    raw_input.shift
    rules = raw_input.each_with_object({}) do |row, memo|
      cond, target = row.split(' -> ')
      memo[cond.split('')] = target
    end
    [template, rules]
  end
end
