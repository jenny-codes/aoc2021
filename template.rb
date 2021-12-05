# frozen_string_literal: true

require './lib/pipe'

# ===========================================
# Main functions

do_puzzle1 = ->(input) {
  input
}

do_puzzle2 = ->(_input) {
  'Not yet implemented'
}

# ===========================================
# Adapter

parse = ->(input) {
  input
}

# ===========================================
# IO Utils

read_input = ->(file_path) {
  File.readlines(file_path).map(&:strip)
}

print_output = ->(label) { ->(output) { puts "#{label}: #{output}" } }

# ===========================================
# Execution

Pipe['data/day[NUM].txt'][read_input][parse][do_puzzle1][print_output['puzzle 1']].run
Pipe['data/day[NUM].txt'][read_input][parse][do_puzzle2][print_output['puzzle 2']].run
