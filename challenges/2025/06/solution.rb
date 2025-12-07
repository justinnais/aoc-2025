# frozen_string_literal: true

module Year2025
  class Day06 < Solution
    def part_1
      grid = create_grid
      grid.sum do |equation|
        *numbers, operator = equation
        numbers.map(&:to_i).reduce(operator.to_sym)
      end
    end

    def part_2
      # wtf am I reading
      # for each equation, take chars from right of each number to construct num?
      # need to maintain whitespace, split won't work

      create_equations.sum do |equation|
        *initial_numbers, operator = equation

        max_index = initial_numbers.map(&:length).max - 1
        number_chars = initial_numbers.map(&:chars)
        columns = []

        max_index.downto(0) do |i|
          column = number_chars.map do |number|
            number.dig(-i - 1)
          end
          columns << column
        end

        transformed_numbers = columns.map do |numbers|
          numbers.compact.join.to_i
        end

        puts transformed_numbers.join(operator)

        transformed_numbers.map(&:to_i).reduce(operator.to_sym)
      end
    end

    private

    def create_grid
      data.map do |line|
        line.split
      end.transpose
    end

    def create_equations
      equations = []
      operators = data.pop.chars

      left_pointer = 0
      operators.each_cons(2).each_with_index do |group, index|
        next unless group[0] == ' ' && group[1] != ' '

        operator = operators[left_pointer]

        numbers = []
        data.each do |line|
          number = line[left_pointer..index - 1]
          numbers << number
        end
        numbers << operator
        equations << numbers
        left_pointer = index + 1
      end

      # has to be a better way for this
      final_index = operators.length
      final_operator = operators[left_pointer]

      final_numbers = []
      data.each do |line|
        final_number = line[left_pointer..final_index - 1]
        final_numbers << final_number
      end
      final_numbers << final_operator
      equations << final_numbers

      equations
    end
  end
end
