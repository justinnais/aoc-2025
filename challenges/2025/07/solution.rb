# frozen_string_literal: true

module Year2025
  class Day07 < Solution
    SPLITTER = '^'
    BEAM = '|'
    START = 'S'

    def part_1
      # find S index, check each line beneath for splitter, if found, split beem, repeat for new beems
      # count splits
      index = data.first.index(START)
      @visited = Set.new
      split_beam(1, index)
    end

    def part_2
      index = data.first.index(START)
      @cache = {}
      unique_paths(1, index)
    end

    private

    def max_row
      @max_row ||= data.length
    end

    def max_col
      @max_col ||= data.first.length
    end

    def out_of_bounds?(row, col)
      row.negative? || row >= max_row || col.negative? || col >= max_col
    end

    def split_beam(row, col)
      key = [row, col]

      return 0 if out_of_bounds?(row, col)
      return 0 if @visited.include?(key)

      @visited.add(key)

      current_cell = data[row][col]
      return split_beam(row + 1, col) unless current_cell == SPLITTER

      left = split_beam(row, col - 1)
      right = split_beam(row, col + 1)

      left + right + 1
    end

    def unique_paths(row, col)
      key = [row, col]

      return 1 if out_of_bounds?(row, col)

      @cache[key] ||= begin
        current_cell = data[row][col]
        return unique_paths(row + 1, col) unless current_cell == SPLITTER

        left = unique_paths(row, col - 1)
        right = unique_paths(row, col + 1)

        left + right
      end
    end
  end
end
