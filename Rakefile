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

task :run, [:source_code_path] do |_t, args|
  raw_input = read_input(args.source_code_path)
  runner = fetch_runner(args.source_code_path).new(raw_input)

  output1 = runner.do_puzzle1
  output2 = runner.do_puzzle2

  print_output('puzzle 1', output1)
  print_output('puzzle 2', output2)
end

task :create, [:day] do |_t, args|
  name = "day#{args.day}"

  # Create new source code file
  `sed s/NUMBER/#{args.day}/ template.rb > #{name}.rb`

  # Create new input file
  FileUtils.touch("./data/#{name}.txt")

  puts "Generated files for #{name} 🧑‍🎄"
end
