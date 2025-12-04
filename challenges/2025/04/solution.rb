# frozen_string_literal: true

module Year2025
  class Day04 < Solution
    DIRECTIONS = [
      [-1, -1],
      [-1, 0],
      [-1, 1],
      [0, -1],
      [0, 1],
      [1, -1],
      [1, 0],
      [1, 1]
    ]

    def part_1
      # grid problem, looking at neighbours
      # if 4 neighbours are filled, can't use

      grid = data.map { |row| row.chars }

      total = 0
      grid.each_with_index do |row, row_index|
        row.each_with_index do |col, col_index|
          next unless col == '@'

          roll_count = DIRECTIONS.sum do |x, y|
            new_row = row_index + x
            new_col = col_index + y

            if new_row >= 0 && new_row < grid.length &&
               new_col >= 0 && new_col < grid[0].length
              cell = grid[new_row][new_col]
              cell == '@' ? 1 : 0
            else
              0 # Out of bounds = not a roll
            end
          end

          total += 1 if roll_count < 4
        end
      end
      total
    end

    def part_2
      grid = data.map { |row| row.chars }

      total = 0
      loop do
        old_grid = grid.map(&:dup)
        grid.each_with_index do |row, row_index|
          row.each_with_index do |col, col_index|
            next unless col == '@'

            roll_count = DIRECTIONS.sum do |x, y|
              new_row = row_index + x
              new_col = col_index + y

              if new_row >= 0 && new_row < grid.length &&
                 new_col >= 0 && new_col < grid[0].length
                cell = grid[new_row][new_col]
                cell == '@' ? 1 : 0
              else
                0 # Out of bounds = not a roll
              end
            end

            if roll_count < 4
              total += 1
              grid[row_index][col_index] = '.'
            end
          end
        end
        break if old_grid == grid
      end
      total
    end

    private
  end
end
