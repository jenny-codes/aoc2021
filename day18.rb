# frozen_string_literal: true

require './runner'

Node = Struct.new(:parent, :left_child, :right_child, :loc) do
  def sum
    3 * (left_child.is_a?(Node) ? left_child.sum : left_child) + 2 * (right_child.is_a?(Node) ? right_child.sum : right_child)
  end

  def is_left?
    loc == :left
  end

  def is_right?
    loc == :right
  end

  def inspect
    [left_child.inspect, right_child.inspect]
  end
end

class SnailFishNumber
  class << self
    def reduce(nodes)
      nodes.reduce do |acc, node|
        add(acc, node)
      end
    end

    def add(left, right)
      new_parent_node = Node.new(nil, nil, nil, nil)
      left.parent = new_parent_node
      left.loc = :left
      right.parent = new_parent_node
      right.loc = :right
      new_parent_node.left_child = left
      new_parent_node.right_child = right
      explode_and_split(new_parent_node)
    end

    def explode_and_split(node)
      while true
        changed, node = explode(node)
        next if changed

        changed, node = split(node)
        next if changed

        break
      end

      node
    end

    def explode(node)
      should_explodes = 4.times.reduce([node]) do |memo, _|
        memo.flat_map do |n|
          left = n.left_child.is_a?(Node) ? n.left_child : nil
          right = n.right_child.is_a?(Node) ? n.right_child : nil
          [left, right].compact
        end
      end
      return [false, node] if should_explodes.empty?

      # Only handle the leftmost one in one iteration
      exploding = should_explodes[0]
      exploding_parent, left_val, right_val = [exploding.parent, exploding.left_child, exploding.right_child]

      update_nearest_left_node(exploding, left_val)
      update_nearest_right_node(exploding, right_val)
      reset_exploded_node(exploding_parent, exploding, left_val, right_val)

      [true, node]
    end

    def reset_exploded_node(parent, exploding, _left_var, _right_var)
      if exploding.is_left?
        parent.left_child = 0
      elsif exploding.is_right?
        parent.right_child = 0
      else
        raise("Parent child mismatch. Parent: #{parent.inspect}. Child: #{exploding.inspect}")
      end
    end

    def update_nearest_right_node(curr, val)
      split_head = curr
      split_head = split_head.parent while split_head.parent && split_head.is_right?
      split_head = split_head.parent
      return if split_head.nil?

      if split_head.right_child.is_a?(Node)
        node = split_head.right_child
        node = node.left_child while node.left_child.is_a?(Node)
        node.left_child += val
      else
        split_head.right_child += val
      end
    end

    def update_nearest_left_node(curr, val)
      split_head = curr
      split_head = split_head.parent while split_head.parent && split_head.is_left?
      split_head = split_head.parent
      return if split_head.nil?

      if split_head.left_child.is_a?(Node)
        node = split_head.left_child
        node = node.right_child while node.right_child.is_a?(Node)
        node.right_child += val
      else
        split_head.left_child += val
      end
    end

    def split(node)
      stack = [node]
      found, val, loc = find_should_split(node, nil, nil)
      return [false, node] unless found

      new_left = val / 2
      new_right = val - new_left
      if loc == :left
        found.left_child = Node.new(found, new_left, new_right, :left)
      elsif loc == :right
        found.right_child = Node.new(found, new_left, new_right, :right)
      else
        raise 'hi???'
      end

      [true, node]
    end

    def find_should_split(node, parent, loc)
      return [parent, node, loc] if node.is_a?(Integer) && node >= 10
      return if node.is_a?(Integer)

      find_should_split(node.left_child, node, :left) ||
        find_should_split(node.right_child, node, :right)
    end
  end
end

class Day18 < Runner
  def do_puzzle1
    nodes = @input.map { |line| parse_to_nodes(line) }
    SnailFishNumber.reduce(nodes).sum
  end

  def do_puzzle2
    nodes = @input
    n = nodes.count

    max = 0
    n.times do |first|
      n.times do |second|
        next if first == second

        first_node = parse_to_nodes(nodes[first].dup)
        second_node = parse_to_nodes(nodes[second].dup)

        result = SnailFishNumber.add(first_node, second_node).sum
        max = result if result > max
      end
    end
    max
  end

  def parse(raw_input)
    raw_input
  end

  def parse_to_nodes(line)
    stack = []
    line.chars.each_with_index do |char, _idx|
      case char
      when '['
        stack << Node.new(nil, nil, nil, nil)
      when ']'
        child = stack.pop
        parent = stack.pop
        if child.is_a?(Node)
          child.parent = parent
          child.loc = :right
        end
        parent.right_child = child
        stack << parent
      when ','
        child = stack.pop
        parent = stack.pop
        if child.is_a?(Node)
          child.parent = parent
          child.loc = :left
        end
        parent.left_child = child
        stack << parent
      else
        stack << (char.to_i)
      end
    end
    stack.first
  end
end
