# frozen_string_literal: true

require './runner'

# Dijkstra Algorithm
# https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm#Practical_optimizations_and_infinite_graphs
# TODO: Use Priority Queue

Node = Struct.new(:val, :acc)

Position = Struct.new(:x, :y) do
  def neighbors
    [
      [x - 1, y], [x + 1, y], [x, y - 1], [x, y + 1]
    ].map { Position.new(*_1) }
  end
end

class DijkstraForGrid
  def initialize(grid, start, target)
    @grid = grid.transform_keys { |k| Position.new(*k) }
    @start = Position.new(*start)
    @target = Position.new(*target)
  end

  def call
    find_shortest_path(@grid, {}, @start, Node.new(0, 0))
  end

  def find_shortest_path(grid, queue, curr_pos, curr_node)
    until curr_pos == @target
      update_neighbors(grid, queue, curr_pos, curr_node)
      queue.delete(curr_pos)
      curr_pos, curr_node = queue.min_by { |_p, n| n.acc }
    end
    curr_node.acc
  end

  def update_neighbors(grid, queue, curr_pos, curr_node)
    curr_pos.neighbors.each do |neighbor_pos|
      neighbor_node = queue.delete(neighbor_pos)
      if neighbor_node
        udpated_val = [neighbor_node.acc, curr_node.acc + neighbor_node.val].min
        queue[neighbor_pos] = Node.new(neighbor_node.val, udpated_val)
        next
      end

      neighbor_val = grid.delete(neighbor_pos)
      if neighbor_val
        acc_val = curr_node.acc + neighbor_val
        queue[neighbor_pos] = Node.new(neighbor_val, acc_val)
      end
    end
  end
end

class Day15 < Runner
  def do_puzzle1
    target = [
      @input.keys.max_by { _1[0] }[0],
      @input.keys.max_by { _1[1] }[1]
    ]

    DijkstraForGrid.new(@input, [0, 0], target).call
  end

  def do_puzzle2
    bigger_input = make_it_scarier(@input)
    target = [
      bigger_input.keys.max_by { _1[0] }[0],
      bigger_input.keys.max_by { _1[1] }[1]
    ]

    DijkstraForGrid.new(bigger_input, [0, 0], target).call
  end

  def make_it_scarier(input)
    x_offset_val = 100
    y_offset_val = 100
    (0..4).flat_map do |x_offset|
      (0..4).map do |y_offset|
        input.each_with_object({}) do |pos_val, result|
          pos, val = pos_val
          new_val = val + x_offset + y_offset
          new_val -= 9 if new_val > 9
          x, y = pos
          new_pos = [x + x_offset * x_offset_val, y + y_offset * y_offset_val]
          result[new_pos] = new_val
        end
      end
    end.reduce(&:merge)
  end

  def parse(raw_input)
    raw_input.each_with_index.each_with_object({}) do |row, board|
      y, y_idx = row
      y.split('').each_with_index do |val, x_idx|
        raise "One of #{x_idx}, #{y_idx}, #{val} is nil" unless val && x_idx && y_idx

        board[[x_idx, y_idx]] = val.to_i
      end
      board
    end
  end
end
