# frozen_string_literal: true

module Year2025
  DIAL_SIZE = 100
  STARTING_POSITION = 50
  DIRECTION_MULTIPLIER = { 'L' => -1, 'R' => 1 }.freeze

  class Day01 < Solution
    def part_1
      position = STARTING_POSITION
      zero_count = 0

      data.each do |turn|
        direction, distance = parse_turn(turn)

        movement = distance * DIRECTION_MULTIPLIER[direction]

        position += movement
        position %= DIAL_SIZE

        zero_count += 1 if position.zero?
      end
      zero_count
    end

    def part_2
      position = STARTING_POSITION
      zero_crossings = 0

      data.each do |turn|
        direction, distance = parse_turn(turn)

        movement = distance * DIRECTION_MULTIPLIER[direction]
        new_position = position + movement

        crossings = count_zero_crossings(position, new_position, direction)

        zero_crossings += crossings
        position = new_position % DIAL_SIZE
      end
      zero_crossings
    end

    private

    def parse_turn(turn)
      direction = turn[0]
      distance = turn[1..].to_i
      [direction, distance]
    end

    def count_zero_crossings(start_position, finish_position, direction)
      if direction == 'R'
        finish_position / DIAL_SIZE
      else
        start_segment = (start_position.to_f / DIAL_SIZE).ceil
        end_segment = (finish_position.to_f / DIAL_SIZE).ceil
        (start_segment - end_segment).abs
      end
    end
  end
end
