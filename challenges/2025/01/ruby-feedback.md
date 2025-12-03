# Ruby Code Review - Day 01 Solution

**Review Date:** December 3, 2025

## Overall Assessment

Great work on solving this dial rotation puzzle! Your solution is correct, well-structured, and demonstrates good understanding of modular arithmetic. The code is clean and the logic is easy to follow. The separation between part 1 and part 2 is clear, and you've properly extracted the zero-crossing logic into a private helper method.

Now let's explore how we can make this code even more idiomatic and "Ruby-like"!

## Ruby Idioms & Best Practices

### 1. String Parsing - Use Pattern Matching or Scan

**Current Approach:**
```ruby
direction = turn[0]
distance = turn[1..-1].to_i
```

While this works perfectly, Ruby offers more expressive ways to parse strings. Here are some idiomatic alternatives:

**Option A: Using `scan` with regex (Ruby Classic):**
```ruby
direction, distance = turn.scan(/([LR])(\d+)/).first
distance = distance.to_i
```

**Option B: Pattern matching (Ruby 2.7+):**
```ruby
case turn
in /^L(?<distance>\d+)$/
  direction = 'L'
  distance = $~[:distance].to_i
in /^R(?<distance>\d+)$/
  direction = 'R'
  distance = $~[:distance].to_i
end
```

**Option C: Simple match with capture (Most Readable):**
```ruby
match = turn.match(/([LR])(\d+)/)
direction, distance = match[1], match[2].to_i
```

**Why it's more Ruby-like:** These approaches make the parsing intent more explicit - you're extracting a direction letter followed by digits. The regex makes the expected format clear to readers.

**For Exercises:** Your current approach is perfectly acceptable and actually quite clear for quick problem-solving!

### 2. Extract Magic Numbers to Constants

**Current Approach:**
```ruby
value %= 100
# ... and elsewhere
finish / 100
```

**More Idiomatic:**
```ruby
module Year2025
  class Day01 < Solution
    DIAL_SIZE = 100
    STARTING_POSITION = 50

    def part_1
      position = STARTING_POSITION
      # ...
      position %= DIAL_SIZE
    end
  end
end
```

**Why it's better:** Constants give meaning to magic numbers. When someone reads `position %= DIAL_SIZE`, they immediately understand that the dial wraps around. It also makes the code more maintainable - if the dial size changed, you'd update it in one place.

### 3. Variable Naming - Be More Descriptive

**Current Approach:**
```ruby
value = 50
```

**More Expressive:**
```ruby
dial_position = STARTING_POSITION
# or simply
position = STARTING_POSITION
```

**Why it's more Ruby-like:** Ruby values readable code that reads like natural language. `dial_position` or `position` immediately conveys what the variable represents, whereas `value` is generic.

### 4. Simplify Movement Calculation

**Current Approach:**
```ruby
movement = (direction == 'L' ? -distance : distance)
```

This is fine, but here are some alternatives:

**Option A: Case statement (more Ruby-like for multiple conditions):**
```ruby
movement = case direction
           when 'L' then -distance
           when 'R' then distance
           end
```

**Option B: Hash lookup (elegant for mappings):**
```ruby
DIRECTION_MULTIPLIER = { 'L' => -1, 'R' => 1 }.freeze

movement = distance * DIRECTION_MULTIPLIER[direction]
```

**Why it's more Ruby-like:** The hash approach is particularly elegant - it separates data (the direction-to-multiplier mapping) from logic. It's also easier to extend if you add more directions.

**For Exercises:** Your ternary is perfectly fine! The hash approach might be overkill for just two directions.

### 5. Use `count` Instead of Manual Counting

**Current Approach (Part 1):**
```ruby
zero_count = 0
data.each do |turn|
  # ...
  zero_count += 1 if value == 0
end
zero_count
```

**More Idiomatic:**
```ruby
data.each_with_object({ position: STARTING_POSITION, count: 0 }) do |turn, state|
  direction, distance = parse_turn(turn)
  state[:position] = (state[:position] + calculate_movement(direction, distance)) % DIAL_SIZE
  state[:count] += 1 if state[:position].zero?
end[:count]
```

Wait, that's more complex! Actually, for this case where we need to track state across iterations, your approach is cleaner. However, we can make it slightly more Ruby-like:

**Better Alternative:**
```ruby
position = STARTING_POSITION

data.count do |turn|
  direction, distance = parse_turn(turn)
  position = (position + calculate_movement(direction, distance)) % DIAL_SIZE
  position.zero?  # count returns true values
end
```

**Why it's more Ruby-like:** Using `count` with a block is more declarative - you're literally counting the items that match a condition. The `.zero?` method is also more Ruby-like than `== 0`.

**Important Note:** The block modifying `position` is a side effect, which some Rubyists might frown upon. Your original approach with explicit counting is actually more clear about its intent!

### 6. Extract Parsing Logic to a Method

**Improvement:**
```ruby
private

def parse_turn(turn)
  direction = turn[0]
  distance = turn[1..-1].to_i
  [direction, distance]
end

# Or more expressive:
def parse_turn(turn)
  match = turn.match(/([LR])(\d+)/)
  [match[1], match[2].to_i]
end
```

Then use it:
```ruby
def part_1
  position = STARTING_POSITION
  zero_count = 0

  data.each do |turn|
    direction, distance = parse_turn(turn)
    movement = (direction == 'L' ? -distance : distance)

    position = (position + movement) % DIAL_SIZE
    zero_count += 1 if position.zero?
  end

  zero_count
end
```

**Why it's better:** Extracting repeated parsing logic reduces duplication and makes the main logic more focused on the problem domain rather than string manipulation.

### 7. Consider Using `.zero?` Instead of `== 0`

**Current:**
```ruby
zero_count += 1 if value == 0
```

**More Ruby-like:**
```ruby
zero_count += 1 if position.zero?
```

**Why it's more Ruby-like:** Ruby provides predicate methods like `.zero?`, `.positive?`, `.negative?`, `.even?`, `.odd?` that read more like natural language. They're more expressive and idiomatic.

### 8. Method Naming - Be Consistent with Ruby Conventions

Your method naming is great! `count_zero_crossings` follows Ruby conventions perfectly. One small thought:

```ruby
def count_zero_crossings(start_position, end_position, direction)
  # renamed parameters for clarity
end
```

Parameter names `start` and `finish` are good, but `start_position` and `end_position` would be even clearer.

## Performance Optimizations

Your solution has excellent time complexity (O(n) where n is the number of rotations) and space complexity (O(1)). There are no significant performance improvements needed.

### Minor Optimization: Avoid Repeated String Indexing

If you were processing millions of rotations, you could cache the parsed data:

```ruby
@parsed_data ||= data.map { |turn| parse_turn(turn) }
```

But for Advent of Code problems, this is unnecessary optimization that would hurt readability.

## Production-Grade Considerations

### Input Validation

For production code, you'd want to validate inputs:

```ruby
def parse_turn(turn)
  raise ArgumentError, "Invalid turn format: #{turn}" unless turn.match?(/^[LR]\d+$/)

  direction = turn[0]
  distance = turn[1..-1].to_i
  [direction, distance]
end
```

**For Exercises:** Advent of Code guarantees valid input, so validation is overkill and would slow you down during competition.

### Edge Case Handling

The `count_zero_crossings` method could document its assumptions:

```ruby
# Counts how many times the dial crosses or lands on 0 during a rotation
# @param start_position [Integer] The starting dial position (0-99)
# @param end_position [Integer] The ending dial position (may be > 99 or < 0 before modulo)
# @param direction [String] 'L' for left, 'R' for right
# @return [Integer] Number of times the dial pointed at 0
def count_zero_crossings(start_position, end_position, direction)
  # ...
end
```

**For Exercises:** Documentation is nice but not essential when you're racing against the clock!

## Refactored Version (Fully Idiomatic)

Here's how I might write this with all the Ruby idioms applied:

```ruby
# frozen_string_literal: true

module Year2025
  class Day01 < Solution
    DIAL_SIZE = 100
    STARTING_POSITION = 50
    DIRECTION_MULTIPLIER = { 'L' => -1, 'R' => 1 }.freeze

    def part_1
      position = STARTING_POSITION

      data.count do |turn|
        direction, distance = parse_turn(turn)
        position = (position + distance * DIRECTION_MULTIPLIER[direction]) % DIAL_SIZE
        position.zero?
      end
    end

    def part_2
      position = STARTING_POSITION

      data.sum do |turn|
        direction, distance = parse_turn(turn)
        new_position = position + distance * DIRECTION_MULTIPLIER[direction]

        crossings = count_zero_crossings(position, new_position, direction)
        position = new_position % DIAL_SIZE

        crossings
      end
    end

    private

    def parse_turn(turn)
      direction = turn[0]
      distance = turn[1..].to_i  # Ruby 2.6+ endless range
      [direction, distance]
    end

    def count_zero_crossings(start_pos, end_pos, direction)
      if direction == 'R'
        end_pos / DIAL_SIZE
      else
        start_segment = (start_pos.to_f / DIAL_SIZE).ceil
        end_segment = (end_pos.to_f / DIAL_SIZE).ceil
        (start_segment - end_segment).abs
      end
    end
  end
end
```

### Key Changes:
- Added constants for magic numbers
- Used `.zero?` predicate method
- Used `.count` in part_1 (though this trades clarity for conciseness)
- Used `.sum` in part_2 instead of manual accumulation
- Used endless range `[1..]` instead of `[1..-1]`
- Extracted direction multiplier to a constant
- More descriptive parameter names

### Trade-offs:
- **More concise** but potentially **less clear** about side effects in part_1
- **More maintainable** with constants
- **Slightly more complex** with the hash lookup

## Learning Resources

To deepen your Ruby knowledge, explore these concepts:

1. **Enumerable Methods**: Study `count`, `sum`, `each_with_object`, `reduce` - they're core to idiomatic Ruby
2. **Pattern Matching**: Ruby 2.7+ pattern matching can make parsing more expressive
3. **Predicate Methods**: Methods ending in `?` like `.zero?`, `.even?`, `.empty?`
4. **String Methods**: Explore `scan`, `match`, `partition` for string parsing
5. **Ruby Style Guide**: Review the [Ruby Style Guide](https://rubystyle.guide/) for community conventions

## Final Thoughts

Your solution demonstrates solid Ruby fundamentals and good problem-solving skills. The code is clean, correct, and easy to understand. The suggestions above are about making it more "Ruby-like" - more expressive and leveraging Ruby's elegant features.

For Advent of Code competitions, your current style strikes a great balance between clarity and speed of implementation. As you continue solving more problems, you'll naturally internalize these idioms and find yourself reaching for them instinctively.

Keep up the great work!
