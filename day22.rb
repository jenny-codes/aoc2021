# frozen_string_literal: true

require './runner'

Cuboid = Struct.new(:x_range, :y_range, :z_range) do
  def initialize(*args)
    raise "Nil detected in #{args}" if args.any?(&:nil?)
    raise "Invalid range detected in #{args}" if args.any? { _1.begin > _1.end }

    super(*args)
  end

  def intersection(other)
    ix = ([x_range.min, other.x_range.min].max)..([x_range.max, other.x_range.max].min)
    return if ix.begin > ix.end

    iy = ([y_range.min, other.y_range.min].max)..([y_range.max, other.y_range.max].min)
    return if iy.begin > iy.end

    iz = ([z_range.min, other.z_range.min].max)..([z_range.max, other.z_range.max].min)
    return if iz.begin > iz.end

    self.class.new(ix, iy, iz)
  end

  def cubes_count
    x_range.count * y_range.count * z_range.count
  end
end

Reactor = Struct.new(:cubes_count) do
  def initialize
    super(0)
  end

  def reboot(instructions)
    memo = [[]]
    instructions.each { memo = execute(*_1, memo) }
    self
  end

  private

  def execute(on_off, cuboid, memo)
    case on_off
    when 'on'
      turn_on(cuboid, memo)
    when 'off'
      turn_off(cuboid, memo)
    else
      raise "Instruction #{on_off} is weird."
    end
  end

  def turn_on(cuboid, memo)
    self.cubes_count += cuboid.cubes_count
    new_memo = adjust_layers(cuboid, memo)
    new_memo[0] << cuboid
    new_memo
  end

  def turn_off(cuboid, memo)
    adjust_layers(cuboid, memo)
  end

  def adjust_layers(cuboid, memo)
    new_memo = deep_dup(memo)
    memo.each_with_index do |cbs, idx|
      cp_cuboids = cbs.filter_map { |cb| cb.intersection(cuboid) }
      break new_memo unless cp_cuboids

      if idx.even?
        self.cubes_count -= cp_cuboids.sum(&:cubes_count)
      else
        self.cubes_count += cp_cuboids.sum(&:cubes_count)
      end

      new_memo[idx + 1] ? new_memo[idx + 1] += cp_cuboids : new_memo[idx + 1] = cp_cuboids
    end
    new_memo
  end

  def deep_dup(arr)
    new_arr = []
    arr.each { new_arr << _1.dup }
    new_arr
  end
end

class Day22 < Runner
  def do_puzzle1
    instructions = @input.select { _1[1].x_range.min >= -50 && _1[1].x_range.max <= 50 }
    Reactor.new.reboot(instructions).cubes_count
  end

  def do_puzzle2
    instructions = @input
    Reactor.new.reboot(instructions).cubes_count
  end

  def parse(raw_input)
    raw_input.map { parse_line(_1) }
  end

  def parse_line(line)
    result = /^(on|off) x=(-*\d+)..(-*\d+),y=(-*\d+)..(-*\d+),z=(-*\d+)..(-*\d+)/.match(line)[1..-1]
    inst = result.first
    ranges = result[1..-1].map(&:to_i)
    [inst, Cuboid.new(ranges[0]..ranges[1], ranges[2]..ranges[3], ranges[4]..ranges[5])]
  end
end
