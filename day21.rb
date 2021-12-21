# frozen_string_literal: true

require './runner'
require 'set'

class QuantumDice
  DICE_POSSIBILITY = {
    3 => 1,
    4 => 3,
    5 => 6,
    6 => 7,
    7 => 6,
    8 => 3,
    9 => 1
  }.freeze

  def initialize(init_pos)
    @init_pos = init_pos
    @incomplete_seq = Set.new
    @completed_seq = Set.new
  end

  # Roll to the end of the multiple universes!
  def roll
    generate_sequences(@init_pos, 0, [])
    generate_possibility_tables
  end

  private

  def generate_sequences(pos, acc, curr_sequence)
    if acc >= 21
      @completed_seq << curr_sequence
      return
    end

    @incomplete_seq << curr_sequence

    (3..9).each do |roll_val|
      new_pos = move(pos, roll_val)
      generate_sequences(new_pos, acc + new_pos, curr_sequence.dup << roll_val)
    end
  end

  def generate_possibility_tables
    [@completed_seq, @incomplete_seq].map { |seq| possibility_table_for(seq) }
  end

  def possibility_table_for(seqs)
    seqs.each_with_object(Hash.new(0)) do |sequence, counts_table|
      seq_possibilities = sequence.reduce(1) do |acc, dice_val|
        possibility = DICE_POSSIBILITY[dice_val]
        raise "Ugh. dice_val is #{dice_val}" unless possibility

        acc * possibility
      end

      counts_table[sequence.count] += seq_possibilities
    end
  end

  def move(pos, val)
    (pos + val - 1) % 10 + 1
  end
end

class Day21 < Runner
  def do_puzzle2
    p1_complete, p1_incomplete = QuantumDice.new(6).roll
    p2_complete, p2_incomplete = QuantumDice.new(4).roll

    p1_winning_universes = p1_complete.sum do |step_count, universes|
      p2_incomplete[step_count - 1] * universes
    end
    p2_winning_universes = p2_complete.sum do |step_count, universes|
      p1_incomplete[step_count] * universes
    end

    [p1_winning_universes, p2_winning_universes].max
  end

  def do_puzzle1
    p1 = 6
    p2 = 4
    p1_score = 0
    p2_score = 0
    die_count = 0
    die = 1

    loop do
      die, val = roll_three_times(die)
      die_count += 3
      p1 = move(p1, val)
      p1_score += p1
      break if p1_score >= 1000

      die, val = roll_three_times(die)
      die_count += 3
      p2 = move(p2, val)
      p2_score += p2
      break if p2_score >= 1000
    end

    die_count * [p1_score, p2_score].min
  end

  def roll_three_times(die)
    case die
    when 100
      [3, 100 + 1 + 2]
    when 99
      [2, 99 + 100 + 1]
    when 98
      [1, 98 + 99 + 100]
    else
      [die + 3, 3 * die + 3]
    end
  end

  def move(pos, val)
    (pos + val - 1) % 10 + 1
  end

  # ===================================
  def parse(raw_input)
    raw_input
  end
end
