# frozen_string_literal: true

module Year2025
  class Day03 < Solution
    # @input is available if you need the raw data input
    # Call `data` to access either an array of the parsed data, or a single record for a 1-line input file

    def part_1
      # kinda like daily stock question?
      # two pointer, keep track of highest two values

      data.sum do |bank|
        max = 0
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
        max
      end
    end

    def part_2
      # greey question: we can remove current val if next is larger

      output_length = 12
      data.sum do |bank|
        batteries = bank.chars
        to_remove = batteries.length - output_length

        while to_remove > 0
          has_removed = false
          (0...(batteries.length - 1)).each do |index|
            current_battery = batteries[index].to_i
            next_battery = batteries[index + 1].to_i

            next unless current_battery < next_battery

            batteries.delete_at(index)
            to_remove -= 1
            has_removed = true
            break
          end

          unless has_removed
            batteries.pop(to_remove)
            to_remove = 0
          end
        end
        batteries.join.to_i
      end
    end

    private
  end
end
