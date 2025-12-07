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
      split_beam(1, index)
    end

    def part_2
      cache = {}

      index = data.first.index(START)
      unique_paths(1, index, cache)
    end

    private

    def out_of_bounds(row, col)
      max_row = data.length
      max_col = data.first.length

      row < 0 || row >= max_row || col < 0 || col >= max_col
    end

    def split_beam(row, col)
      return 0 if out_of_bounds(row, col)

      current_cell = data[row][col]

      return 0 if current_cell == BEAM

      if current_cell == SPLITTER
        left = split_beam(row, col - 1)
        right = split_beam(row, col + 1)
        return left + right + 1
      end

      # avoid duplicate beams
      data[row][col] = BEAM

      split_beam(row + 1, col)
    end

    def unique_paths(row, col, cache)
      key = [row, col]
      return cache[key] if cache.key?(key)

      return 1 if out_of_bounds(row, col)

      current_cell = data[row][col]

      count = if current_cell == SPLITTER
                left = unique_paths(row, col - 1, cache)
                right = unique_paths(row, col + 1, cache)
                return left + right
              else
                unique_paths(row + 1, col, cache)
              end

      cache[key] = count

      count
    end
  end
end
