# frozen_string_literal: true

module Year2025
  class Day02 < Solution
    def part_1
      # for each number in range, split in half, compare two halves
      total = 0

      data.split(',').each do |range|
        start, finish = range.split('-')

        (start..finish).each do |value|
          next if value.length.odd?

          if value[0] == '0'
            total += value.to_i
            next
          end

          half_point = value.length / 2

          a = value[0, half_point]
          b = value[half_point, half_point]

          total += value.to_i if a == b
        end
      end
      total
    end

    def part_2
      # could probably bruteforce with loops -> o^3?
      # need to find repeating segments instead of halves?

      total = 0

      data.split(',').each do |range|
        start, finish = range.split('-').map(&:to_i)

        (start..finish).each do |num|
          value = num.to_s
          if value[0] == '0'
            total += num
            next
          end

          length = value.length

          (1...length).each do |i|
            next unless length % i == 0

            segment = value[0, i]
            repeat_count = length / i

            if (segment * repeat_count) == value
              total += num
              break
            end
          end
        end
      end
      total
    end
  end
end
