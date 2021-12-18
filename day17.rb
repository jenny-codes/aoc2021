# frozen_string_literal: true

require './runner'

TargetArea = Struct.new(:x_min, :x_max, :y_min, :y_max)

class CalculateAllValidInitVelocity
  def initialize(target_area)
    @target = target_area
  end

  def call
    minmax = x_minmax_init_velocity
    x_steps = find_possible_steps_for_init_velocity(minmax)
    y_steps_lookup = y_steps_to_possible_init_velocity_lookup
    x_steps.filter_map do |_x_vel, step_range|
      y_vels = step_range.flat_map { |s| y_steps_lookup[s] }.compact.uniq

      y_vels.count if y_vels.any?
    end.sum
  end

  def x_minmax_init_velocity
    min = 1
    min += 1 while (0..min).sum < @target.x_min
    max = @target.x_max
    [min, max]
  end

  def find_possible_steps_for_init_velocity(minmax)
    (minmax[0]..minmax[1]).each_with_object({}) do |velocity, memo|
      possible_steps = x_possible_steps_for_init_velocity(velocity)
      memo[velocity] = possible_steps if possible_steps
    end
  end

  def x_possible_steps_for_init_velocity(v)
    result = []
    pos = 0
    steps = 0
    while pos <= @target.x_max && v > 0
      result << steps if pos >= @target.x_min
      pos += v
      v -= 1 if v > 0
      steps += 1
    end

    max_y_steps = 2 * @target.y_min.abs
    result << max_y_steps if v.zero? && pos >= @target.x_min

    (result.min)..(result.max) if result.any?
  end

  def y_possible_init_velocities_for_step(n)
    # y needs to satisfy y_target_min <= n * y - fact(n-1) <= y_target_max
    result = []
    normalized_min = ((@target.y_min + factorial_for(n - 1)).to_f / n).ceil
    normalized_max = ((@target.y_max + factorial_for(n - 1)).to_f / n).floor
    (normalized_min..normalized_max).each do |v|
      result << v
    end
    result
  end

  # Produces a lookup that maps each step to possible velocity
  # Given a step, how many possible init velocity value can get
  # to the target zone?
  def y_steps_to_possible_init_velocity_lookup
    max_step = 2 * @target.y_min.abs
    (1..max_step).each_with_object({}) do |step, memo|
      possible_v_list = y_possible_init_velocities_for_step(step)
      memo[step] = possible_v_list if possible_v_list.any?
    end
  end

  def factorial_for(n)
    return 0 if n.zero?

    n * (n + 1) / 2
  end
end

class Day17 < Runner
  def do_puzzle1
    target = TargetArea.new(*@input)
    farest_y = target.y_min.abs
    farest_y * (farest_y - 1) / 2
  end

  def do_puzzle2
    target = TargetArea.new(*@input)
    CalculateAllValidInitVelocity.new(target).call
  end

  def parse(raw_input)
    /x=(\d+)\.\.(\d+).*y=(-\d+).*(-\d+)/.match(raw_input[0])[1..-1].map(&:to_i)
  end
end
