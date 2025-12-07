# Ruby Code Review - Day 04

**Review Date:** 2025-12-04

## Overall Assessment

Good working solution! The code correctly solves both parts using straightforward grid traversal. The use of `sum` with blocks is nice Ruby style. The main opportunities for improvement are around extracting duplicated logic and using more expressive Ruby patterns for bounds checking and neighbor queries.

## Top 3 Ruby Improvements

### 1. Extract Duplicated Neighbor Counting Logic

**Current approach:** The neighbor counting logic is duplicated between `part_1` (lines 27-38) and `part_2` (lines 56-67).

**More idiomatic Ruby:**

```ruby
def count_neighbors(grid, row, col, target = '@')
  DIRECTIONS.count do |dx, dy|
    new_row, new_col = row + dx, col + dy
    grid.dig(new_row, new_col) == target
  end
end
```

**Why it's better:**
- `dig` is a Ruby gem that safely navigates nested structures, returning `nil` for out-of-bounds (no manual bounds checking!)
- Using `count` instead of `sum` with ternary is more semantic for boolean counting
- Parallel assignment (`new_row, new_col = row + dx, col + dy`) is more Ruby-like than separate assignments
- DRY principle: define once, reuse everywhere

**Updated part_1:**
```ruby
def part_1
  grid = data.map(&:chars)

  grid.each_with_index.count do |row, row_index|
    row.each_with_index.count do |cell, col_index|
      cell == '@' && count_neighbors(grid, row_index, col_index) < 4
    end
  end
end
```

### 2. Fix Misleading Variable Name

**Current code:**
```ruby
row.each_with_index do |col, col_index|
  next unless col == '@'
```

**Issue:** The variable `col` actually represents a **cell value/character**, not a column. This is confusing!

**Better naming:**
```ruby
row.each_with_index do |cell, col_index|
  next unless cell == '@'
```

**Why it matters:** Clear variable names make code self-documenting and prevent confusion when debugging.

### 3. Use `each_index` and Flatten Nested Iteration

**Current approach:** Nested `each_with_index` creates visual complexity and requires tracking both row/cell and their indices.

**More Ruby-like pattern:**

```ruby
def part_1
  grid = data.map(&:chars)

  (0...grid.size).sum do |row_index|
    (0...grid[row_index].size).count do |col_index|
      grid[row_index][col_index] == '@' && count_neighbors(grid, row_index, col_index) < 4
    end
  end
end
```

Or even more elegantly with `product`:

```ruby
def part_1
  grid = data.map(&:chars)

  (0...grid.size).to_a.product(0...grid[0].size.to_a).count do |row, col|
    grid[row][col] == '@' && count_neighbors(grid, row, col) < 4
  end
end
```

**Why it's better:**
- Flatter iteration structure
- `product` creates all coordinate pairs, making the 2D iteration more explicit
- Reduces nesting depth and improves readability

### 4. Bonus: Part 2 Grid Mutation Strategy

**Current approach:** Mutating `grid` during iteration (line 71) while comparing with `old_grid`.

**Safer approach:**

```ruby
def part_2
  grid = data.map(&:chars)
  total = 0

  loop do
    positions_to_remove = []

    grid.each_with_index do |row, row_index|
      row.each_with_index do |cell, col_index|
        if cell == '@' && count_neighbors(grid, row_index, col_index) < 4
          positions_to_remove << [row_index, col_index]
        end
      end
    end

    break if positions_to_remove.empty?

    positions_to_remove.each do |row, col|
      grid[row][col] = '.'
      total += 1
    end
  end

  total
end
```

**Why it's better:**
- Separates detection from mutation (safer and clearer intent)
- No need to deep copy the entire grid with `map(&:dup)`
- Natural loop termination when no positions found
- More memory efficient

## Complete Refactored Example

```ruby
module Year2025
  class Day04 < Solution
    DIRECTIONS = [
      [-1, -1], [-1, 0], [-1, 1],
      [0, -1],           [0, 1],
      [1, -1],  [1, 0],  [1, 1]
    ].freeze

    def part_1
      grid = data.map(&:chars)
      count_valid_positions(grid)
    end

    def part_2
      grid = data.map(&:chars)
      total = 0

      loop do
        positions = find_removable_positions(grid)
        break if positions.empty?

        positions.each do |row, col|
          grid[row][col] = '.'
          total += 1
        end
      end

      total
    end

    private

    def count_valid_positions(grid)
      (0...grid.size).sum do |row|
        (0...grid[row].size).count do |col|
          grid[row][col] == '@' && count_neighbors(grid, row, col) < 4
        end
      end
    end

    def find_removable_positions(grid)
      [].tap do |positions|
        grid.each_with_index do |row, row_index|
          row.each_with_index do |cell, col_index|
            if cell == '@' && count_neighbors(grid, row_index, col_index) < 4
              positions << [row_index, col_index]
            end
          end
        end
      end
    end

    def count_neighbors(grid, row, col, target = '@')
      DIRECTIONS.count do |dx, dy|
        grid.dig(row + dx, col + dy) == target
      end
    end
  end
end
```

## Key Takeaways

1. **Array#dig is a hidden gem**: Use it for safe nested access instead of manual bounds checking
2. **count vs sum for booleans**: `count` is more semantic than `sum { condition ? 1 : 0 }`
3. **Extract, extract, extract**: Duplicated code is a sign that helper methods are needed
4. **Variable names matter**: `col` (column) vs `cell` (value) - precision prevents confusion

These changes transform working code into idiomatic Ruby that's easier to test, maintain, and understand!
