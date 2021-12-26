# frozen_string_literal: true

require './runner'

EAST_CUCUMBER = '>'
SOUTH_CUCUMBER = 'v'
SPACE = '.'

Coord = Struct.new(:x, :y)

class Seafloor
  def initialize(seamap)
    @map = seamap
    @x_bound = seamap.keys.max_by(&:x).x
    @y_bound = seamap.keys.min_by(&:y).y
  end

  def steps_until_stabilize
    count = 1
    count += 1 while move == :cond
    count
  end

  def move
    r1 = move_east
    r2 = move_south
    r1.zero? && r2.zero? ? :nop : :cond
  end

  def move_east
    new_map = @map.dup
    count = @map
            .select { |_coord, t| t == EAST_CUCUMBER }
            .map { |coord, ccb| update_map(new_map, coord, east_of(coord), ccb) }
            .sum
    @map = new_map
    count
  end

  def move_south
    new_map = @map.dup
    count = @map
            .select { |_coord, t| t == SOUTH_CUCUMBER }
            .map { |coord, ccb| update_map(new_map, coord, south_of(coord), ccb) }
            .sum
    @map = new_map
    count
  end

  def update_map(new_map, coord, new_coord, ccb)
    if @map[new_coord] == SPACE
      new_map[new_coord] = ccb
      new_map[coord] = SPACE
      1
    else
      0
    end
  end

  def east_of(coord)
    if coord.x == @x_bound
      Coord.new(0, coord.y)
    else
      Coord.new(coord.x + 1, coord.y)
    end
  end

  def south_of(coord)
    if coord.y == @y_bound
      Coord.new(coord.x, 0)
    else
      Coord.new(coord.x, coord.y - 1)
    end
  end

  def inspect
    "\n" + (@y_bound..0).to_a.reverse.map do |y_idx|
      (0..@x_bound).map do |x_idx|
        @map[Coord.new(x_idx, y_idx)]
      end.join
    end.join("\n")
  end
end

class Day25 < Runner
  def do_puzzle1
    Seafloor.new(@input).steps_until_stabilize
  end

  def do_puzzle2
    'Merry Christmas!'
  end

  def parse(raw_input)
    seamap = {}
    raw_input.each_with_index do |row, y_idx|
      row.split('').each_with_index do |val, x_idx|
        seamap[Coord.new(x_idx, -y_idx)] = val
      end
    end
    seamap
  end
end
