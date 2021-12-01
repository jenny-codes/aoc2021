read_input = ->(file_path) { File.read(file_path).split().map(&:to_i) }

p1 = ->(input) { (1...(input.count)).count { |n| input[n-1] < input[n] } }
p2 = ->(input) { (3...(input.count)).count { |n| input[n-3] < input[n] } }

print_output = ->(output, label) { puts "#{label}: #{output}" }

input = read_input['data/day1.txt']

p1_result = p1[input]
p2_result = p2[input]

print_output[p1_result, 'Puzzle 1']
print_output[p2_result, 'Puzzle 2']
