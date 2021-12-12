# frozen_string_literal: true

require './runner'

class Cave
  START = 'start'
  FINISH = 'end'

  def self.create(name)
    case name
    when START
      StartCave.new(name, [])
    when FINISH
      EndCave.new(name)
    when /^[[:upper:]]+$/
      BigCave.new(name, [])
    else
      SmallCave.new(name, [], false)
    end
  end

  def add_neighbor(_neighbor)
    raise "#{self.class} needs to implement :add_neighbor method"
  end

  def accessible?
    raise "#{self.class} needs to implement :accessible? method"
  end

  def visit
    raise "#{self.class} needs to implement :visit method"
  end
end

class SmallCave < Cave
  attr_reader :name, :neighbors, :is_visited

  def initialize(name, neighbors, is_visited)
    @name = name
    @neighbors = neighbors
    @is_visited = is_visited
  end

  def add_neighbor(neighbor)
    return self if neighbor == Cave::START

    self.class.new(name, neighbors << neighbor, is_visited)
  end

  def accessible?
    !is_visited
  end

  def visit
    self.class.new(name, neighbors, true)
  end
end

class BigCave < Cave
  attr_reader :name, :neighbors

  def initialize(name, neighbors)
    @name = name
    @neighbors = neighbors
  end

  def add_neighbor(neighbor)
    return self if neighbor == Cave::START

    self.class.new(name, neighbors << neighbor)
  end

  def accessible?
    true
  end

  def visit
    self
  end
end

class StartCave < Cave
  attr_reader :name, :neighbors

  def initialize(name, neighbors)
    @name = name
    @neighbors = neighbors
  end

  def add_neighbor(neighbor)
    self.class.new(name, neighbors << neighbor)
  end

  def accessible?
    false
  end
end

class EndCave < Cave
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def accessible?
    true
  end

  def add_neighbor(_)
    self
  end
end

class CaveMap
  def self.build(raw)
    cave_map = raw.each_with_object({}) do |pair, caves|
      left, right = pair
      left_cave = caves[left] || Cave.create(left)
      right_cave = caves[right] || Cave.create(right)
      caves[left] = left_cave.add_neighbor(right)
      caves[right] = right_cave.add_neighbor(left)
    end

    new(cave_map)
  end

  def initialize(caves)
    @caves = caves
  end

  def find_paths
    @caves[Cave::START].neighbors.sum { |name| explore(@caves[name], @caves.dup) }
  end

  def explore(cave, cave_map)
    return 1 if cave.is_a?(EndCave)
    return 0 unless cave.accessible?

    cave_map[cave.name] = cave.visit
    cave.neighbors.sum { |n_name| explore(cave_map.fetch(n_name), cave_map.dup) }
  end

  # One small cave gets to be visited twice.
  def find_paths_with_leisure
    @caves[Cave::START].neighbors.sum { |name| explore_with_leisure(@caves[name], @caves.dup, true) }
  end

  def explore_with_leisure(cave, cave_map, is_free)
    return 1 if cave.is_a?(EndCave)
    return 0 if !cave.accessible? && !is_free

    is_free = cave.accessible? ? is_free : false
    cave_map[cave.name] = cave.visit
    cave.neighbors.sum { |neighbor| explore_with_leisure(cave_map.fetch(neighbor), cave_map.dup, is_free) }
  end
end

# ===========================================
# Runner

class Day12 < Runner
  def do_puzzle1
    CaveMap.build(@input).find_paths
  end

  def do_puzzle2
    CaveMap.build(@input).find_paths_with_leisure
  end

  def parse(raw_input)
    raw_input.map { |row| row.split('-') }
  end
end
