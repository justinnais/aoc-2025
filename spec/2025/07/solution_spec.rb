# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Year2025::Day07 do
  let(:input) { File.read(File.join(File.dirname(__FILE__), '../../../challenges/2025/07/input.txt')) }
  let(:example_input) do
    <<~EOF
      .......S.......
      ...............
      .......^.......
      ...............
      ......^.^......
      ...............
      .....^.^.^.....
      ...............
      ....^.^...^....
      ...............
      ...^.^...^.^...
      ...............
      ..^...^.....^..
      ...............
      .^.^.^.^.^...^.
      ...............
    EOF
  end

  describe 'part 1' do
    it 'returns 21 for the example input' do
      expect(described_class.part_1(example_input)).to eq(21)
    end

    it 'returns 1615 for my input' do
      expect(described_class.part_1(input)).to eq(1615)
    end
  end

  describe 'part 2' do
    it 'returns 40 for the example input' do
      expect(described_class.part_2(example_input)).to eq(40)
    end

    it 'returns 43560947406326 for my input' do
      expect(described_class.part_2(input)).to eq(43_560_947_406_326)
    end
  end
end
