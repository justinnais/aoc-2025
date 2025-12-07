# Ruby Code Review - Day 6: Trash Compactor

**Review Date:** December 6, 2025

## Overall Assessment

Great work solving this challenging problem! The solution correctly handles both parts of the puzzle - Part 1 with its straightforward column-based operations, and Part 2 with its more complex right-to-left column reading. Your use of `transpose` in Part 1 is an excellent Ruby idiom that elegantly transforms the problem space. The `create_equations` method in Part 2 shows good problem-solving, though there are opportunities to make it more Ruby-like and easier to understand.

**Strengths:**
- Excellent use of `transpose` to convert rows to columns in Part 1
- Proper use of splat operator for destructuring
- Good use of `reduce` with symbol-to-proc
- The algorithm correctly identifies equation boundaries using `each_cons(2)`

**Areas for improvement:**
- Part 2 has leftover debugging code (`puts`)
- The `create_equations` method is complex and could be refactored
- Some variable names could be more descriptive
- Opportunities to use more Ruby idioms for clarity

---

## Ruby Idioms & Best Practices

### 1. Remove Debug Code (Critical)

**Current Code (lines 36-38):**
```ruby
puts transformed_numbers.join(operator)

transformed_numbers.map(&:to_i).reduce(operator.to_sym)
```

**Issue:** The `puts` statement is leftover debug code that should be removed. Also, `transformed_numbers` is already an array of integers (from line 32-34), so `map(&:to_i)` is redundant.

**Better Approach:**
```ruby
transformed_numbers.reduce(operator.to_sym)
```

**Why:** Debug statements should be removed before committing. The redundant `map(&:to_i)` adds unnecessary processing since the numbers are already integers.

### 2. Simplify Column Extraction Using `zip`

**Current Code (lines 21-30):**
```ruby
max_index = initial_numbers.map(&:length).max - 1
number_chars = initial_numbers.map(&:chars)
columns = []

max_index.downto(0) do |i|
  column = number_chars.map do |number|
    number.dig(-i - 1)
  end
  columns << column
end
```

**More Ruby-like Alternative:**
```ruby
# Convert strings to character arrays, then transpose to get columns
# Reading right-to-left means reversing first
columns = initial_numbers
  .map { |num| num.chars.reverse }
  .then { |arrays| arrays.max_by(&:length).length.times.map { |i| arrays.map { |a| a[i] } } }
```

Or even more elegantly using `zip`:
```ruby
# Pad arrays to same length, then zip to get columns
max_length = initial_numbers.map(&:length).max
columns = initial_numbers
  .map { |num| num.chars.reverse.fill(nil, num.length...max_length) }
  .transpose
```

**Why:** Ruby's `transpose` works beautifully for this operation once you've prepared the data. The manual loop with `dig(-i - 1)` and `downto` works but is more imperative than Ruby typically encourages. However, your approach is valid - the alternative above may be clearer to other Ruby developers.

**For Exercises:** Your current approach is perfectly acceptable and arguably easier to understand. The index-based approach with `downto` makes the algorithm explicit.

**For Production:** The `transpose` approach would be preferred as it's more declarative and leverages Ruby's built-in matrix operations.

### 3. Refactor `create_equations` for Clarity

**Current Code (lines 50-83):**
The method does several things: finds equation boundaries, extracts numbers, and handles the final equation separately.

**Better Approach - Break into Smaller Methods:**
```ruby
def create_equations
  operators = data.pop.chars
  equation_boundaries = find_equation_boundaries(operators)

  equation_boundaries.map do |start_pos, end_pos|
    operator = operators[start_pos]
    numbers = data.map { |line| line[start_pos..end_pos] }
    numbers + [operator]
  end
end

def find_equation_boundaries(operators)
  boundaries = []
  left_pointer = 0

  operators.each_cons(2).each_with_index do |(current, next_char), index|
    if current == ' ' && next_char != ' '
      boundaries << [left_pointer, index - 1]
      left_pointer = index + 1
    end
  end

  # Add final equation
  boundaries << [left_pointer, operators.length - 1]
  boundaries
end
```

**Why:** Single Responsibility Principle - each method does one thing well. The boundary detection logic is isolated and testable. The duplication between the loop and "final equation" handling is eliminated by including the final boundary in the array.

### 4. Use More Descriptive Variable Names

**Current Code:**
```ruby
operators.each_cons(2).each_with_index do |group, index|
  next unless group[0] == ' ' && group[1] != ' '
```

**Better:**
```ruby
operators.each_cons(2).each_with_index do |(current, next_char), index|
  next unless current == ' ' && next_char != ' '
```

**Why:** Destructuring the pair directly makes the code self-documenting. `group[0]` and `group[1]` require the reader to remember what the indices represent.

### 5. Consider Using `chunk` for Boundary Detection

**Alternative Ruby Idiom:**
```ruby
def find_equation_boundaries(operators)
  boundaries = []
  in_equation = false
  start_pos = 0

  operators.chars.each_with_index do |char, index|
    if char != ' ' && !in_equation
      start_pos = index
      in_equation = true
    elsif char == ' ' && in_equation && (index + 1 >= operators.length || operators[index + 1] == ' ')
      boundaries << [start_pos, index - 1]
      in_equation = false
    end
  end

  # Add final boundary if we're still in an equation
  boundaries << [start_pos, operators.length - 1] if in_equation
  boundaries
end
```

Or using Ruby's `chunk`:
```ruby
def find_equation_boundaries(operators)
  # Group consecutive spaces vs non-spaces
  chunks = operators.chars.chunk { |c| c == ' ' }.with_index

  chunks.filter_map do |(is_space, chars), idx|
    next if is_space

    start_pos = chunks.take(idx).sum { |(_, cs)| cs.length }
    end_pos = start_pos + chars.length - 1
    [start_pos, end_pos]
  end
end
```

**Why:** `chunk` is a powerful but underutilized Ruby method that groups consecutive elements. It's perfect for finding runs of spaces vs non-spaces. However, for this specific case, your `each_cons` approach is arguably clearer.

---

## Performance Optimizations

### 1. Avoid Redundant Operations

**Current Issue (line 38):**
```ruby
transformed_numbers.map(&:to_i).reduce(operator.to_sym)
```

The array `transformed_numbers` is built on line 32-34 by explicitly calling `.to_i` on each joined string. The `.map(&:to_i)` on line 38 is redundant.

**Impact:** Low - for exercise inputs this won't matter, but it's wasteful.

### 2. Mutating vs. Building Arrays

**Current Approach (lines 27-30):**
```ruby
columns = []
# ...
columns << column
```

**Alternative:**
```ruby
columns = max_index.downto(0).map do |i|
  number_chars.map { |number| number.dig(-i - 1) }
end
```

**Why:** Using `map` is more functional and idiomatic in Ruby. Building arrays with `<<` is perfectly fine for exercises, but `map` expresses the intent more clearly - "transform each index into a column."

**Performance Note:** For this problem size, there's no meaningful difference. The `map` approach creates the array once; the `<<` approach potentially resizes the array multiple times (though Ruby optimizes this internally).

---

## Production-Grade Considerations

### 1. Error Handling and Edge Cases

**Current Code:** Assumes well-formed input with:
- At least one equation
- Valid operators (`+` or `*`)
- Proper spacing between equations

**For Production, Consider:**
```ruby
def create_grid
  lines = data.map(&:split).compact
  return [] if lines.empty?

  lines.transpose
rescue IndexError
  raise ArgumentError, "Input data has inconsistent row lengths"
end

def part_2
  return 0 if data.empty?

  create_equations.sum do |equation|
    *initial_numbers, operator = equation
    next 0 if operator.nil? || !%w[+ *].include?(operator)

    # ... rest of logic
  end
end
```

**Why:** In production, you'd want to handle malformed input gracefully rather than raising cryptic errors.

### 2. Input Validation

**For Production:**
```ruby
def validate_operator(operator)
  unless %w[+ *].include?(operator)
    raise ArgumentError, "Invalid operator: #{operator.inspect}"
  end
  operator
end
```

### 3. Method Complexity

The `create_equations` method has a cyclomatic complexity of 5+ (multiple conditionals, loops). In production, aim for complexity < 10 per method.

**Recommendation:** The refactored version with extracted methods would be more maintainable in a production codebase.

---

## Learning Resources

### Ruby Methods to Explore

1. **`transpose`**: You used this brilliantly in Part 1! Explore how it can be used in Part 2 as well.
   - [Ruby Doc: Array#transpose](https://ruby-doc.org/core-3.1.0/Array.html#method-i-transpose)

2. **`chunk` and `chunk_while`**: Powerful methods for grouping consecutive elements
   - [Ruby Doc: Enumerable#chunk](https://ruby-doc.org/core-3.1.0/Enumerable.html#method-i-chunk)

3. **`each_cons` and `each_slice`**: You used `each_cons` well! Explore `each_slice` for similar problems
   - [Ruby Doc: Enumerable#each_cons](https://ruby-doc.org/core-3.1.0/Enumerable.html#method-i-each_cons)

4. **`dig` vs direct indexing**: You used `dig` correctly for safe navigation, but consider when it's overkill
   - [Ruby Doc: Array#dig](https://ruby-doc.org/core-3.1.0/Array.html#method-i-dig)

### Ruby Patterns to Study

1. **Functional vs Imperative Ruby**:
   - When to use `map`/`reduce` vs `each` with mutation
   - [Style Guide: Functional Programming](https://rubystyle.guide/#functional-code)

2. **Method Extraction and Single Responsibility Principle**:
   - Breaking complex methods into smaller, focused ones
   - [Clean Code Ruby](https://github.com/uohzxela/clean-code-ruby)

3. **Ruby's Matrix Operations**:
   - Explore `Matrix` class for 2D array operations
   - [Ruby Doc: Matrix](https://ruby-doc.org/stdlib-3.1.0/libdoc/matrix/rdoc/Matrix.html)

### Suggested Practice

Try refactoring `create_equations` to:
1. Use `chunk` instead of `each_cons`
2. Eliminate the duplicate "final equation" logic
3. Break into smaller methods with clear names

This will deepen your understanding of Ruby's enumerable methods and functional programming style!

---

## Summary

Your solution demonstrates solid Ruby knowledge and good problem-solving skills. The use of `transpose` in Part 1 is excellent, and your algorithm for Part 2 correctly solves a tricky problem. Focus on:

1. **Removing debug code** before committing
2. **Breaking complex methods** into smaller, focused pieces
3. **Using descriptive names** when destructuring
4. **Exploring Ruby's enumerable methods** like `chunk` and `transpose` for more expressive code

Keep up the great work! The solution is correct and demonstrates growing familiarity with Ruby's powerful standard library.
