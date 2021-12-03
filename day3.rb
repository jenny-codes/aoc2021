require './lib/pipe'

# ===========================================
# Helper functions

bit_array_to_num = ->(bit_array) {
  bit_array.join.to_i(2)
}

reverse_bits = ->(bits) { bits.map { |i| i == '1' ? '0' : '1' } }

# ===========================================
# Main functions

do_puzzle1 = ->(input) {
  data = input.map { |x| x.split('') }

  gemma_bits = (0...(data.first.count)).map do |idx|
    data
      .map { |row| row[idx] }
      .tally
      .max_by { |_k, v| v }
      .first
  end

  epsilon_bits = reverse_bits.(gemma_bits)

  bit_array_to_num.(gemma_bits) * bit_array_to_num.(epsilon_bits)
}

do_puzzle2 = ->(input) {
  data = input.map { |x| x.split('') }

  oxygen = (0...(data.first.count)).reduce(data) do |memo, idx|
    break memo[0] if memo.count == 1

    tally = memo.map { |row| row[idx] }.tally
    selector = tally['1'] >= tally['0'] ? '1' : '0'
    memo.select { |row| row[idx] == selector }
  end

  co2 = (0...(data.first.count)).reduce(data) do |memo, idx|
    break memo[0] if memo.count == 1

    tally = memo.map { |row| row[idx] }.tally
    selector = tally['1'] < tally['0'] ? '1' : '0'
    memo.select { |row| row[idx] == selector }
  end

  bit_array_to_num.(oxygen) * bit_array_to_num.(co2)
}

# ===========================================
# IO Utils

read_input = ->(file_path) {
  File.readlines(file_path).map(&:strip)
}

print_output = ->(label) { ->(output) { puts "#{label}: #{output}" } }

# ===========================================
# Execution

Pipe['data/day3.txt'][read_input][do_puzzle1][print_output['puzzle 1']].run
Pipe['data/day3.txt'][read_input][do_puzzle2][print_output['puzzle 2']].run
