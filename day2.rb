# =========================
# Main funs

Vector = Struct.new(:x, :y) do
  def +(other)
    Vector.new(x + other.x, y + other.y)
  end
end

VectorWithAim = Struct.new(:vector, :aim) do
  def +(other)
    VectorWithAim.new(vector + other.vector, aim + other.aim)
  end
end

build_vector = ->(instruction:, value:) {
  case instruction
  when 'up'
    Vector.new(0, -value)
  when 'down'
    Vector.new(0, value)
  when 'forward'
    Vector.new(value, 0)
  else
    raise 'Invalid value'
  end
}

build_vector_with_aim = ->(aim, instruction:, value:) {
  case instruction
  when 'up'
    VectorWithAim.new(Vector.new(0, 0), -value)
  when 'down'
    VectorWithAim.new(Vector.new(0, 0), value)
  when 'forward'
    VectorWithAim.new(Vector.new(value, value * aim), 0)
  else
    raise 'Invalueid value'
  end
}

puzzle1 = ->(input) {
  position = input.reduce(Vector.new(0, 0)) { |vec, command| vec + build_vector.(**command) }
  position.x * position.y
}

puzzle2 = ->(input) {
  vector_with_aim = input.reduce(VectorWithAim.new(Vector.new(0, 0), 0)) do |vwa, command|
    vwa + build_vector_with_aim.(vwa.aim, **command)
  end
  vector_with_aim.vector.x * vector_with_aim.vector.y
}

# =========================
# IO Utils

read_input = ->(file_path) {
  File.read(file_path).split("\n").map do |command|
    instruction, value = command.strip.split(' ')
    value = value.to_i
    { instruction: instruction, value: value }
  end
}

print_output = ->(output, label) { puts "#{label}: #{output}" }

# =========================
# Execution

input = read_input['data/day2.txt']
print_output[puzzle1[input], 'Puzzle 1']
print_output[puzzle2[input], 'Puzzle 2']
