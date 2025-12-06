# frozen_string_literal: true

module Year2025
  class Day05 < Solution
    def part_1
      # count of numbers that fall into any range
      ranges, numbers = parse(data)

      numbers.count do |num|
        ranges.any? { |range| range.cover?(num) }
      end
    end

    def part_2
      # merge ranges, return total count of ranges
      ranges = data.filter_map { |entry| entry_to_range(entry) if entry.include?('-') }
      merge_ranges(ranges).sum(&:size)
    end

    private

    def parse(data)
      ranges, numbers = data.reject(&:empty?).partition { |entry| entry.include?('-') }
      merged_ranges = merge_ranges(ranges.map { |r| entry_to_range(r) })
      [merged_ranges, numbers.map(&:to_i)]
    end

    def entry_to_range(entry)
      start, finish = entry.split('-').map(&:to_i)
      (start..finish)
    end

    def merge_ranges(ranges)
      return [] if ranges.empty?

      ranges = ranges.sort_by(&:begin)

      merged = [ranges.first]

      ranges[1..].each do |current_range|
        last_merged = merged.last

        if current_range.begin <= last_merged.end
          new_end = [last_merged.end, current_range.end].max
          merged[-1] = last_merged.begin..new_end
        else
          merged << current_range
        end
      end
      merged
    end
    # Processes each line of the input file and stores the result in the dataset
    # def process_input(line)
    #   line.map(&:to_i)
    # end

    # Processes the dataset as a whole
    # def process_dataset(set)
    #   set
    # end
  end
end
