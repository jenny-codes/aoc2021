# frozen_string_literal: true

require './lib/pipe'
require './runner'
require 'set'

ThreeDim = Struct.new(:x, :y, :z) do
  def +(other)
    self.class.new(x + other.x, y + other.y, z + other.z)
  end

  def -(other)
    self.class.new(x - other.x, y - other.y, z - other.z)
  end

  def manhattan_distance
    x.abs + y.abs + z.abs
  end

  # Not by formal definition. Only used for comparison
  def informal_distance_from(other)
    (x - other.x)**2 + (y - other.y)**2 + (z - other.z)**2
  end

  # To avoid ambiguous situation that might lead to wrong intepretation
  def good_compare_candidate?
    [x.abs, y.abs, z.abs].uniq.count == 3
  end
end

Beacon = ThreeDim

Vector = ThreeDim
def Vector.from(start, dest)
  new(dest.x - start.x, dest.y - start.y, dest.z - start.z)
end

class Scanner
  attr_reader :id, :beacons

  def initialize(id, beacons = nil)
    @id = id
    @beacons = Array(beacons)
  end

  def add_beacon(beacon)
    @beacons << beacon
  end

  def generate_distances
    distances = {}
    @beacons.each do |b1|
      @beacons.each do |b2|
        next if b1 == b2

        distance = b1.informal_distance_from(b2)
        distances[distance] = [b1, b2]
      end
    end
    distances
  end
end

Mapper = Struct.new(:mapping) do
  class << self
    def for(scanners)
      find_overlapping_pairs(scanners).map { |pair| build_mapping(*pair) }
    end

    def find_overlapping_pairs(scanners)
      distances = scanners.each_with_object({}) do |scanner, memo|
        memo[scanner] = scanner.generate_distances
        memo
      end

      threshold = 12.times.map { _1 }.combination(2).count

      distances.to_a.combination(2).each_with_object([]) do |com, memo|
        d1, d2 = com
        scanner1, ds1 = d1
        scanner2, ds2 = d2

        distance_overlap = (ds1.keys & ds2.keys)
        memo << [scanner1, scanner2, distance_overlap] if distance_overlap.count >= threshold
      end
    end

    # Align the scanner with other_id with that of base_id
    def build_mapping(base_scanner, other_scanner, distance_overlap)
      bs_lookup =
        base_scanner
        .generate_distances
        .each_with_object(Hash.new { |h, k| h[k] = Set.new }) do |dis_and_bs, lookup|
          distance, beacons = dis_and_bs
          next lookup unless distance_overlap.include?(distance)

          b1, b2 = beacons
          lookup[b1] << distance
          lookup[b2] << distance
          lookup
        end

      os_lookup =
        other_scanner
        .generate_distances
        .each_with_object(Hash.new { |h, k| h[k] = Set.new }) do |dis_and_bs, lookup|
          distance, beacons = dis_and_bs
          next lookup unless distance_overlap.include?(distance)

          b1, b2 = beacons
          lookup[b1] << distance
          lookup[b2] << distance
          lookup
        end

      mapping = bs_lookup.map do |base_beacon, diss|
        other_beacon = os_lookup.key(diss)
        raise "No such value in os_lookup. Value: #{diss}" unless other_beacon

        [base_beacon, other_beacon]
      end

      [[base_scanner.id, other_scanner.id], mapping]
    end
  end
end

Transformer = Struct.new(:transformers) do
  class << self
    def for(mapping)
      relative_tmrs = mapping.each_with_object({}) do |ids_mapping, memo|
        id_pair, mapping = ids_mapping
        memo[id_pair] = build_pair_transformers(mapping)

        # build for reverse mapping too
        reverse_id_pair = id_pair.reverse
        reverse_mapping = mapping.map(&:reverse)
        memo[reverse_id_pair] = build_pair_transformers(reverse_mapping)
      end
      absolute_tmrs = build_absolute_paths_from(relative_tmrs)
      new(absolute_tmrs)
    end

    def build_pair_transformers(mapping)
      i = 0 # The value is not significant.
      while true
        com1, com2 = mapping[i..(i + 1)]
        from_b1, to_b1 = com1
        from_b2, to_b2 = com2
        base_vec = Vector.from(to_b1, to_b2)
        next i += 1 unless base_vec.good_compare_candidate?

        other_vec = Vector.from(from_b1, from_b2)

        reorient = ->(beacon) {
          new_x = calculate_vec_diff(beacon, base_vec.x, other_vec)
          new_y = calculate_vec_diff(beacon, base_vec.y, other_vec)
          new_z = calculate_vec_diff(beacon, base_vec.z, other_vec)

          Beacon.new(new_x, new_y, new_z)
        }

        reoriented1 = reorient.(from_b1)
        offset_vector = Vector.from(reoriented1, to_b1)

        reoriented_and_offset = ->(beacon) {
          reorient.call(beacon) + offset_vector
        }
        break reoriented_and_offset
      end
    end

    def build_absolute_paths_from(pair_tmrs)
      scanners_count = pair_tmrs.keys.flatten.uniq.count
      tunnels_for(pair_tmrs.keys, scanners_count).each_with_object({}) do |id_path, memo|
        id, paths = id_path
        pipes = paths.each_cons(2).reduce(Pipe) do |pipe, pair|
          pipe[pair_tmrs[pair]]
        end

        final_pipe = ->(x) { pipes.run(x) }
        memo[id] = final_pipe
      end
    end

    def tunnels_for(input, goal_count)
      result = { 0 => [] }

      input.select { |pair| pair[1] == 0 }.each { |pair| result[pair[0]] = pair }
      input = input.reject { |pair| pair[1] == 0 }

      while result.count < goal_count
        establisbed = result.keys
        workables = input.select { |pair| establisbed.include?(pair[1]) }
        workables.each { |pair| result[pair[0]] ||= ([pair[0]] + result[pair[1]].dup) }
        input -= workables
      end

      result
    end

    def calculate_vec_diff(beacon, base_val, vec)
      if base_val.abs == vec.x.abs
        if base_val == vec.x
          beacon.x
        else
          -beacon.x
        end
      elsif base_val.abs == vec.y.abs
        if base_val == vec.y
          beacon.y
        else
          -beacon.y
        end
      elsif base_val.abs == vec.z.abs
        if base_val == vec.z
          beacon.z
        else
          -beacon.z
        end
      end
    end
  end

  def transform(scanner)
    tmr = transformers[scanner.id]
    new_beacons = scanner.beacons.map { |b| tmr.call(b) }
    Scanner.new(scanner.id, new_beacons)
  end
end

class Day19 < Runner
  def do_puzzle1
    scanners = @input
    mapping = Mapper.for(scanners)

    tmr = Transformer.for(mapping)
    scanners
      .flat_map { |scanner| tmr.transform(scanner).beacons }
      .uniq
      .count
  end

  def do_puzzle2
    scanners = @input
    mapping = Mapper.for(scanners)
    tmr = Transformer.for(mapping)
    tmr.transformers.map { |_id, fun| fun.call(Vector.new(0, 0, 0)) }.combination(2).reduce(0) do |max, pair|
      m_distance = (pair[0] - pair[1]).manhattan_distance
      [max, m_distance].max
    end
  end

  def parse(raw_input)
    raw_input.each_with_object([]) do |line, scanners|
      new_scanner_match = /--- scanner (\d+)/.match(line)
      if new_scanner_match
        scanners << Scanner.new(new_scanner_match[1].to_i)
      elsif line.empty?
        next
      else
        beacon = Beacon.new(*line.split(',').map(&:to_i))
        scanners.last.add_beacon(beacon)
      end
    end
  end
end
