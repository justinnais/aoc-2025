# frozen_string_literal: true

module Year2025
  class Day02 < Solution
    def part_1
      # for each number in range, split in half, compare two halves
      parse_ranges.sum do |start, finish|
        (start..finish).sum do |num|
          value = num.to_s
          next 0 if value.length.odd?
          next num if value.start_with?('0')

          palindromic_halves?(value) ? num : 0
        end
      end
    end

    def part_2
      # could probably bruteforce with loops -> o^3?
      # need to find repeating segments instead of halves?

      parse_ranges.sum do |start, finish|
        (start..finish).sum do |num|
          value = num.to_s
          next num if value.start_with?('0')

          repeating_pattern?(value) ? num : 0
        end
      end
    end

    private

    def parse_ranges
      data.split(',').map { |range| range.split('-').map(&:to_i) }
    end

    def palindromic_halves?(value)
      half = value.length / 2
      left_half = value[0, half]
      right_half = value[half..]

      left_half == right_half
    end

    def repeating_pattern?(value)
      length = value.length
      (1...length).any? do |segment_length|
        next unless (length % segment_length).zero?

        segment = value[0, segment_length]
        repeat_count = length / segment_length

        (segment * repeat_count) == value
      end
    end
  end
end
