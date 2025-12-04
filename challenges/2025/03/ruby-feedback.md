# Ruby Code Review - Day 3

**Review Date:** December 3, 2025

## Overall Assessment

Great work on solving this problem! Your solution demonstrates solid algorithmic thinking with the two-pointer approach in Part 1 and the greedy algorithm in Part 2. The code is functional and well-structured. Both solutions show good problem-solving skills and appropriate algorithm selection for the constraints.

The main opportunities for improvement are around making the code more Ruby-like through better use of Enumerable methods, eliminating unnecessary type conversions, and improving variable naming to make the code more self-documenting.

---

## Ruby Idioms & Best Practices

### 1. Prefer `each_cons` Over Manual Two-Pointer Patterns

**Current Code (Part 1):**
```ruby
left_pointer = 0
right_pointer = 1

while right_pointer < bank.length
  left_num = bank[left_pointer].to_i
  right_num = bank[right_pointer].to_i
  current_num = "#{left_num}#{right_num}".to_i

  max = current_num if current_num > max

  left_pointer = right_pointer if right_num > left_num

  right_pointer += 1
end
```

**Why This Matters:**
Ruby's `Enumerable#each_cons` is designed specifically for iterating over consecutive elements, making sliding window and adjacent pair operations much more expressive. Manual pointer management is more common in lower-level languages but feels un-Ruby-like.

However, your algorithm has special logic where `left_pointer` can jump to `right_pointer` when finding a larger value, which makes this more complex than a simple consecutive iteration. This is actually an interesting case where the imperative approach might be justified!

**Alternative Approach:**
If you were doing a simple two-pointer scan without the jumping logic:
```ruby
bank.chars.each_cons(2).reduce(0) do |max, (left, right)|
  combined = "#{left}#{right}".to_i
  [max, combined].max
end
```

But given your algorithm's complexity with pointer jumping, the current approach is acceptable for this exercise. Just be aware of `each_cons` for simpler consecutive element problems.

### 2. Avoid Redundant Type Conversions

**Current Code:**
```ruby
left_num = bank[left_pointer].to_i
right_num = bank[right_pointer].to_i
current_num = "#{left_num}#{right_num}".to_i
```

**Issue:**
You're converting characters to integers, then back to strings via interpolation, then to integer again. This is wasteful and less readable.

**More Ruby-like:**
```ruby
# Keep them as characters and concatenate directly
left_char = bank[left_pointer]
right_char = bank[right_pointer]
current_num = (left_char + right_char).to_i

# Or even simpler:
current_num = bank[left_pointer..left_pointer+1].to_i
```

**Even Better for Comparisons:**
Since you're comparing digit characters, you can compare them directly without converting to integers:
```ruby
# Character comparison works correctly for single digits
left_pointer = right_pointer if bank[right_pointer] > bank[left_pointer]
```

This works because string comparison in Ruby compares lexicographically, and for single digit characters '0' < '1' < ... < '9'.

### 3. More Idiomatic Loop Structure (Part 2)

**Current Code:**
```ruby
(0...(batteries.length - 1)).each do |index|
  current_battery = batteries[index].to_i
  next_battery = batteries[index + 1].to_i

  next unless current_battery < next_battery

  batteries.delete_at(index)
  to_remove -= 1
  has_removed = true
  break
end
```

**More Ruby-like:**
```ruby
# Using each_with_index and each_cons together
removal_index = batteries.each_cons(2)
                        .each_with_index
                        .find { |(curr, nxt), _| curr < nxt }
                        &.last

if removal_index
  batteries.delete_at(removal_index)
  to_remove -= 1
  has_removed = true
end
```

This is more declarative and separates the "finding" logic from the "acting" logic, which is very Ruby-like.

### 4. Use `chars` Consistently

**Observation:**
In Part 1, you access `bank` as an array directly, but in Part 2, you call `bank.chars`. This suggests `bank` is already a string in both cases.

**Recommendation:**
Be consistent about your data structure expectations. If `bank` is a string:

```ruby
# Part 1
bank.chars.each_with_index do |left_char, left_idx|
  # ...
end
```

Or store `chars = bank.chars` at the beginning if you'll use it multiple times.

### 5. Better Variable Naming

**Current Code:**
```ruby
left_num = bank[left_pointer].to_i
right_num = bank[right_pointer].to_i
```

**Better Names:**
Since these are digits from what appears to be battery power levels or similar:
```ruby
left_digit = bank[left_pointer]
right_digit = bank[right_pointer]

# Or even more descriptive:
current_digit = bank[left_pointer]
next_digit = bank[right_pointer]
```

The name `num` is vague, and since you're working with single digits, `digit` is more accurate.

### 6. Simplify the Fallback Logic (Part 2)

**Current Code:**
```ruby
unless has_removed
  batteries.pop(to_remove)
  to_remove = 0
end
```

**More Ruby-like:**
```ruby
if has_removed
  to_remove -= 1
else
  batteries.pop(to_remove)
  to_remove = 0
end
```

Using positive conditionals (`if`) is generally more readable than negative ones (`unless`), especially when there are multiple statements or when the else branch does something different.

**Alternative Approach - Break Early:**
```ruby
# If you reach this point and haven't removed anything,
# all remaining digits are in descending order
if to_remove > 0 && !has_removed
  batteries.pop(to_remove)
  break  # Exit the while loop entirely
end
```

---

## Performance Optimizations

### 1. Avoid Repeated Array Slicing in Part 1

**Current Approach:**
Your algorithm repeatedly accesses array elements by index, which is fine for arrays but could be optimized.

**Optimization:**
If the arrays are large, consider:
```ruby
chars = bank.chars
max = 0
left_pointer = 0

(1...chars.length).each do |right_pointer|
  current_num = (chars[left_pointer] + chars[right_pointer]).to_i
  max = [max, current_num].max
  left_pointer = right_pointer if chars[right_pointer] > chars[left_pointer]
end
```

This pre-converts to chars array once and uses `[max, current_num].max` which is slightly more idiomatic.

### 2. Critical Issue: Inefficient `delete_at` in Loop (Part 2)

**Current Code:**
```ruby
(0...(batteries.length - 1)).each do |index|
  # ...
  batteries.delete_at(index)
  # ...
  break
end
```

**Problem:**
`Array#delete_at` is O(n) because it needs to shift all subsequent elements. Doing this in a loop that runs up to `to_remove` times gives you O(n * k) complexity where k is the number of deletions.

**Better Approach - Build New Array:**
```ruby
def part_2
  output_length = 12
  data.sum do |bank|
    result = []
    to_remove = bank.length - output_length

    bank.chars.each do |digit|
      # Remove elements from result while the current digit is larger
      while to_remove > 0 && !result.empty? && result.last < digit
        result.pop
        to_remove -= 1
      end
      result << digit
    end

    # Remove remaining from the end if needed
    result.pop(to_remove) if to_remove > 0

    result.join.to_i
  end
end
```

This is the classic "monotonic stack" approach - O(n) instead of O(n * k). Each element is pushed and popped at most once.

**Why This Is Better:**
- Single pass through the data
- No repeated array shifting
- More efficient use of Ruby's array operations
- Clearer algorithmic intent

### 3. Avoid String Interpolation for Simple Concatenation

**Current Code:**
```ruby
current_num = "#{left_num}#{right_num}".to_i
```

**Better:**
```ruby
# String concatenation
current_num = (left_char + right_char).to_i

# Or if you have integers and want to concatenate digits:
current_num = left_num * 10 + right_num  # Mathematical approach
```

String interpolation has overhead for the expression evaluation. For simple concatenation, use `+` or mathematical operations.

---

## Production-Grade Considerations (Optional)

While your solution is excellent for an exercise, here are some production considerations:

### 1. Edge Case Handling
```ruby
def part_1
  data.sum do |bank|
    return 0 if bank.nil? || bank.length < 2

    # ... rest of logic
  end
end
```

### 2. Input Validation
```ruby
def part_2
  output_length = 12
  data.sum do |bank|
    if bank.length <= output_length
      # What should happen if the string is already short enough?
      return bank.to_i
    end

    # ... rest of logic
  end
end
```

### 3. Magic Numbers
```ruby
OUTPUT_LENGTH = 12  # Document why this number

def part_2
  data.sum do |bank|
    batteries = bank.chars
    to_remove = batteries.length - OUTPUT_LENGTH
    # ...
  end
end
```

---

## Refactored Solution

Here's how I might write this in a more Ruby-like style:

```ruby
# frozen_string_literal: true

module Year2025
  class Day03 < Solution
    def part_1
      data.sum do |bank|
        chars = bank.chars
        max_value = 0
        max_digit_idx = 0

        (1...chars.length).each do |idx|
          # Check concatenation with current max digit
          concatenated = (chars[max_digit_idx] + chars[idx]).to_i
          max_value = [max_value, concatenated].max

          # Update max digit position if we found a larger digit
          max_digit_idx = idx if chars[idx] > chars[max_digit_idx]
        end

        max_value
      end
    end

    def part_2
      OUTPUT_LENGTH = 12

      data.sum do |bank|
        result = []
        to_remove = bank.length - OUTPUT_LENGTH

        bank.chars.each do |digit|
          # Greedy: remove smaller digits when we see a larger one
          while to_remove > 0 && !result.empty? && result.last < digit
            result.pop
            to_remove -= 1
          end
          result << digit
        end

        # Remove any remaining digits from the end
        result.pop(to_remove) if to_remove > 0

        result.join.to_i
      end
    end
  end
end
```

**Key Improvements:**
- Pre-convert to chars array for consistency
- Use `[max_value, concatenated].max` for idiomatic max finding
- Monotonic stack algorithm in Part 2 for O(n) performance
- Better variable names (`max_digit_idx` vs `left_pointer`)
- More descriptive comments explaining the algorithm
- No redundant type conversions

---

## Learning Resources

To deepen your Ruby skills, explore these topics:

1. **Enumerable Methods**: Study `each_cons`, `each_with_index`, `reduce`, `inject`, and `max_by`
   - [Ruby Enumerable Documentation](https://ruby-doc.org/core/Enumerable.html)

2. **String vs Character Operations**: Understand when to work with strings directly vs converting to arrays
   - Character comparisons work lexicographically in Ruby

3. **Algorithm Patterns in Ruby**: Learn about monotonic stack, two-pointer, and sliding window patterns
   - How to express algorithmic patterns idiomatically in Ruby

4. **Performance Considerations**: Understand the Big O complexity of Ruby array operations
   - `delete_at` is O(n), `pop` is O(1)
   - Building new arrays vs mutating existing ones

5. **Ruby Style Guide**: Familiarize yourself with community conventions
   - [Ruby Style Guide](https://rubystyle.guide/)

---

## Summary

Your solution shows strong algorithmic thinking and works correctly! The main areas for growth are:

1. **Use character operations directly** instead of converting to integers unnecessarily
2. **Consider monotonic stack** for the greedy removal problem (Part 2) - much more efficient
3. **Use more descriptive variable names** (digit vs num, max_digit_idx vs left_pointer)
4. **Leverage Enumerable methods** where appropriate, but don't force them when imperative code is clearer

Keep up the excellent work! Your solutions are well-structured and show good algorithmic intuition. These suggestions will help you write even more idiomatic and performant Ruby code.
