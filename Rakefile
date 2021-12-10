# frozen_string_literal: true

task default: %w[run]

# =========================================
# Helper functions

def fetch_runner(source_code_path)
  filename = /day\d*/.match(source_code_path)[0]
  Object.const_get(filename.capitalize)
end

def read_input(source_code_path)
  require "./#{source_code_path}"

  filename = /day\d*/.match(source_code_path)[0]
  input_path = "data/#{filename}.txt"
  File.readlines(input_path).map(&:strip)
end

def print_output(label, output)
  puts "#{label}: #{output}"
end

# =========================================
# Main tasks

desc 'Run the code for the day'
task :run, [:source_code_path] do |_t, args|
  raw_input = read_input(args.source_code_path)
  runner = fetch_runner(args.source_code_path).new(raw_input)

  output1 = runner.do_puzzle1
  output2 = runner.do_puzzle2

  print_output('puzzle 1', output1)
  print_output('puzzle 2', output2)
end

desc 'Setup files for the day. Need AOC_SESSION_TOKEN env var.'
task :create, [:day] do |_t, args|
  token = ENV.fetch('AOC_SESSION_TOKEN')

  # If one doesn't already exist, create a source code file
  source_code_path = "day#{args.day}.rb"
  `sed s/NUMBER/#{args.day}/ template.rb > #{source_code_path}` unless File.exist?(source_code_path)

  # Create a new input file
  input_path = "data/day#{args.day}.txt"
  `curl --header 'cookie: session=#{token}' -o #{input_path} https://adventofcode.com/2021/day/#{args.day}/input`

  puts "Generated files for day #{args.day} 🧑‍🎄"
end
