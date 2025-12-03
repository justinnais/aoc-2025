# Ruby Code Review - Day 02

**Review Date:** December 3, 2025

## Overall Assessment

This is a functional solution that successfully solves both parts of the problem! The code demonstrates good fundamentals including proper use of string manipulation, range iteration, and control flow. The structure is clear and easy to follow, with helpful comments explaining the approach. Both solutions take a straightforward iterative approach that works well for this problem domain.

There are several opportunities to make this code more "Ruby-like" by leveraging Ruby's expressive Enumerable methods, improving pattern matching logic, and utilizing Ruby's powerful string and numeric operations more idiomatically.

## Ruby Idioms & Best Practices

### 1. Use Functional Patterns with `sum` Instead of Accumulator Variables

**Current Approach (Part 1, lines 7-28):**
```ruby
total = 0

data.split(',').each do |range|
  start, finish = range.split('-')

  (start..finish).each do |value|
    # ... logic ...
    total += value.to_i if condition
  end
end
total
```

**More Idiomatic Ruby:**
```ruby
data.split(',').sum do |range|
  start, finish = range.split('-')

  (start..finish).sum do |value|
    # ... logic that returns the value or 0 ...
  end
end
```

**Why This Is More Ruby-like:**
- Eliminates mutable state (`total` variable)
- More declarative - expresses *what* we're computing rather than *how*
- Ruby's `sum` method is designed for exactly this pattern
- Follows functional programming principles that Ruby encourages
- The return value is explicit at each level

**For Exercises:** Your current approach is perfectly acceptable and very readable! The accumulator pattern is clear and straightforward. The `sum` approach becomes more valuable as codebases grow and you want to minimize mutable state.

### 2. Destructuring with Parallel Assignment and `map`

**Current Approach (Part 2, line 38):**
```ruby
start, finish = range.split('-').map(&:to_i)
```

**Excellent Work!** This is already idiomatic Ruby. You're using:
- Parallel assignment for destructuring
- Method reference syntax (`:to_i`) with `map`
- Chaining operations together

**Opportunity for Consistency:** Part 1 (line 10) doesn't convert to integers:
```ruby
start, finish = range.split('-')
```

Consider applying the same pattern from Part 2 to Part 1, then converting to strings only when needed.

### 3. Guard Clauses and Early Returns

**Current Approach (Part 1, lines 13-18):**
```ruby
next if value.length.odd?

if value[0] == '0'
  total += value.to_i
  next
end
```

**Alternative Using Guard Clauses:**
```ruby
next if value.length.odd?
next value.to_i if value.start_with?('0')
```

**Why This Is Better:**
- More concise while maintaining clarity
- `start_with?` is more intention-revealing than `value[0] == '0'`
- Combines the check and the action on one line when it's simple
- Reduces nesting and improves readability

**For Exercises:** Your current approach is completely fine! The explicit `if` block is very clear. The one-liner becomes more valuable in production code with many guard clauses.

### 4. String Pattern Matching for Repeated Segments

**Current Approach (Part 2, lines 49-59):**
```ruby
(1...length).each do |i|
  next unless length % i == 0

  segment = value[0, i]
  repeat_count = length / i

  if (segment * repeat_count) == value
    total += num
    break
  end
end
```

**More Idiomatic Ruby:**
```ruby
# Using find to make the search intent explicit
segment_length = (1...length).find do |i|
  next unless length % i.zero?

  segment = value[0, i]
  (segment * (length / i)) == value
end

total += num if segment_length
```

**Why This Is More Ruby-like:**
- `find` (or `detect`) expresses the intent: "find the first segment that works"
- Separates the search logic from the accumulation logic
- More declarative style
- `zero?` is more idiomatic than `== 0`
- The `break` becomes implicit with `find`

**Alternative Using `any?`:**
```ruby
if (1...length).any? { |i| length % i == 0 && value == value[0, i] * (length / i) }
  total += num
end
```

This is more concise but potentially less clear about intent.

### 5. Range Iteration: String vs Integer

**Current Approach (Part 1, lines 12-26):**
```ruby
(start..finish).each do |value|
  next if value.length.odd?
  # ... work with value as string ...
end
```

**Discussion:**
Ruby allows ranges of strings (`'100'..'200'`), which works but has some quirks:
- String ranges iterate lexicographically, not numerically
- For example, `'9'..'11'` doesn't include '10' as expected

**More Predictable Approach:**
```ruby
(start.to_i..finish.to_i).each do |num|
  value = num.to_s
  next if value.length.odd?
  # ... work with value as string ...
end
```

**Trade-offs:**
- String ranges avoid conversion overhead (minor)
- Integer ranges are more predictable and idiomatic for numeric data
- Your current approach works for this specific problem but could be surprising in other contexts

**For Exercises:** If it works reliably for your input (which it does here), it's acceptable! In production code, integer ranges would be more defensive.

### 6. Consistent Naming and Intent

**Current Variables:**
```ruby
half_point = value.length / 2
a = value[0, half_point]
b = value[half_point, half_point]
```

**More Descriptive:**
```ruby
half_point = value.length / 2
left_half = value[0, half_point]
right_half = value[half_point, half_point]

total += value.to_i if left_half == right_half
```

**Why This Is Better:**
- `left_half` and `right_half` are self-documenting
- Single-letter variables (`a`, `b`) require mental mapping
- The comparison reads more naturally

**For Exercises:** Single-letter variables are fine for small scopes! In production code with longer methods, descriptive names become more valuable.

### 7. Method Extraction for Clarity

**Opportunity:**
Both parts have repeated logic that could be extracted:

```ruby
def part_1
  parse_ranges.sum do |start_num, finish_num|
    (start_num..finish_num).sum do |num|
      value = num.to_s
      next 0 if value.length.odd?
      next num if value.start_with?('0')

      num if palindromic_halves?(value)
    end
  end
end

def part_2
  parse_ranges.sum do |start_num, finish_num|
    (start_num..finish_num).sum do |num|
      value = num.to_s
      next num if value.start_with?('0')
      next num if repeating_pattern?(value)

      0
    end
  end
end

private

def parse_ranges
  data.split(',').map { |range| range.split('-').map(&:to_i) }
end

def palindromic_halves?(value)
  half = value.length / 2
  value[0, half] == value[half, half]
end

def repeating_pattern?(value)
  length = value.length
  (1...length).any? do |segment_length|
    next unless (length % segment_length).zero?

    segment = value[0, segment_length]
    (segment * (length / segment_length)) == value
  end
end
```

**Why This Is Better:**
- Clear method names document intent
- Easier to test individual pieces
- Reduces duplication of parsing logic
- Each method has a single responsibility
- More maintainable and extensible

## Performance Optimizations

### 1. Algorithmic Optimization for Part 2

**Current Approach:** Checks all possible segment lengths (O(n) for each number)

**Optimization:** Only check divisors of the length:
```ruby
def repeating_pattern?(value)
  length = value.length

  # Only check lengths that evenly divide the total length
  (1...length).select { |i| (length % i).zero? }.any? do |segment_length|
    segment = value[0, segment_length]
    (segment * (length / segment_length)) == value
  end
end
```

**Analysis:**
- Your current code already does this with `next unless length % i == 0`!
- This is good optimization thinking
- The select + any pattern makes the filtering more explicit
- Performance impact: Minimal for most inputs, but good defensive practice

### 2. String Comparison Short-Circuit

**Current Approach (Part 2, line 55):**
```ruby
if (segment * repeat_count) == value
```

**Micro-optimization:**
```ruby
# Check length first as a quick rejection
if segment.length * repeat_count == value.length && (segment * repeat_count) == value
```

**Analysis:**
- Length comparison is cheaper than string multiplication and comparison
- Only worth it if rejections are common
- For exercises: Over-optimization! Your current code is clearer.
- For production with huge inputs: Worth considering

### 3. Caching String Properties

**Current Pattern:**
```ruby
value = num.to_s
length = value.length
```

**Already Optimal!** You're caching the length calculation, which is good practice.

### 4. Range Efficiency

**Current Approach:** Iterates through entire ranges

**Discussion:**
For this problem, you need to check every number, so iteration is necessary. However, if the problem allowed, you could:
- Use mathematical formulas to calculate results without iteration
- Use parallel processing for independent ranges
- Filter ranges before iteration

**For This Problem:** Your approach is appropriate. Full iteration is required.

## Production-Grade Considerations

Since this is an exercise, these considerations are optional, but they're good to be aware of:

### 1. Input Validation

```ruby
def parse_ranges
  data.split(',').map do |range|
    parts = range.split('-').map(&:to_i)
    raise ArgumentError, "Invalid range format" unless parts.size == 2
    raise ArgumentError, "Invalid range order" unless parts[0] <= parts[1]
    parts
  end
end
```

### 2. Edge Case Handling

Consider what happens with:
- Empty strings
- Negative numbers
- Very large ranges
- Single-digit numbers

Your code handles most of these gracefully, but explicit edge case documentation helps.

### 3. Documentation

```ruby
# Calculates the sum of numbers within comma-separated ranges that have
# palindromic halves (e.g., "1221", "454545")
#
# @return [Integer] sum of all matching numbers
def part_1
  # ...
end
```

### 4. Testing Considerations

In production, you'd want unit tests for:
- `parse_ranges` with various inputs
- `palindromic_halves?` with edge cases
- `repeating_pattern?` with different pattern lengths
- Empty ranges, single-number ranges, etc.

## Learning Resources

To deepen your Ruby knowledge, explore:

1. **Enumerable Methods**
   - Ruby's Enumerable module has powerful methods beyond `each`
   - Study: `sum`, `reduce`, `map`, `select`, `find`, `any?`, `all?`
   - Resource: Ruby Enumerable documentation

2. **Functional Programming in Ruby**
   - Immutable data patterns
   - Reducing side effects
   - Method chaining and composition
   - Resource: "Functional Programming in Ruby" by Arnab Deka

3. **String Methods**
   - Explore: `start_with?`, `end_with?`, `scan`, `partition`
   - Ruby has rich string manipulation beyond array indexing
   - Resource: Ruby String class documentation

4. **Method Extraction and Refactoring**
   - Single Responsibility Principle
   - When and how to extract methods
   - Resource: "Refactoring: Ruby Edition" by Jay Fields

5. **Ruby Performance Optimization**
   - Understanding Ruby's performance characteristics
   - When optimization matters vs. premature optimization
   - Resource: "Ruby Performance Optimization" by Alexander Dymo

## Summary

Your solution is correct, clear, and well-structured! The main opportunities for improvement are:

1. **Use `sum` instead of accumulator variables** for more functional style
2. **Extract methods** to name intent and reduce duplication
3. **Leverage Ruby's expressive methods** like `start_with?` and `find`
4. **Consider integer ranges** over string ranges for predictability
5. **Use descriptive variable names** even in short scopes

These changes would make the code more "Ruby-like" while maintaining the clarity you've already achieved. Great work on solving both parts with a clean, understandable approach!
