# Ruby Code Review - Day 7

**Review Date:** December 7, 2025

## Overall Assessment

This is a clean, working solution that demonstrates good understanding of recursive algorithms for grid traversal problems. The code uses appropriate data structures (Set for visited tracking, Hash for memoization) and shows awareness of performance optimization needs through caching. The separation of concerns between the two parts is clear, with each having its own recursive helper method.

## Ruby Idioms & Best Practices

### 1. Array Destructuring in Method Signatures

**Current approach:**
```ruby
def out_of_bounds?((row, col))
  row.negative? || row >= max_row || col.negative? || col >= max_col
end
```

**More idiomatic Ruby:**
```ruby
def out_of_bounds?(row, col)
  row.negative? || row >= max_row || col.negative? || col >= max_col
end

# Called as:
out_of_bounds?(row, col)  # Instead of out_of_bounds?([row, col])
```

**Why this is better:** While the destructuring syntax `((row, col))` is clever, it requires callers to wrap coordinates in an array or use double parentheses `out_of_bounds?((key))`, which can be confusing. Using two separate parameters is more explicit and follows Ruby conventions. If you want to maintain the coordinate pairing concept, consider using keyword arguments or a coordinate struct.

**Acceptable for exercises:** Your current approach is perfectly fine for exercises where terseness matters.

### 2. Hash Memoization Pattern

**Current approach:**
```ruby
def unique_paths(row, col, cache = {})
  key = [row, col]
  return cache[key] if cache.key?(key)

  # ... calculation ...

  cache[key] = count
  count
end
```

**More idiomatic Ruby:**
```ruby
def unique_paths(row, col, cache = {})
  key = [row, col]
  cache.fetch(key) do
    count = if current_cell == SPLITTER
              # ... calculation ...
            else
              # ... calculation ...
            end
    cache[key] = count
  end
end
```

**Why this is more Ruby-like:** The `Hash#fetch` method with a block is Ruby's idiomatic way to handle "get or compute and store" patterns. It's more expressive and eliminates the explicit conditional check. However, for pure memoization, consider:

```ruby
cache[key] ||= begin
  # ... calculation ...
end
```

**Note:** Be careful with `||=` when cached values could be `false` or `nil` (not an issue here since you're counting).

### 3. Consistent Memoization Strategy

**Current approach:**
- Part 1: `visited = Set.new` passed as parameter
- Part 2: `cache = {}` passed as parameter

**More maintainable approach:**
```ruby
def part_1
  index = data.first.index(START)
  @visited = Set.new
  split_beam(1, index)
end

def split_beam(row, col)
  key = [row, col]
  return 0 if out_of_bounds?(key)
  return 0 if @visited.include?(key)

  @visited.add(key)
  # ...
end
```

**Why this matters:** While passing cache/visited as parameters works for exercises, using instance variables (`@visited`, `@cache`) is more typical in Ruby for maintaining state across recursive calls. It also eliminates the risk of accidentally passing the wrong cache object or forgetting to pass it in recursive calls.

**Acceptable for exercises:** Your approach is fine here—it's actually more functional programming style and makes the dependency explicit.

### 4. Guard Clause Consistency

**Observation:**
In `split_beam`, you check bounds first, then visited:
```ruby
return 0 if out_of_bounds?(key)
return 0 if visited.include?(key)
```

In `unique_paths`, you check cache first, then bounds:
```ruby
return cache[key] if cache.key?(key)
return 1 if out_of_bounds?(key)
```

**Better approach:**
Be consistent. For optimal performance, check the cache first (O(1) hash lookup vs method call), then bounds:

```ruby
# Consistent ordering for both methods
return cached_value if already_cached?(key)
return boundary_value if out_of_bounds?(key)
```

**Why consistency matters:** It makes code easier to reason about and review. The order here affects readability more than performance, but establishing patterns helps prevent bugs.

### 5. Implicit vs Explicit Returns

**Mixed usage:**
```ruby
# Part 1: explicit returns everywhere
return 0 if out_of_bounds?(key)
return left + right + 1

# Part 2: implicit final return
count
```

**More idiomatic Ruby:**
Ruby style favors implicit returns:
```ruby
def split_beam(row, col, visited = Set.new)
  key = [row, col]

  return 0 if out_of_bounds?(key)
  return 0 if visited.include?(key)

  visited.add(key)
  current_cell = data[row][col]

  return split_beam(row + 1, col, visited) unless current_cell == SPLITTER

  left = split_beam(row, col - 1, visited)
  right = split_beam(row, col + 1, visited)
  left + right + 1  # Implicit return
end
```

**Why it's more Ruby-like:** Implicit returns are idiomatic Ruby. Use explicit `return` for early exits (guard clauses) but let the last expression be the return value naturally.

### 6. Negative Number Check

**Current:**
```ruby
row.negative? || row >= max_row || col.negative? || col >= max_col
```

**This is perfect!** Using `negative?` is exactly the right Ruby idiom. Well done!

Many developers write `row < 0`, but `negative?` is more expressive and reads better.

## Performance Optimizations

### Critical Optimization Opportunity

**Observation:** Part 1 tracks visited cells but doesn't cache results, while Part 2 caches results. Consider whether Part 1 would benefit from result caching similar to Part 2:

```ruby
def split_beam(row, col, visited = Set.new, cache = {})
  key = [row, col]
  return cache[key] if cache.key?(key)
  return 0 if out_of_bounds?(key)
  return 0 if visited.include?(key)

  visited.add(key)
  current_cell = data[row][col]

  result = if current_cell == SPLITTER
             left = split_beam(row, col - 1, visited, cache)
             right = split_beam(row, col + 1, visited, cache)
             left + right + 1
           else
             split_beam(row + 1, col, visited, cache)
           end

  cache[key] = result
end
```

**Why this helps:** If the same coordinate can be reached via different paths, caching prevents redundant calculations. However, analyze if this is actually needed for your problem—if each cell is only visited once, the visited Set is sufficient.

### Algorithm Efficiency

Both solutions use recursive DFS with appropriate memoization/visited tracking. Time complexity is O(n) where n is the number of cells, which is optimal for this type of graph traversal.

## Production-Grade Considerations

For real-world code, consider:

1. **Input validation:** What happens if `data` is empty or doesn't contain 'S'?
2. **Stack overflow:** Deep recursion on large grids could cause stack overflow. Consider iterative approach with explicit stack for production use.
3. **Constants namespace:** Consider moving constants to a module or using more specific names if they might conflict.

These are overkill for exercises but matter in production systems.

## Learning Resources

- **Ruby's Enumerable magic:** Explore `Hash#fetch` and `Hash#default_proc` for elegant memoization patterns
- **Pattern matching (Ruby 3+):** Could simplify the cell type checking with pattern matching
- **Stack vs Heap considerations:** Understanding when recursion depth matters vs when Ruby's call stack is sufficient

## Summary

This is well-structured code that solves the problem efficiently. The main opportunities are:
1. Choose between instance variables or parameters for state (both work, be consistent)
2. Use `Hash#fetch` for more idiomatic cache checks
3. Prefer implicit returns except for guard clauses
4. Keep guard clause ordering consistent across similar methods

Your use of `negative?`, proper constant naming, and appropriate data structures (Set vs Hash) shows good Ruby awareness. Keep it up!
