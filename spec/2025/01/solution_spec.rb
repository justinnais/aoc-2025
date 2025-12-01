# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Year2025::Day01 do
  let(:input) { File.read(File.join(File.dirname(__FILE__), '../../../challenges/2025/01/input.txt')) }
  let(:example_input) do
    <<~EOF
      L68
      L30
      R48
      L5
      R60
      L55
      L1
      L99
      R14
      L82
    EOF
  end

  describe 'part 1' do
    it 'returns 3 for the example input' do
      expect(described_class.part_1(example_input)).to eq(3)
    end

    it 'returns 1029 for my input' do
      expect(described_class.part_1(input)).to eq(1029)
    end
  end

  describe 'part 2' do
    it 'returns 6 for the example input' do
      expect(described_class.part_2(example_input)).to eq(6)
    end

    it 'returns 5892 for my input' do
      expect(described_class.part_2(input)).to eq(5892)
    end
  end
end
