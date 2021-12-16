# frozen_string_literal: true

require './runner'

Node = Struct.new(:value, :acc)

Board = Struct.new(:nodes, :queue) do
  def update_neighbors(current_point, current_node)
    x, y = current_point
    [
      [x - 1, y],
      [x + 1, y],
      [x, y - 1],
      [x, y + 1]
    ].filter_map do |p|
      existing_node = queue[p]
      if existing_node
        queue[p] = Node.new(existing_node.value,
                            [existing_node.acc, current_node.acc + existing_node.value].min)
      elsif nodes.key?(p)
        new_node = nodes.delete(p)
        queue[p] = Node.new(new_node.value,
                            current_node.acc + new_node.value)
      end
    end
  end

  def delete(point)
    node = queue.delete(point)
    raise "Cannot find #{point} in queue. Perhaps your brain does not work?" unless node

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
    queue.min_by { |_point, node| node.acc }
  end

  def debug_print_first_column
    puts nodes.select { |key, _node| key[0] == 0 }
              .sort_by { |key, _node| key[1] }
              .map { |_key, node| node.value }.inspect
  end
end

class Day15 < Runner
  def do_puzzle1
    board = Board.new(@input, {})
    starting_pos = [0, 0]
    starting_node = Node.new(0, 0)
    target = [board.x_bound, board.y_bound]

    find_shortest_path(board, starting_pos, starting_node, target)
  end

  def do_puzzle2
    board = Board.new(make_it_scarier(@input), {})
    starting_pos = [0, 0]
    starting_node = Node.new(0, 0)
    target = [board.x_bound, board.y_bound]

    find_shortest_path(board, starting_pos, starting_node, target)
  end

  # Implementing Dijkstra algorithm
  # https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm#Practical_optimizations_and_infinite_graphs
  def find_shortest_path(board, current_point, current_node, target)
    until current_point == target
      board.update_neighbors(current_point, current_node)
      current_point, current_node = board.min_by_acc
      board.delete(current_point)
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

        board[[x_idx, y_idx]] = Node.new(val.to_i, nil)
      end
      board
    end
  end
end
