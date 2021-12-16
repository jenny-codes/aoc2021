# frozen_string_literal: true

require './runner'

MAX_INT = (2**(0.size * 8 - 2) - 1)

Node = Struct.new(:value, :acc)

# Didn't end up using this struct. May revisist once I figure out where the performance bottleneck is.
# Point = Struct.new(:x, :y) do
#   def neighbors
#     [
#       Point.new(x - 1, y),
#       Point.new(x + 1, y),
#       Point.new(x, y - 1),
#       Point.new(x, y + 1)
#     ]
#   end
# end

Board = Struct.new(:nodes) do
  def update(current_node, next_node, next_point)
    new_next_node = Node.new(next_node.value, [next_node.acc, current_node.acc + next_node.value].min)
    nodes[next_point] = new_next_node
  end

  def delete(point)
    raise "Cannot find #{point} in nodes. Perhaps your brain does not work?" unless nodes[point]

    nodes.delete(point)
    self
  end

  def x_bound
    nodes.keys.max_by { |p| p[0] }[0]
  end

  def y_bound
    nodes.keys.max_by { |p| p[1] }[1]
  end

  def valid_neighbors_for(point)
    x, y = point
    [
      [x - 1, y],
      [x + 1, y],
      [x, y - 1],
      [x, y + 1]
    ].filter_map do |p|
      node = nodes[p]
      [p, node] if node
    end
  end

  def min_by_acc
    nodes.min_by { |_point, node| node.acc }
  end

  def debug_print_first_column
    puts nodes.select { |key, _node| key[0] == 0 }
              .sort_by { |key, _node| key[1] }
              .map { |_key, node| node.value }.inspect
  end
end

class Day15 < Runner
  def do_puzzle1
    board = Board.new(@input)
    starting_pos = [0, 0]

    target = [board.x_bound, board.y_bound]
    find_shortest_path(board.delete(starting_pos), starting_pos, Node.new(0, 0), target)
  end

  def do_puzzle2
    board = Board.new(make_it_scarier(@input))
    starting_pos = [0, 0]
    target = [board.x_bound, board.y_bound]
    find_shortest_path(board.delete(starting_pos), starting_pos, Node.new(0, 0), target)
  end

  # Implementing Dijkstra algorithm
  def find_shortest_path(remaining_board, current_point, current_node, target)
    until current_point == target
      puts remaining_board.nodes.count
      remaining_board.valid_neighbors_for(current_point).each do |point_node|
        next_point, next_node = point_node
        remaining_board.update(current_node, next_node, next_point)
      end

      current_point, current_node = remaining_board.min_by_acc
      remaining_board.delete(current_point)
    end
    current_node.acc
  end

  def make_it_scarier(board)
    x_offset_val = 100
    y_offset_val = 100
    (0..4).flat_map do |x_offset|
      (0..4).map do |y_offset|
        board.each_with_object({}) do |point_node, offset_board|
          point, node = point_node
          new_value = node.value + x_offset + y_offset
          new_value -= 9 if new_value > 9
          new_node = Node.new(new_value, node.acc)
          x, y = point
          new_point = [x + x_offset * x_offset_val, y + y_offset * y_offset_val]
          offset_board[new_point] = new_node
        end
      end
    end.reduce(&:merge)
  end

  def parse(raw_input)
    raw_input.each_with_index.each_with_object({}) do |row, board|
      y, y_idx = row
      y.split('').each_with_index do |val, x_idx|
        raise "One of #{x_idx}, #{y_idx}, #{val} is nil" unless val && x_idx && y_idx

        board[[x_idx, y_idx]] = Node.new(val.to_i, MAX_INT)
      end
      board
    end
  end
end
