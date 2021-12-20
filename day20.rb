# frozen_string_literal: true

require './runner'
require 'set'

LIGHT_PIXEL = 1
DARK_PIXEL = 0

Location = Struct.new(:x, :y)

Image = Struct.new(:light_pixel_locs, :boundary_color) do
  def light_pixels_count
    light_pixel_locs.count
  end

  def x_range
    return @x_range if @x_range

    leftest, rightest = light_pixel_locs.minmax_by(&:x).map(&:x)
    @x_range = (leftest - 1)..(rightest + 1)
    @x_range
  end

  def y_range
    return @y_range if @y_range

    lowest, highest = light_pixel_locs.minmax_by(&:y).map(&:y)
    @y_range = (lowest - 1)..(highest + 1)
    @y_range
  end

  def each_loc_in_range(&block)
    x_range.map do |x_idx|
      y_range.map do |y_idx|
        block.call(Location.new(x_idx, y_idx))
      end
    end
  end

  def pixels_surrounding(loc)
    [
      [loc.x - 1, loc.y + 1], [loc.x, loc.y + 1], [loc.x + 1, loc.y + 1],
      [loc.x - 1, loc.y], [loc.x, loc.y], [loc.x + 1, loc.y],
      [loc.x - 1, loc.y - 1], [loc.x, loc.y - 1], [loc.x + 1, loc.y - 1]
    ].map { |l| calculate_pixel_color_at(Location.new(*l)) }
  end

  def calculate_pixel_color_at(loc)
    return boundary_color if outside_boundary?(loc)

    light_pixel_locs.include?(loc) ? LIGHT_PIXEL : DARK_PIXEL
  end

  def outside_boundary?(loc)
    loc.x >= x_range.max || loc.x <= x_range.min || loc.y >= y_range.max || loc.y <= y_range.min
  end
end

Enhancer = Struct.new(:algo) do
  def enhance_twice(image)
    first_enhanced = enhance(image, Image.new(Set.new, LIGHT_PIXEL))
    enhance(first_enhanced, Image.new(Set.new, DARK_PIXEL))
  end

  def enhance(orig_image, new_image)
    orig_image.each_loc_in_range do |location|
      new_pixel = new_pixel_from(orig_image.pixels_surrounding(location))
      new_image.light_pixel_locs << location if new_pixel == LIGHT_PIXEL
    end
    new_image
  end

  def new_pixel_from(surround_pixels)
    idx = surround_pixels.join.to_i(2)
    algo[idx]
  end
end

class Day20 < Runner
  def do_puzzle1
    enhancement_algo, image = @input
    Enhancer.new(enhancement_algo).enhance_twice(image).light_pixels_count
  end

  def do_puzzle2
    enhancement_algo, image = @input
    enhancer = Enhancer.new(enhancement_algo)
    25.times { image = enhancer.enhance_twice(image) }
    image.light_pixels_count
  end

  def parse(raw_input)
    algorithm = raw_input.shift.split('').map do |val|
      val == '#' ? LIGHT_PIXEL : DARK_PIXEL
    end

    image = Image.new(Set.new, DARK_PIXEL)
    raw_input[1..-1].each_with_index.each do |line, y_idx|
      line.split('').each_with_index.each do |val, x_idx|
        next if val == '.'

        image.light_pixel_locs << Location.new(x_idx, -y_idx)
      end
    end
    [algorithm, image]
  end
end
