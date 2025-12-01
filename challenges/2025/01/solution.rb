# frozen_string_literal: true

module Year2025
  class Day01 < Solution
    def part_1
      value = 50
      zero_count = 0
      data.each do |turn|
        direction = turn[0]
        distance = turn[1..-1].to_i

        movement = (direction == 'L' ? -distance : distance)

        value += movement
        value %= 100

        zero_count += 1 if value == 0
      end
      zero_count
    end

    def part_2
      value = 50
      zero_crossings = 0
      data.each do |turn|
        direction = turn[0]
        distance = turn[1..-1].to_i

        movement = (direction == 'L' ? -distance : distance)
        new_value = value + movement

        crossings = count_zero_crossings(value, new_value, direction)

        zero_crossings += crossings
        value = new_value % 100
      end
      zero_crossings
    end

    private

    def count_zero_crossings(start, finish, direction)
      if direction == 'R'
        finish / 100
      else
        start_segment = (start.to_f / 100.0).ceil
        end_segment = (finish.to_f / 100.0).ceil
        (start_segment - end_segment).abs
      end
    end
  end
end
